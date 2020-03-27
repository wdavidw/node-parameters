
var parameters = require('..');
require('should');

// NAME
//     server - Manage a web server
// SYNOPSIS
//     server command [options...]
//     where command is one of
//       start             Start a web server
//       help              Display help information about server
// DESCRIPTION
//     start               Start a web server
//       -h --host           Web server listen host
//       -p --port           Web server listen port
//     help                Display help information about server
//       name                Help about a specific command
// EXAMPLES
//     server help       Show this message

const command = parameters({
  name: 'server',
  description: 'Manage a web server',
  commands: {
    'start': {
      description: 'Start a web server',
      options: {
        'host': {
          shortcut: 'h', 
          description: 'Web server listen host'
        },
        'port': {
          shortcut: 'p', type: 'integer', 
          description: 'Web server listen port'
        }
      }
    }
  }
});
// Print help
console.log( command.help() );
// Extract command arguments
// Note, if the argument array is undefined, it default to `process.argv`
// and is similar to running the command
// `node samples/commands.js start --host 127.0.0.1 -p '80'`
// from the project home directory
command.parse(
  ['start', '--host', '127.0.0.1', '-p', '80']
).should.eql({
  command: ['start'],
  host: '127.0.0.1',
  port: 80
});
// Create a command
command.compile({
  command: ['start'],
  host: '127.0.0.1',
  port: 80
}).should.eql(
  ['start', '--host', '127.0.0.1', '--port', '80']
);
// Make an argument string
command.stringify({
  command: ['start'],
  host: '127.0.0.1',
  port: 80
}).should.eql(
  'start --host 127.0.0.1 --port 80'
);
