const Package = require('../src/Package');
const shell = require('@travist/async-shell');
const defaultOptions = Package.defaultOptions;
const fs = require('fs/promises');
const path = require('path');
module.exports = (program) => {
    program
        .command('run').alias('r')
        .description('Locally run a Form.io Environment.')
        .option('--dir', 'The default directory within your home folder to place the deployments.', defaultOptions.dir)
        .option('--license [LICENSE_KEY]', 'Your deployment license.', defaultOptions.license)
        .option('--server [server]', 'The Form.io Enterprise Server Docker repo', defaultOptions.server)
        .option('--version [version]', 'The Form.io Enterprise Server version.', defaultOptions.version)
        .option('--pdf [server]', 'The Form.io PDF Server Docker Repo', defaultOptions.pdf)
        .option('--pdf-version [version]', 'The Form.io PDF Server version.', defaultOptions.pdfVersion)
        .option('--uswds-version [version]', 'The USWDS PDF Server version.', defaultOptions.uswdsVersion)
        .option('--submission-server [option]', 'The Form.io Submission Server Docker Repository', defaultOptions.submissionServer)
        .option('--sub-version [version]', 'The Form.io Submission Server version.', defaultOptions.subVersion)
        .option('--db-secret [secret]', 'The Database Secret.', defaultOptions.dbSecret)
        .option('--jwt-secret [secret]', 'The JWT Token Secret', defaultOptions.jwtSecret)
        .option('--admin-email [email]', 'The default root admin email address', defaultOptions.adminEmail)
        .option('--admin-pass [password]', 'The default root admin password', defaultOptions.adminPass)
        .option('--mongo-cert [cert]', 'File path or URL to the MongoDB SSL Certificate')
        .option('--ssl-cert [cert]', 'File path or URL to the SSL Certificate for the deployment to enable SSL.')
        .option('--ssl-key [key]', 'File path or URL to the SSL Certificate Key for the deployment to enable SSL.')
        .option('--port [port]', 'The port to use for NGINX configurations.')
        .option('--save')
        .action(async (options) => {
            if (options.save) {
                await fs.writeFile(path.join(options.dir, 'config.json'), JSON.stringify(options, null, 2));
            }
            else {
                if (await fs.stat(path.join(options.dir, 'config.json'))) {
                    options = JSON.parse(await fs.readFile(path.join(options.dir, 'config.json'), 'utf8'));
                }
            }
            const package = new Package('compose/local.zip', options);
            await package.create();
            await shell('docker-compose -f ~/deployments/current/docker-compose.xml up');
        });
};