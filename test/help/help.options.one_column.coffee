
parameters = require '../../src'

describe 'help/help.options.one_column', ->

  it 'is `true`', ->
    parameters
      main: 'a_main'
      options:
        'debug':
          type: 'boolean'
    .help([], one_column: true).should.eql """

    NAME
      myapp
      No description yet

    SYNOPSIS
      myapp [myapp options] {a_main}

    OPTIONS
      --debug
      No description yet for the debug option.
      -h
      --help
      Display help information
      a_main
      No description yet for the a_main option.
    
    EXAMPLES
      myapp --help
      Show this message

    """
