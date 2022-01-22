const Package = require('../src/Package');
module.exports = (program) => {
    program
        .command('package [path]').alias('p')
        .description('Create a new deployment package.')
        .option('--license [LICENSE_KEY]', 'Your deployment license.')
        .option('--server [server]', 'The Form.io Enterprise Server Docker repo')
        .option('--version [version]', 'The Form.io Enterprise Server version.')
        .option('--pdf-version [version]', 'The Form.io PDF Server version.')
        .option('--sub-version [version]', 'The Form.io Submission Server version.')
        .option('--db-secret [secret]', 'The Database Secret.')
        .option('--jwt-secret [secret]', 'The JWT Token Secret')
        .option('--admin-email [email]', 'The default root admin email address')
        .option('--admin-pass [password]', 'The default root admin password')
        .option('--ssl-cert [cert]', 'File path to the SSL Certificate for the deployment to enable SSL.')
        .option('--ssl-key [key]', 'File path to the SSL Certificate Key for the deployment to enable SSL.')
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