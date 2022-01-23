const Package = require('../src/Package');
const defaultOptions = Package.defaultOptions;
module.exports = (program) => {
    program
        .command('package [path]').alias('p')
        .description('Create a new deployment package.')
        .option('--dir', 'The default directory within your home folder to place the deployments.', defaultOptions.dir)
        .option('--license [LICENSE_KEY]', 'Your deployment license.', defaultOptions.license)
        .option('--server [server]', 'The Form.io Enterprise Server Docker repo', defaultOptions.server)
        .option('--version [version]', 'The Form.io Enterprise Server version.', defaultOptions.version)
        .option('--pdf [server]', 'The Form.io PDF Server Docker Repo', defaultOptions.pdf)
        .option('--pdf-version [version]', 'The Form.io PDF Server version.', defaultOptions.pdfVersion)
        .option('--submission-server [option]', 'The Form.io Submission Server Docker Repository', defaultOptions.submissionServer)
        .option('--sub-version [version]', 'The Form.io Submission Server version.', defaultOptions.subVersion)
        .option('--db-secret [secret]', 'The Database Secret.', defaultOptions.dbSecret)
        .option('--jwt-secret [secret]', 'The JWT Token Secret', defaultOptions.jwtSecret)
        .option('--admin-email [email]', 'The default root admin email address', defaultOptions.adminEmail)
        .option('--admin-pass [password]', 'The default root admin password', defaultOptions.adminPass)
        .option('--mongo-cert [cert]', 'File path or URL to the MongoDB SSL Certificate')
        .option('--ssl-cert [cert]', 'File path or URL to the SSL Certificate for the deployment to enable SSL.')
        .option('--ssl-key [key]', 'File path or URL to the SSL Certificate Key for the deployment to enable SSL.')
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