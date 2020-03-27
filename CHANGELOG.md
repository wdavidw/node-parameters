
# Changelog

## Version 0.7.3

* docs: typos

## Version 0.7.2

* package: update author url

## Version 0.7.1

* options: enforce literal object

## Version 0.7.0

Backward incompatibilities
* help: remove help command inject in non leaf commands
* parse: dont accept string command, only [string] and process
* commands: only accept objects, no arrays
* options: only accept objects, no arrays
* compile: rename stringify method to compile

New functionality
* stringify: new method, convert a parameters object to an arguments string
* options: new disabled property
* help: new plugin
* help: sort options
* router: accept a context object
* router: rename root property help to router
* router: new router_call hook
* hook: return value from handler
* hook: configure_app_set hook
* hook: configure_commands_set hook
* hook: new plugin/hook system
* config: dsl api plugin
* project: plugin architecture

Fix and improvements
* configure: persist name collision store

## Version 0.6.0

New functionality
* router: redirect error to help route
* router: handle help options and commands

Fix and improvements
* configure: immutable input
* project: normalise error messages
* options: fix collision detection for sibling commands
* shortcut: no need to test in strict mode

## Version 0.5.0

Breaking compatibility
* run: 1st arg as info with params and extended
* help: only accept a command, no params
* route: rename run method and configuration to route
* helping: only accept params, no more argv

New functionality
* extended: parse and stringify without merging
* main: string declaration shortcut
* parse: main as an array
* stringify: main from an array

Fix and improvements
* configure: isolate into its own method
* options: prevent collisions in flatten mode
* help: new extended option
* helping: complete re-implementation
* stringify: check 2nd argument
* help: new sample
* help: remove info per command
* parse: new extended option
* parse: improve arguments validation
* command: only declared at application level

Management
* license: switch to MIT license
* package: use mixme
* package: use file instead of npm ignore
* package: latest package dependencies

## Version 0.4.4

* one_of: handle optional params
* lib: move load & merge to utils
* readme: add author company
* package: relative paths

## Version 0.4.3

* help: accept array as first argument
* src: fix error thrown as string instead of object

## Version 0.4.2

* help: overwrittable by user

## Version 0.4.1

* help: handle shortcut
* shortcut: improve err message
* config: root property for internal use

## Version 0.4.0

* run: route help options and command
* src: convert to literate coffee
* helping: new function
* help: new revisited format supporting nested commands
* commands: unlimited nested dimensions
* doc: improve run description
* run: user arguments as last arguments, new extended option

## Version 0.3.0

* help: default app name and description
* config: options and commands as objects literals

## Version 0.2.2

* load: custom user module loader

## Version 0.2.1

* commands: default to help fixed on presence of options
* run: error handling for humans

## Version 0.2.0

* package: release commands
* package: update Node.js version inside Travis
* parse: better error handling
* options: new default option
* test: should required by mocha
* help: fix shortcut in commands
* options: run get context, argv and config
* options: run options accepts a function or a module
* readme: API documentation
* package: upgrade to CoffeeScript 2
