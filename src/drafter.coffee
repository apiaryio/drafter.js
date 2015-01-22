protagonist = require 'protagonist-experimental'
options = require './options'
fs = require 'fs'

class Drafter

  # Run the build, processing the blueprint on input and print it to the stdout
  run: (blueprintPath, callback) ->

    fs.readFile blueprintPath, 'utf8', (error, source) =>
      return callback(error) if error

      @make source, (error, result) ->
        return callback(error) if error

        console.log JSON.stringify result, null, 2
        callback()

  # Parse & process the input source file
  make: (source, callback) ->
    protagonist.parse source, callback

module.exports = Drafter
module.exports.options = options
