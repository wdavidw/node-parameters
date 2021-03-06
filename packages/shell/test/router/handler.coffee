
fs = require('fs').promises
os = require 'os'
shell = require '../../src'
  
describe 'router.handler', ->
    
  it 'context is parameter instance', ->
    shell
      handler: ->
        @should.have.property('help').which.is.a.Function()
        @should.have.property('parse').which.is.a.Function()
        @should.have.property('compile').which.is.a.Function()
    .route []

  it 'propagate error', ->
    (->
      shell
        options:
          'my_argument': {}
        handler: -> throw Error 'catch me'
      .route ['--my_argument', 'my value']
    ).should.throw 'catch me'
    
  it 'load with custom function handler', ->
    await fs.writeFile "#{os.tmpdir()}/renamed_module.coffee", 'module.exports = -> "Hello"'
    shell
      handler: './something'
      load: (module) ->
        require "#{os.tmpdir()}/renamed_module.coffee" if module is './something'
    .route []
    .should.eql 'Hello'
    await fs.unlink "#{os.tmpdir()}/renamed_module.coffee"
  
  describe 'arguments', ->
    
    it 'pass a single info argument by default', ->
      shell
        options:
          'my_argument': {}
        handler: (context) ->
          Object.keys(context).sort().should.eql ['args', 'argv', 'command', 'error', 'params', 'stderr', 'stderr_end', 'stdin', 'stdout', 'stdout_end']
          arguments.length.should.eql 1
      .route ['--my_argument', 'my value']

    it 'pass user arguments', (next) ->
      shell
        options:
          'my_argument': {}
        handler: (context, my_param, callback) ->
          my_param.should.eql 'my value'
          callback.should.be.a.Function()
          callback null, 'something'
      .route ['--my_argument', 'my value'], 'my value', (err, value) ->
        value.should.eql 'something'
        next()

  describe 'returned value', ->

    it 'inside an application', ->
      shell
        handler: ({params}) -> params.my_argument
        options:
          'my_argument': {}
      .route ['--my_argument', 'my value']
      .should.eql 'my value'

    it 'inside a command', ->
      shell
        commands: 'my_command':
          handler: ({params}) -> params.my_argument
          options:
            'my_argument': {}
      .route ['my_command', '--my_argument', 'my value']
      .should.eql 'my value'
