const shell = require('@travist/async-shell');
module.exports = (program) => {
    program
        .command('push <source> <destination>')
        .description('Push an application to a hosted environment.')
        .action(async (source, destination) => {
            let downloaded = false;
            let parts = [];
            if (source.indexOf('@') > 0) {
                downloaded = true;
                parts = source.split('@');
                const path = (parts[0] === 'formio-app') ? parts[1] : parts.join('/');
                await shell(`mkdir ${parts[0]}`);
                await shell(`aws s3 cp s3://formio-app-releases/${path}.tgz .`);
                await shell(`tar -zxvf ${parts[1]}.tgz -C ./${parts[0]}`);
                await shell(`rm ${parts[1]}.tgz`);
                source = `./${parts[0]}`;
            }
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
                case 'manager.form.io':
                    cloudfront = 'EHP8U7763VP9D';
                    break;
                case 'manager.test-form.io':
                    cloudfront = 'E1FSS9J2KV6QL4';
                    break;
                case 'edge.form.io':
                    cloudfront = 'E2IPD36UKEMHZJ';
                    break;
            }
            await shell(`aws s3 sync --acl public-read --exclude "node_modules/*" --exclude ".git/*" ${source} s3://${destination}`);
            if (cloudfront) {
                await shell(`aws cloudfront create-invalidation --distribution-id ${cloudfront} --paths "/*"`)
            }
            if (downloaded) {
                await shell(`rm -rf ./${parts[0]}`);
            }
        });
};
