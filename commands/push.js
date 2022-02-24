const shell = require('@travist/async-shell');
module.exports = (program) => {
    program
        .command('push <source> <destination>').alias('p')
        .description('Push an application to a hosted environment.')
        .action(async (source, destination) => {
            await shell(`aws s3 cp --recursive --acl public-read --exclude "*node_modules*|*\.git*" ${source}/ s3://${destination}`);
        });
};