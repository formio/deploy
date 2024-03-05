const _ = require('lodash');
const fs = require('fs');
const path = require('path');
const compose = _.template(fs.readFileSync(path.join(__dirname, 'compose/docker-compose.yml.tpl')));
const nginx = _.template(fs.readFileSync(path.join(__dirname, 'nginx/default.conf.tpl')));

// Function to process all template files in a directory
function processHelmTemplates(directory) {
    let templates = {};

    const readDirectory = dir => {
        fs.readdirSync(dir).forEach(filename => {
            const filePath = path.join(dir, filename);
            const fileStat = fs.statSync(filePath);

            if (fileStat.isDirectory()) {
                // If it's a directory, recursively read it
                readDirectory(filePath);
            } else {
                // List of file extensions to process
                const fileExtensions = ['.yaml', '.sh', '.tpl', '.md', '.gitignore', '.helmignore'];

                if (fileExtensions.includes(path.extname(filename))) {
                    // Process files with the specified extensions
                    const fileContents = fs.readFileSync(filePath, 'utf8');
                    // Create a relative path key for the templates object
                    const relativePath = path.relative(directory, filePath);
                    templates[relativePath] = _.template(fileContents);
                }
            }
        });
    };

    readDirectory(directory);

    return templates;
}

// Directory containing the YAML templates
const templatesDir = path.join(__dirname, 'helm');

// Process the templates
const helm = processHelmTemplates(templatesDir);


module.exports = {
    compose: (package, options) => compose({package, options}).replace(/\n+/g, "\n"),
    nginx: (package, options) => nginx({package, options}).replace(/\n+/g, "\n"),
    helm: (package, options) => {
        // Process each Helm template and return the results
        return Object.keys(helm).reduce((acc, templateName) => {
            const templateFunction = helm[templateName];
            acc[templateName] = templateFunction({package, options}).replace(/\n+/g, "\n");
            return acc;
        }, {});
    },
}