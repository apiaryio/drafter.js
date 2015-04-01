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

  it 'parses correctly when super type of a member is not found', (done) ->
    drafter = new Drafter

    blueprint = '''
    # Polls [/]

    + Attributes
        + owner (Person)
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast
      done()

  it 'parses correctly when super type of a type is not found', (done) ->
    drafter = new Drafter

    blueprint = '''
    # Polls [/]
    ## Get a Poll [GET]

    + Attributes (Person)
        + id
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast
      done()

  it 'parses correctly when named type in a mixin is not found', (done) ->
    drafter = new Drafter

    blueprint = '''
    # Polls [/]

    + Attributes
        + Include Person
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast
      done()

  it 'parses correctly when named type in a mixin is a primitive type', (done) ->
    drafter = new Drafter

    blueprint = '''
    # Polls [/]

    + Attributes
        + Include string
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast
      done()
