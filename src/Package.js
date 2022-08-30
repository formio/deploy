const path = require('path');
const _fs = require('fs');
const fs = require('fs/promises');
const fsExtra = require('fs-extra');
const zipper = require('zip-local');
const templates = require('./templates');
const _ = require('lodash');
const packages = require('./packages.json');
const homedir = require('os').homedir();
const fetch = require('node-fetch');
const semver = require('semver');

// See if this is being run locally or not.
let isLocal = false;
try {
    const pkgJson = JSON.parse(_fs.readFileSync(path.join(process.cwd(), 'package.json'), 'utf8'));
    isLocal = pkgJson.name === '@formio/deploy';
}
catch (err) {

}

class Package {
    static downloadCache = {};
    static get defaultOptions() {
        return {
            dir: path.join(isLocal ? process.cwd() : homedir, 'deployments'),
            server: 'formio/formio-enterprise',
            version: 'latest',
            pdf: 'formio/pdf-server',
            pdfVersion: 'latest',
            submissionServer: 'formio/submission-server',
            subVersion: 'latest',
            uswdsVersion: 'latest',
            dbSecret: 'CHANGEME',
            jwtSecret: 'CHANGEME',
            adminEmail: 'admin@example.com',
            adminPass: 'CHANGEME',
            port: '80',
            hosted: false,
            portal: true,
            default: true
        };
    }

    static options(options) {
        options = _.defaults(options || {}, Package.defaultOptions);
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
     * @parm deployment - The path to the deployment we wish to create.
     * @param {*} options - Configurations.
     * @param options.license - The Form.io license
     * @param options.server - The Form.io Enterprise Server Docker repo
     * @param options.version - The Form.io Enterprise Server version.
     * @param options.pdfVersion - The Form.io PDF Server version.
     * @param options.subVersion - The Form.io Submission Server version.
     * @param options.uswdsVersion - The USWDS Viewer version.
     * @param options.dbSecret - The Database Secret
     * @param options.jwtSecret - The JWT Secret
     * @param options.adminEmail - The Admin email address
     * @param options.adminPass - The Admin password
     * @param options.sslCert - File path or URL to the SSL certificate
     * @param options.sslKey - File path or URL to the SSL certificate key
     * @param options.mongoCert - File path or URL to the MongoDB SSL Certificate.
     */
    constructor(deployment, options) {
        if (!deployment.match(/\.zip$/)) {
            deployment = `${deployment}.zip`;
        }
        this.path = deployment;
        this.options = options.default ? options : Package.options(options);
        this.pathParts = this.path.split('/');
        this.type = this.pathParts[0];
        this.outputPath = path.join(this.options.dir, ...this.pathParts);
        const pkgName = this.pathParts.pop();
        const pkgPath = this.pathParts.join('.');
        this.package = _.get(this.options.packages, pkgPath, {})[pkgName];
        if (!this.package) {
            throw `Cannot find package ${pkgPath}.${pkgName}`;
        }
        if (this.options.pdfVersion === 'latest' || semver.gt(this.options.pdfVersion, '4.0.0-rc.1')) {
            this.package.pdfLibs = true;
        }
        this.currentDir = path.join(this.options.dir, 'current');
        this.templateDir = path.join(__dirname, 'templates');
        this.certsDir = path.join(this.currentDir, 'certs');
        this.hasCert = false;
    }

    pathOrLocal(filePath) {
        if (filePath[0] === '/') {
            return filePath;
        }
        return path.join(process.cwd(), ...filePath.split('/'));
    }

    async fileContents(filePath) {
        if (filePath.match(/^http[s]?:/)) {
            if (!Package.downloadCache.hasOwnProperty(filePath)) {
                console.log(`Downloading file contents ${filePath}`);
                const resp = await fetch(filePath);
                Package.downloadCache[filePath] = await resp.text();
            }
            return Package.downloadCache[filePath];
        }
        else {
            return await fs.readFile(this.pathOrLocal(filePath));
        }
    }

    async fullPackage() {
        if (this.package.full) {
            return this.package;
        }
        if (!this.package.hasOwnProperty('nginx')) {
            this.package.nginx = false;
        }
        if (!this.package.hasOwnProperty('server')) {
            this.package.server = this.options.server;
        }
        if (this.package.server && (this.package.version || this.options.version)) {
            this.package.server += `:${this.package.version || this.options.version}`;
        }
        if (!this.package.hasOwnProperty('pdf')) {
            this.package.pdf = this.options.pdf;
        }
        if (this.package.pdf && (this.package.pdfVersion || this.options.pdfVersion)) {
            this.package.pdf += `:${this.package.pdfVersion || this.options.pdfVersion}`;
        }
        if (!this.package.hasOwnProperty('portal')) {
            this.package.portal = true;
        }
        const mongoCert = this.options.mongoCert || this.package.mongoCert;
        if (mongoCert) {
            this.package.mongoCert = mongoCert;
            this.package.mongoCertName = this.package.mongoCertName || mongoCert.split('/').pop();
        }
        if (this.options.sslCert) {
            this.package.sslCert = await this.fileContents(this.options.sslCert);
            this.package.sslCert = this.package.sslCert.toString().replace(/\n/g, '\\n');
        }
        if (this.options.sslKey) {
            this.package.sslKey = await this.fileContents(this.options.sslKey);
            this.package.sslKey = this.package.sslKey.toString().replace(/\n/g, '\\n');
        }
        this.package.full = true;
    }

    async addCert(name, fn) {
        if (!name) {
            return;
        }
        if (!this.hasCert) {
            try {
                await fs.rmdir(this.certsDir, { recursive: true });
            }
            catch (err) {
                // Ignore...
            }
        }
        await fs.mkdir(this.certsDir, { recursive: true });
        console.log(`Creating Certificate: ${name}`)
        await fn();
        this.hasCert = true;
    }

    async addCerts() {
        if (!this.options.hosted) {
            await this.addCert(this.package.mongoCertName, async () => await fs.writeFile(path.join(this.certsDir, this.package.mongoCertName), await this.fileContents(this.package.mongoCert)));
            await this.addCert(this.options.sslCert, async () => await fs.copyFile(path.join(this.pathOrLocal(this.options.sslCert)), path.join(this.certsDir, 'cert.crt')));
            await this.addCert(this.options.sslKey, async () => await fs.copyFile(path.join(this.pathOrLocal(this.options.sslKey)), path.join(this.certsDir, 'cert.key')));    
        }
        if (!this.hasCert || this.options.hosted) {
            // Delete the certs folder.
            try {
                await fs.rmdir(this.certsDir, { recursive: true });
            }
            catch (err) {
                // Ignore.
            }
        }
    }

    async addNGINX() {
        if (this.package.nginx) {
            console.log('Adding NGINX configuration.');
            await fs.mkdir(path.join(this.currentDir, 'conf.d'), { recursive: true });
            await fs.writeFile(path.join(this.currentDir, 'conf.d', 'default.conf'), templates.nginx(this.package, this.options));
        }
        else {
            // Delete the nginx folder.
            try {
                await fs.rmdir(path.join(this.currentDir, 'conf.d'), { recursive: true });
            }
            catch (err) {
                // Ignore.
            }
        }
    }

    async addExtensions() {
        if (this.package.aws) {
            console.log('Adding AWS extensions');
            await fsExtra.copy(path.join(this.templateDir, '.platform'), path.join(this.currentDir, '.platform'));
            await fsExtra.copy(path.join(this.templateDir, '.ebextensions'), path.join(this.currentDir, '.ebextensions'));
        }
        else {
            // Delete the platform folder.
            try {
                await fs.rmdir(path.join(this.currentDir, '.platform'), { recursive: true });
                await fs.rmdir(path.join(this.currentDir, '.ebextensions'), { recursive: true });
            }
            catch (err) {
                // Ignore.
            }
        }
    }

    async addManifest() {
        console.log(`Creating ${this.type} manifest.`);
        const manifest = templates[this.type](this.package, this.options);
        switch (this.type) {
            case 'compose':
                await fs.writeFile(path.join(this.currentDir, 'docker-compose.yml'), manifest, {encoding:'utf8',flag:'w'});
                break;
        }
    }

    async createPackage() {
        let dataExists = await fsExtra.pathExists(path.join(this.currentDir, 'data'));
        // Move the data folder out of the current directory.
        if (dataExists) {
            try {
                await fs.rmdir(path.join(this.options.dir, '.tmp_data'), { recursive: true });
                await fsExtra.move(path.join(this.currentDir, 'data'), path.join(this.options.dir, '.tmp_data'));
            }
            catch (err) {
                dataExists = false;
            }
        }
        console.log(`Creating package ${this.outputPath}.`);
        await fs.mkdir(path.join('/', ...this.outputPath.split('/').slice(0, -1)), { recursive: true });
        zipper.sync.zip(path.join(this.currentDir, '/')).compress().save(this.outputPath);
        if (this.package.local) {
            // Move the data folder back.
            if (dataExists) {
                await fsExtra.move(path.join(this.options.dir, '.tmp_data'), path.join(this.currentDir, 'data'));
            }
            else {
                await fs.mkdir(path.join(this.currentDir, 'data'), { recursive: true });
            }

            // Create the .env file.
            if (this.options.save) {
                let envFile = '';
                if (this.options.license) {
                    envFile += `LICENSE=${this.options.license}\\n`;
                }
                if (this.options.dbSecret) {
                    envFile += `LICENSE=${this.options.license}\\n`;
                }
            }
        }
    }

    async create() {
        console.group(`Creating ${this.path}`);
        try {
            console.log('Removing previous package.');
            await fs.unlink(this.outputPath);
        }
        catch (err) { }
        if (this.package) {
            await this.fullPackage();
            await this.addNGINX();
            await this.addExtensions();
            await this.addCerts();
            await this.addManifest();
            await this.createPackage();
        }
        else {
            console.log('Package not found.');
        }
        console.groupEnd();
    }
}

module.exports = Package;