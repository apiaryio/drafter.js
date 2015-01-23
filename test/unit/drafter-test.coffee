{assert} = require 'chai'

Drafter = require '../../src/drafter'

describe 'Drafter Class', ->

  it 'parses a bluerint', (done) ->
    drafter = new Drafter

    drafter.make '# My API', (error, result) ->
      assert.isNull error
      assert.ok result.ast
      done()
