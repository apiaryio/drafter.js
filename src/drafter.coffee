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

  # Constructor
  #
  # @param config [Object] configuration of the parser (see Drafter.defaultConfig)
  constructor: (@config) ->
    @config = Drafter.defaultConfig if !@config

  # Execute the make process using a file path
  #   this is just a convenience wrapper for @make
  #
  # @param blueprintPath [String] path to the source API Blueprint
  # @param callback [(Error, ParseResult))]
  makeFromPath: (blueprintPath, callback) ->

    fs.readFile blueprintPath, 'utf8', (error, source) =>
      return callback(error) if error

      @make source, callback

  # Parse & process the input source file
  #
  # @param source [String] soruce API Bluerpint code
  # @param callback [(Error, ParseResult)]
  make: (source, callback) ->
    protagonist.parse source, @config, callback

module.exports = Drafter
module.exports.options = options
