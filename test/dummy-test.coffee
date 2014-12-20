require 'mocha'
{assert} = require 'chai'

drafter = require '../index'


describe "Drafter", ->

  before (next) =>
    drafter.parse '# My API', (err, result) =>
      @result = result
      next err

  it "can parse", =>
    assert.ok @result.ast
