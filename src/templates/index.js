const _ = require('lodash');
const fs = require('fs');
const path = require('path');
const compose = _.template(fs.readFileSync(path.join(__dirname, 'compress/docker-compose.yml.tpl')));
const nginx = _.template(fs.readFileSync(path.join(__dirname, 'nginx/default.conf.tpl')));
module.exports = {
    compose: (package, options) => compose({package, options}).replace(/\n+/g, "\n"),
    nginx: (package, options) => nginx({package, options}).replace(/\n+/g, "\n")
}