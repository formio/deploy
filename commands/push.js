const shell = require('@travist/async-shell');
module.exports = (program) => {
    program
        .command('push <source> <destination>').alias('p')
        .description('Push an application to a hosted environment.')
        .action(async (source, destination) => {
            let cloudfront = '';
            switch (destination) {
                case 'portal.test-form.io':
                    cloudfront = 'E2BZNWGLSP355U';
                    break;
                case 'portal.form.io':
                    cloudfront = 'E3BVZ9SUM1E422';
                    break;
                case 'pro.formview.io':
                    cloudfront = 'E1G0SRPKZNR4IC';
                    break;
                case 'test.formview.io':
                    cloudfront = 'E1GH8TBBTOUUKY';
                    break;
                case 'apps.form.io/manager':
                    cloudfront = 'E26X18INJPZZZI';
                    break;
            }
            await shell(`aws s3 sync --acl public-read --exclude "node_modules/*" --exclude ".git/*" ${source} s3://${destination}`);
            if (cloudfront) {
                await shell(`aws cloudfront create-invalidation --distribution-id ${cloudfront} --paths "/*"`)
            }
        });
};