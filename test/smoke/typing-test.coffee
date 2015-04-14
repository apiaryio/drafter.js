{assert} = require 'chai'

fs = require 'fs'

Drafter = require '../../src/drafter'

KNOWN_PROBLEMATIC_LENGTHS = []

describe 'Typing test', ->
  blueprint = fs.readFileSync './test/fixtures/dataStructures.apib', 'utf8'
  drafter   = new Drafter

  describe 'When I type the blueprint', ->
    currentLength = 0

    # Because drafter.make uses protagonist.parse (asynchronous call),
    # we cannot call desribe directly within for loop. We need a closure or
    # otherwise currentLength won't be of value the one used when describe
    # was created, but with the final number (blueprint.length) instead.
    for currentLength in [1..(blueprint.length-1)] then do (currentLength) ->

      if currentLength in KNOWN_PROBLEMATIC_LENGTHS then return

      describe "and write first #{currentLength} characters and parse them", ->
        error = undefined
        exception = undefined
        result = undefined

        after ->
          error     = undefined
          exception = undefined
          result    = undefined

        before (done) ->
          try
            drafter.make blueprint.slice(0, currentLength), (err, res) ->
              error = err
              result = res
              done null

          catch exc
            exception = exc
            done null

        it 'I got no unplanned exception', ->
          assert.isUndefined exception

        it 'I properly-formatted error', ->
          if not error
            assert.isNull error

          else
            assert.isDefined error.code
            assert.isDefined error.message
            assert.isArray   error.location

        it 'I get proper result', ->
          if error
            # The node idom is to pass null, but drafter is passing undefined
            assert.isUndefined result
          else
            assert.ok      result.ast._version
            assert.ok      result.ast.content
            assert.isArray result.ast.resourceGroups
