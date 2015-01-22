protagonist = require 'protagonist-experimental'

class Drafter

  # Parse & process the input source file
  make: (source, callback) ->
    protagonist.parse source, callback

module.exports = Drafter
