
parameters = require '../src'

describe 'plugin.config.commands', ->
  
  describe 'get', ->
        
    it 'get a child command', ->
      parameters
        options: 'config': {}
        commands: 'server': commands: 'start': {}
      .confx().commands('server').get()
      .command.should.eql ['server']
      
    it 'get a deep child command', ->
      parameters
        options: 'config': {}
        commands: 'server': commands: 'start': {}
      .confx().commands(['server', 'start']).get()
      .command.should.eql ['server', 'start']
    
    it 'traverse commands', ->
      parameters
        options: 'config': {}
        commands: 'server': commands: 'start': {}
      .confx().commands('server').commands('start').get()
      .command.should.eql ['server', 'start']
  
  describe 'set', ->
      
    it 'exepect 1 or 2 arguments', ->
      (->
        parameters
          options: 'config': {}
          commands: 'server': commands: 'start': {}
        .confx().commands('server').commands('stop')
        .set()
      ).should.throw 'Invalid Commands Set Arguments: expect 1 or 2 arguments, got 0'
      
    it 'an object', ->
      config = parameters
        options: 'config': {}
        commands: 'server': commands: 'start': {}
      .confx().commands('server').commands('stop')
      .set(
        route: 'path/to/route'
        options: 'force': {}
      )
      .get()
      config.route.should.eql 'path/to/route'
      config.options.force.should.eql
        name: 'force'
        type: 'string'
            
    it 'key values', ->
      config = parameters
        options: 'config': {}
        commands: 'server': commands: 'start': {}
      .confx().commands('server').commands('stop')
      .set('route', 'path/to/route')
      .set('options', 'force': {})
      .get()
      config.route.should.eql 'path/to/route'
      config.options.force.should.eql
        name: 'force'
        type: 'string'
      
    it 'call the hook', ->
      parameters {}
      .register
        'configure_commands_set': ({config, command, values}, handler) ->
          config.test = 'was here'
          handler
      .confx().commands('start').set
        route: 'path/to/route'
      .get().test.should.eql 'was here'