/* helper script to generate markdown table from terraform variables.tf file */

const { log } = require('console');
const fs = require('fs');
const regex = /variable "(.+?)" \{(.+?)\}/gs;

// Read the variables.tf file
const content = fs.readFileSync('aws/variables.tf', 'utf-8');

let match;
let markdownTable = "| Name | Description | Default Value |\n| --- | --- | --- |\n";

while ((match = regex.exec(content)) !== null) {
    const name = match[1].trim();
    let block = match[2].trim();
    log(block);

    // Extract description and default value
    let descriptionMatch = block.match(/description = "(.*?)"/s);
    let description = descriptionMatch ? descriptionMatch[1].trim() : 'N/A';

    let defaultMatch = block.match(/default\s+=\s+(.*)/s);
    console.log(defaultMatch);
    let defaultValue = defaultMatch ? defaultMatch[1].trim() : 'N/A';

    // Add to the markdown table
    markdownTable += `| ${name} | ${description} | ${defaultValue} |\n`;
}

console.log(markdownTable);