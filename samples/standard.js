const parameters = require('..');
require('should');

// NAME
//     server - Start a web server
// SYNOPSIS
//     server [options...]
// DESCRIPTION
//     -h --host           Web server listen host
//     -p --port           Web server listen port
//     -h --help           Display help information
// EXAMPLES
//     server --help     Show this message

const command = parameters({
  name: 'server',
  description: 'Start a web server',
  options: {
    'host': {
      shortcut: 'h',
      description: 'Web server listen host'
    },
    'port': {
      shortcut: 'p',
      type: 'integer',
      description: 'Web server listen port'
    }
  }
});
// Print help
console.log(command.help());
// Extract command arguments
// Note, if the argument array is undefined, it default to `process.argv`
// and is similar to running the command
// `node samples/commands.js --host 127.0.0.1 -p '80'`
// from the project home directory
command.parse(
  ['--host', '127.0.0.1', '-p', '80']
).should.eql({
  host: '127.0.0.1',
  port: 80
});
// Create a command
command.compile({
  host: '127.0.0.1',
  port: 80
}).should.eql(
  ['--host', '127.0.0.1', '--port', '80']
);
