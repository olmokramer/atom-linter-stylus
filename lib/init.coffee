{resolve} = require 'path'

module.exports =
  config:
    stylusPath:
      type: 'string'
      default: resolve __dirname, '..', 'node_modules', 'stylus'

  activate: ->
    console.log 'activate linter-stylus'
