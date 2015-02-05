{assert} = require 'chai'
fs = require 'fs'

Drafter = require '../../src/drafter'

describe 'Drafter Class', ->

  it 'parses a bluerint', (done) ->
    drafter = new Drafter

    drafter.make '# My API', (error, result) ->
      assert.isNull error
      assert.ok result.ast
      done()

  it 'parses and expands a blueprint', (done) ->
    drafter = new Drafter

    drafter.make fs.readFileSync('./test/fixtures/dataStructures.apib', 'utf8'), (error, result) ->
      assert.isNull error
      assert.ok result.ast

      assert.deepEqual result.ast, require '../fixtures/dataStructures.ast.json'

      done()
