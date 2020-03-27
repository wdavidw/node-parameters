
parameters = require '../../src'

describe 'api.stringify', ->

  it 'should convert a parameters object to an arguments string', ->
    parameters
      commands: 'start':
        options: 'myparam': {}
    .stringify
      command: 'start'
      myparam: 'value'
    .should.eql 'start --myparam value'

  it 'should convert with node path and executed script', ->
    parameters
      commands: 'start' : {}
    .stringify
      command: 'start'
    ,
      script: './bin/myscript'
    .should.eql process.execPath + ' ./bin/myscript start'

  it 'should convert in extended mode', ->
    parameters
      extended: true
      options: 'myparam': {}
      commands: 'start':
        options: 'myparam': {}
    .stringify [
          myparam: 'value'
        ,
          command: 'start'
          myparam: 'value'
      ]
    .should.eql '--myparam value start --myparam value'

  it 'should escape bash characters of only parameters object', ->
    parameters
      options: 'myparam': {}
    .stringify
      myparam: '\\^$*+?()|[\]{}]'
    ,
      script: './bin/myscript'
    .should.eql process.execPath + ' ./bin/myscript --myparam \\\\\\^\\$\\*\\+\\?\\(\\)\\|\\[\\]\\{\\}\\]'

  it 'does not lose the context', ->
    parameters
      commands: 'start':
        main: 'leftover'
    .stringify
      command: 'start'
      leftover: ['my value', 'here']
    .should.eql 'start "my value" here'
