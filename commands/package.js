const Package = require('../src/Package');
const defaultOptions = Package.defaultOptions;
module.exports = (program) => {
    program
        .command('package [path]').alias('p')
        .description('Create a new deployment package.')
        .option('--dir [dir]', 'The default directory within your home folder to place the deployments.', defaultOptions.dir)
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
        .option('--hosted', 'If this is a hosted environment and comes with its own MongoDB interface')
        .option('--no-portal', 'If you do not wish to have the portal')
        .option('--save', 'Save the configuration parameters into a local .env file for future deployments.')
        .action(async (path, options) => {
            if (!path) {
                // Build all packages.
                await Package.all(options);
                console.log('Done!');
            }
            else {
                const package = new Package(path, options);
                await package.create();
                console.log('Done!');
            }
        });
};