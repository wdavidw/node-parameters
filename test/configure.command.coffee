
parameters = require '../src'

describe 'configure.command', ->
  
  describe 'validation', ->
    
    it 'only at application level', ->
      (->
        app = parameters
          commands: [
            name: 'server'
            command: 'invalid'
            commands: [
              name: 'start'
            ]
          ]
      ).should.throw 'Invalid Command Configuration: command property can only be declared at the application level, not inside a command, got invalid'
      
