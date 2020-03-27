
## Plugin "args"

    # Dependencies
    error = require '../utils/error'
    {clone, is_object_literal, merge} = require 'mixme'
    # Parameters & plugins
    Parameters = require '../Parameters'

## Method `parse([arguments])`

Convert an arguments list to a parameters object.

* `arguments`: `[string] | process` The arguments to parse into parameters, accept the [Node.js process](https://nodejs.org/api/process.html) instance or an [argument list](https://nodejs.org/api/process.html#process_process_argv) provided as an array or a string, optional.
* `options`: `object` Options used to alter the behavior of the `compile` method.
  * `extended`: `boolean` The value `true` indicates that the parameters are returned in extended format, default to the configuration `extended` value which is `false` by default.
* Returns: `object | [object]` The extracted parameters, a literal object in default flatten mode or an array in extended mode.

    Parameters::parse = (argv = process, options={}) ->
      appconfig = @confx().get()
      options.extended ?= appconfig.extended
      index = 0
      # Remove node and script argv elements
      if argv is process
        index = 2
        argv = argv.argv
      else unless Array.isArray argv
        throw error [
          'Invalid Arguments:'
          'parse require arguments or process as first argument,'
          "got #{JSON.stringify process}"
        ]
      # Extracted parameters
      full_params = []
      parse = (config, command) ->
        full_params.push params = {}
        # Add command name provided by parent
        params[appconfig.command] = command if command?
        # Read options
        while true
          break if argv.length is index or argv[index][0] isnt '-'
          key = argv[index++]
          shortcut = key[1] isnt '-'
          key = key.substring (if shortcut then 1 else 2), key.length
          shortcut = key if shortcut
          key = config.shortcuts[shortcut] if shortcut
          option = config.options?[key]
          if not shortcut and config.strict and not option
            err = error [
              'Invalid Argument:'
              "the argument #{if shortcut then "-" else "--"}#{key} is not a valid option"
            ]
            err.command = full_params.slice(1).map (params) ->
              params[appconfig.command]
            throw err
          if shortcut and not option
            throw error [
              'Invalid Shortcut Argument:'
              "the \"-#{shortcut}\" argument is not a valid option"
              "in command \"#{config.command.join ' '}\"" if Array.isArray config.command
            ]
          # Auto discovery
          unless option
            type = if argv[index] and argv[index][0] isnt '-' then 'string' else 'boolean'
            option = name: key, type: type
          switch option.type
            when 'boolean'
              params[key] = true
            when 'string'
              value = argv[index++]
              throw error [
                'Invalid Option:'
                "no value found for option #{JSON.stringify key}"
              ] unless value? and value[0] isnt '-'
              params[key] = value
            when 'integer'
              value = argv[index++]
              throw error [
                'Invalid Option:'
                "no value found for option #{JSON.stringify key}"
              ] unless value? and value[0] isnt '-'
              params[key] = parseInt value, 10
            when 'array'
              value = argv[index++]
              throw error [
                'Invalid Option:'
                "no value found for option #{JSON.stringify key}"
              ] unless value? and value[0] isnt '-'
              params[key] ?= []
              params[key].push value.split(',')...
        # Check if help is requested
        # TODO: this doesnt seem right, also, the test in help.parse seems wrong as well
        helping = false
        for _, option of config.options
          continue unless option.help is true
          helping = true if params[option.name]
        return params if helping
        # Check against required options
        for _, option of config.options
          if option.required
            throw error [
              'Required Option Argument:'
              "the \"#{option.name}\" option must be provided"
            ] unless params[option.name]?
          if option.one_of
            values = params[option.name]
            if not option.required and values isnt undefined
              values = [values] unless Array.isArray values
              for value in values
                throw error [
                  'Invalid Argument Value:'
                  "the value of option \"#{option.name}\""
                  "must be one of #{JSON.stringify option.one_of},"
                  "got #{JSON.stringify value}"
                ] unless value in option.one_of
        # We still have some argument to parse
        if argv.length isnt index
          # Store the full command in the return array
          leftover = argv.slice(index)
          if config.main
            params[config.main.name] = leftover
          else
            command = argv[index++]
            # Validate the command
            throw error [
              'Invalid Argument:'
              "fail to interpret all arguments \"#{leftover.join ' '}\""
            ] unless config.commands[command]
            # Parse child configuration
            parse config.commands[command], command
        # NOTE: legacy versions used to inject an help command
        # when parsing arguments which doesnt hit a sub command
        # See the associated tests in "help/parse.coffee"
        # Happens with global options without a command
        # if Object.keys(config.commands).length and not command
        #   params[appconfig.command] = 'help'
        # Check against required main
        main = config.main
        if main and main.required
          throw error [
            'Required Main Argument:'
            "no suitable arguments for #{JSON.stringify main.name}"
          ] unless params[main.name]?
        params
      # Start the parser
      parse appconfig, null
      unless options.extended
        params = {}
        if Object.keys(appconfig.commands).length
          params[appconfig.command] = []
        for command_params in full_params
          for k, v of command_params
            if k is appconfig.command
              params[k].push v
            else
              params[k] = v
      else
        params = full_params
      # Enrich params with default values
      set_default appconfig, params
      params

## Method `compile(command, [options])`

Convert a parameters object to an arguments array.

* `params`: `object` The parameter object to be converted into an array of arguments, optional.
* `options`: `object` Options used to alter the behavior of the `compile` method.
  * `extended`: `boolean` The value `true` indicates that the parameters are provided in extended format, default to the configuration `extended` value which is `false` by default.
  * `script`: `string` The JavaScript file being executed by the engine, when present, the engine and the script names will prepend the returned arguments, optional, default is false.
* Returns: `array` The command line arguments.

    Parameters::compile = (params, options={}) ->
      argv = if options.script then [process.execPath, options.script] else []
      appconfig = @confx().get()
      options.extended ?= appconfig.extended
      throw error [
        'Invalid Compile Arguments:'
        '2nd argument option must be an object,'
        "got #{JSON.stringify options}"
      ] unless is_object_literal options
      keys = {}
      # In extended mode, the params array will be truncated
      # params = merge params unless extended
      set_default appconfig, params
      # Convert command parameter to a 1 element array if provided as a string
      params[appconfig.command] = [params[appconfig.command]] if typeof params[appconfig.command] is 'string'
      # Compile
      compile = (config, lparams) ->
        for _, option of config.options
          key = option.name
          keys[key] = true
          value = lparams[key]
          # Validate required value
          throw error [
            'Required Option Parameter:'
            "the \"#{key}\" option must be provided"
          ] if option.required and not value?
          # Validate value against option "one_of"
          if value? and option.one_of
            value = [value] unless Array.isArray value
            for val in value
              throw error [
                'Invalid Parameter Value:'
                "the value of option \"#{option.name}\""
                "must be one of #{JSON.stringify option.one_of},"
                "got #{JSON.stringify val}"
              ] unless val in option.one_of
          # Serialize
          if value then switch option.type
            when 'boolean'
              argv.push "--#{key}"
            when 'string', 'integer'
              argv.push "--#{key}"
              argv.push "#{value}"
            when 'array'
              argv.push "--#{key}"
              argv.push "#{value.join ','}"
        if config.main
          value = lparams[config.main.name]
          throw error [
            'Required Main Parameter:'
            "no suitable arguments for #{JSON.stringify config.main.name}"
          ] if config.main.required and not value?
          if value?
            throw error [
              'Invalid Parameter Type:'
              "expect main to be an array, got #{JSON.stringify value}"
            ] unless Array.isArray value
            keys[config.main.name] = value
            argv = argv.concat value
        # Recursive
        has_child_commands = if options.extended then params.length else Object.keys(config.commands).length
        if has_child_commands
          command = if options.extended then params[0][appconfig.command] else params[appconfig.command].shift()
          throw error [
            'Invalid Command Parameter:'
            "command #{JSON.stringify command} is not registed,"
            "expect one of #{JSON.stringify Object.keys(config.commands).sort()}"
            "in command #{JSON.stringify config.command.join ' '}" if Array.isArray config.command
          ] unless config.commands[command]
          argv.push command
          keys[appconfig.command] = command
          # Compile child configuration
          compile config.commands[command], if options.extended then params.shift() else lparams
        if options.extended or not has_child_commands
          # Handle params not defined in the configuration
          # Note, they are always pushed to the end and associated with the deepest child
          for key, value of lparams
            continue if keys[key]
            throw Error [
              'Invalid Parameter:'
              "the property --#{key} is not a registered argument"
            ].join ' ' if appconfig.strict
            if typeof value is 'boolean'
              argv.push "--#{key}" if value
            else if typeof value is 'undefined' or value is null
              # nothing
            else
              argv.push "--#{key}"
              argv.push "#{value}"
      compile appconfig, if options.extended then params.shift() else params
      argv
      
## Method `stringify(command, [options])`

Convert a parameters object to an arguments string.

* `params`: `object` The parameter object to be converted into an array of arguments, optional.
* `options`: `object` Options used to alter the behavior of the `compile` method.
  * `extended`: `boolean` The value `true` indicates that the parameters are provided in extended format, default to the configuration `extended` value which is `false` by default.
  * `script`: `string` The JavaScript file being executed by the engine, when present, the engine and the script names will prepend the returned arguments, optional, default is false.
* Returns: `string` The command line arguments.

    Parameters::stringify = (params, options={}) ->
      argv = ""
      compile = @compile params, options
      if options.script? 
        argv += compile.shift() + ' '
        argv += compile.shift() + ' '
      for arg in compile
        arg = escape arg
        if " " in arg
        then argv += '"' + arg + '"'
        else argv += arg
        argv += ' '
      argv.trim()

## Utils

Given a configuration, apply default values to the parameters

    set_default = (config, params, tempparams = null) ->
      tempparams = merge params unless tempparams?
      if Object.keys(config.commands).length
        command = tempparams[config.command]
        command = tempparams[config.command].shift() if Array.isArray command
        # We are not validating if the command is valid, it may not be set if help option is present
        # throw Error "Invalid Command: \"#{command}\"" unless config.commands[command]
        if config.commands[command]
          params = set_default config.commands[command], params, tempparams
      for _, option of config.options
        params[option.name] ?= option.default if option.default?
      params

Escape the bash characters

    escape = (string) -> 
      string.toString().replace /[\\^$*+?()|[\]{}]/g, "\\$&"
    
