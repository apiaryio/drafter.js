protagonist = require 'protagonist-experimental'
options = require './options'
fs = require 'fs'

#
# Drafter
#
class Drafter

  # Default configuration
  @defaultConfig:
    requireBlueprintName: false # Treat missing API name as error
    exportSourcemap: false      # Generate source map

  # Ctor
  #
  # @param config [Object] configuration of the parser (see Drafter.defaultConfig)
  constructor: (@config) ->
    @config = Drafter.defaultConfig if !@config

  # Run the build
  #   processing the blueprint on input and print it to the stdout
  #
  # @param blueprintPath [String] path to the source API Blueprint
  # @param callback [(Error)]
  run: (blueprintPath, callback) ->

    fs.readFile blueprintPath, 'utf8', (error, source) =>
      return callback(error) if error

      @make source, (error, result) ->
        return callback(error) if error

        console.log JSON.stringify result, null, 2
        callback()

  # Parse & process the input source file
  #
  # @param source [String] soruce API Bluerpint code
  # @param callback [(Error, ParseResult)]
  make: (source, callback) ->
    protagonist.parse source, @config, callback

module.exports = Drafter
module.exports.options = options
