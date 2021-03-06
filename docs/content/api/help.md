---
title: API method `help`
navtitle: help
description: How to use the `help` method to print help to the user console.
keywords: ['shell', 'node.js', 'cli', 'api', 'help', 'print']
maturity: review
---

# Method `help(commands, options)`

Format the configuration into a readable documentation string.

* `commands` ([string] | string)   
  The string or array containing the command name if any, optional.
* `options.extended` (boolean)   
  Print the child command descriptions, default is `false`.
* `options.indent` (string)   
  Indentation used with output help, default to 2 spaces.

All options are optional.

It returns the formatted help to be printed as a string.

## Description

Without any argument, the `help` method returns the application help without the specific documentation of each commands. With the command name, it returns the help of the requested command as well as the options of the application and any parent commands.

Calling `help` will always return a string, it does not detect if help was requested by the user for display. To achieve this behaviour, it is expected to be used conjointly with [`helping`](/api/helping/), see the [the help usage documentation](/usage/help/) for additional information.

## Examples

Considering a "server" application containing a "start" command and initialized with the following configuration:

```js
const shell = require('shell')
const app = shell({
  name: 'server',
  description: 'Manage a web server',
  commands: {
    'start': {
      description: 'Start a web server',
      options: {
        'host': {shortcut: 'h', description: 'Web server listen host'},
        'port': {shortcut: 'p', type: 'integer', description: 'Web server listen port'}
      }
    }
  }
});
```

To print the help of the overall application does not require any arguments. It behaves the same as calling the `help` method with an empty array.

```js
process.stdout.write( app.help() )
process.stdout.write( app.help( [] ) )
```

Pass the name of the command as an array to print the help of any nested command. It behaves the same as defining the command as a string.

```js
process.stdout.write( app.help( ['start'] ) );
process.stdout.write( app.help( 'start' ) );
```

## Implementation

### Argument `--help`

Internally, an empty configuration by default register the `help` option by default:

```js
const assert = require("assert")
const shell = require("shell")

assert.deepStrictEqual(
  shell({}).config.options
, {
    help: {
      name: 'help',
      shortcut: 'h',
      description: 'Display help information',
      type: 'boolean',
      help: true
} } )
```

The same apply to every commands:

```js
const assert = require("assert")
const shell = require("shell")

assert.deepStrictEqual(
  shell( {
    commands: { 'my_cmd': {} }
  }).config.commands.my_cmd.options
, {
    help: {
      name: 'help',
      shortcut: 'h',
      description: 'Display help information',
      type: 'boolean',
      help: true
} } )
```

### Command `help <commands...>`

Internally, an `help` command is registered if at least another command is defined:

```js
const assert = require("assert")
const shell = require("shell")

assert.deepStrictEqual(
  shell({
    commands: [ { name: 'secret' } ]
  }).config.commands.help
, {
    name: 'help',
    description: 'Display help information about myapp',
    main: {
      name: 'name', description: 'Help about a specific command' 
    },
    help: true,
    strict: false,
    shortcuts: {},
    command: 'command',
    options: {},
    commands: {}
} )
```
