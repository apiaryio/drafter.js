{assert} = require 'chai'

fs = require 'fs'

Drafter = require '../../src/drafter'

describe 'Typing test', ->
  blueprint = fs.readFileSync './test/fixtures/dataStructures.apib', 'utf8'
  drafter   = new Drafter

  describe 'When I type the blueprint', ->
    currentLength = 0
    error = undefined
    exception = undefined
    result = undefined

    while currentLength < blueprint.length
      currentLength++

      describe "and write first #{currentLength} characters and parse them", ->
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



      after ->
        error     = undefined
        exception = undefined
        result    = undefined
