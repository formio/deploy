const path = require('path');
const fs = require('fs/promises');
const zipper = require('zip-local');
const templates = require('./templates');
const _ = require('lodash');
const packages = require('./packages.json');

class Package {
    static defaultOptions(options) {
        options = _.defaults(options || {}, {
            server: 'formio/formio-enterprise',
            version: 'latest',
            pdf: 'formio/pdf-server',
            pdfVersion: 'latest',
            submissionServer: 'formio/submission-server',
            subVersion: 'latest',
            dbSecret: 'CHANGEME',
            jwtSecret: 'CHANGEME',
            adminEmail: 'admin@example.com',
            adminPass: 'CHANGEME',
            default: true
        });
        options.packages = JSON.parse(_.template(JSON.stringify(packages))({ options }));
        return options;
    }

    // Iterate through each package.
    static eachPackage(fn, path, pkgs) {
        pkgs = pkgs || packages;
        path = path ? `${path}/` : '';
        _.each(pkgs, (pkg, name) => {
            if (name.match(/\.zip$/)) {
                fn(`${path}${name}`);
            }
            else if (_.isObject(pkg)) {
                Package.eachPackage(fn, `${path}${name}`, pkg);
            }
        });

    }

    // Package all libs.
    static async all(options) {
        const pkgs = [];
        Package.eachPackage((path) => {
            pkgs.push(new Package(path, options));
        });
        for (var i = 0; i < pkgs.length; i++) {
            await pkgs[i].create();
        }
    }

    /**
     * @parm path - The path to the deployment we wish to create.
     * 
     * @param {*} options - Configurations.
     * @param options.license - The Form.io license
     * @param options.server - The Form.io Enterprise Server Docker repo
     * @param options.version - The Form.io Enterprise Server version.
     * @param options.pdfVersion - The Form.io PDF Server version.
     * @param options.subVersion - The Form.io Submission Server version.
     * @param options.dbSecret - The Database Secret
     * @param options.jwtSecret - The JWT Secret
     * @param options.adminEmail - The Admin email address
     * @param options.adminPass - The Admin password
     * @param options.sslCert - File path to the SSL certificate
     * @param options.sslKey - File path to the SSL certificate key
     */
    constructor(path, options) {
        this.path = path;
        this.options = options.default ? options : Package.defaultOptions(options);
    }

    pathOrLocal(filePath) {
        if (filePath[0] === '/') {
            return filePath;
        }
        return path.join(process.cwd(), ...filePath.split('/'));
    }

    async package(pkg) {
        if (pkg.package) {
            return pkg;
        }
        if (!pkg.hasOwnProperty('server')) {
            pkg.server = this.options.server;
            pkg.server += `:${pkg.version || this.options.version}`;
        }
        if (!pkg.hasOwnProperty('pdf')) {
            pkg.pdf = this.options.pdf;
            pkg.pdf += `:${pkg.pdfVersion || this.options.pdfVersion}`;
        }
        if (!pkg.hasOwnProperty('portal')) {
            pkg.portal = true;
        }
        if (this.options.sslCert) {
            pkg.sslCert = await fs.readFile(this.pathOrLocal(this.options.sslCert));
        }
        if (this.options.sslKey) {
            pkg.sslCert = await fs.readFile(this.pathOrLocal(this.options.sslKey));
        }
        pkg.package = true;
        return pkg;
    }

    async create() {
        console.group(`Creating ${this.path}`);
        const pkgParts = this.path.split('/');
        const outputPath = path.join(process.cwd(), 'deployments', ...pkgParts);
        try {
            console.log('Removing temporary folder.');
            await fs.rmdir(path.join(process.cwd(), '.formio-tmp'), {
                recursive: true
            });
        }
        catch (err) { }
        try {
            console.log('Removing previous package.');
            await fs.unlink(outputPath);
        }
        catch (err) { }
        let pkgPaths = this.path.split('/');
        const pkgName = pkgPaths.pop();
        const pkgPath = pkgPaths.join('.');
        let pkg = _.get(this.options.packages, pkgPath, {})[pkgName];
        if (pkg) {
            pkg = await this.package(pkg);
            const type = pkgParts[0];
            const manifest = templates[type](pkg, this.options);
            const nginx = templates.nginx(pkg, this.options);

            console.log('Creating temporary folder.');
            await fs.mkdir(path.join(process.cwd(), '.formio-tmp'));

            // Add NGINX
            if (!pkg.local) {
                console.log('Adding NGINX configuration.');
                await fs.mkdir(path.join(process.cwd(), '.formio-tmp', 'conf.d'), {recursive: true});
                await fs.writeFile(path.join(process.cwd(), '.formio-tmp', 'conf.d', 'default.conf'), nginx);
            }

            // If we have a mongo cert, copy it over.
            if (pkg.mongoCert) {
                console.log(`Copying MongoDB Certificate: ${pkg.mongoCert}`);
                await fs.mkdir(path.join(process.cwd(), '.formio-tmp', 'certs'), {recursive: true});
                await fs.copyFile(path.join(__dirname, 'certs', pkg.mongoCert), path.join(process.cwd(), '.formio-tmp', 'certs', pkg.mongoCert));
            }

            // If they provided their own certs, copy them over.
            if (this.options.sslCert) {
                console.log(`Copying certificate: ${this.options.sslCert}`);
                await fs.mkdir(path.join(process.cwd(), '.formio-tmp', 'certs'), {recursive: true});
                await fs.copyFile(path.join(this.pathOrLocal(this.options.sslCert), 'utf8'), path.join(process.cwd(), '.formio-tmp', 'certs', 'cert.crt'));
            }
            if (this.options.sslKey) {
                console.log(`Copying certificate key: ${this.options.sslKey}`);
                await fs.mkdir(path.join(process.cwd(), '.formio-tmp', 'certs'), {recursive: true});
                await fs.copyFile(path.join(this.pathOrLocal(this.options.sslKey), 'utf8'), path.join(process.cwd(), '.formio-tmp', 'certs', 'cert.key'));
            }

            // Add manifest file.
            console.log(`Creating manifest.`);
            switch (type) {
                case 'compose':
                    await fs.writeFile(path.join(process.cwd(), '.formio-tmp', 'docker-compose.yml'), manifest);
                    break;
            }

            // Create the package.
            console.log(`Creating package ${outputPath}.`);
            pkgParts.pop();
            await fs.mkdir(path.join(process.cwd(), 'deployments', ...pkgParts), {recursive: true});
            zipper.sync.zip(path.join(process.cwd(), '.formio-tmp/')).compress().save(outputPath);
        }
        else {
            console.log('Package not found.');
        }
        console.groupEnd();
    }
}

module.exports = Package;