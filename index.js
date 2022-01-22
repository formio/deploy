const { Command } = require('commander');
const program = new Command();
const pkg = require('./package.json');
program.version(pkg.version);
require('./commands')(program);
try {
  program.parse(process.argv);
}
catch (err) {
  console.log(err);
}
