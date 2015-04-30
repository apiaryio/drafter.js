{assert} = require 'chai'
fs = require 'fs'

Drafter = require '../../src/drafter'

singleMember = (obj, type) ->
  assert.equal obj.sections.length, 1
  assert.equal obj.sections[0].class, 'memberType'
  assert.equal obj.sections[0].content.length, 1
  assert.equal obj.sections[0].content[0].class, type

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
      assert.isUndefined result
      done()

  it 'parses correctly when super type of a type in action attributes is not found', (done) ->
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
      assert.isUndefined result
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

  it 'parses correctly when resource has no name but has attributes', (done) ->
    drafter = new Drafter

    blueprint = '''
    # /

    + Attributes
      + id
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast
      done()

  it 'implicitly resolves base type to an object', (done) ->
    drafter = new Drafter

    blueprint = '''
    # Root [/]
    ## Retrieve the Entry Point [GET]
    + Response 200 (application/json)
        + Attributes
            + Properties
                + hello: 42 (string)
                + nested (Question)

    ## Group Question
    ## Question [/questions/{question_id}]
    + Attributes
        + question
        + url
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast

      assert.equal result.ast.content[1].content[0].element, 'resource'

      dataStructure = result.ast.content[1].content[0].content[0]

      assert.equal dataStructure.element, 'dataStructure'
      assert.equal dataStructure.name.literal, 'Question'
      assert.isNull dataStructure.typeDefinition.typeSpecification.name

      dataStructure = result.ast.content[1].content[0].content[1]

      assert.equal dataStructure.element, 'resolvedDataStructure'
      assert.equal dataStructure.name.literal, 'Question'
      assert.equal dataStructure.typeDefinition.typeSpecification.name, 'object'

      done()

  it 'correctly reconstructs resource groups', (done) ->
    drafter = new Drafter

    blueprint = '''
    ## Group A
    This is a testing group without any data
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast

      assert.equal result.ast.resourceGroups.length, 1

      done()

  it 'correctly expands the references in nested members of nested members', (done) ->
    drafter = new Drafter

    blueprint = '''
    # GET /
    + Response 200 (application/json)
        + Attributes
            + b
                + c (X)

    # Data Structures
    ## X
    + id: pavan
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast

      assert.equal result.ast.resourceGroups.length, 1
      assert.equal result.ast.resourceGroups[0].resources.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions[0].examples.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions[0].examples[0].responses.length, 1

      response = result.ast.resourceGroups[0].resources[0].actions[0].examples[0].responses[0]
      assert.equal response.body, '{"b":{"c":{"id":"pavan"}}}'

      done()

  it 'correctly expands the mixins in nested members of nested members', (done) ->
    drafter = new Drafter

    blueprint = '''
    # GET /
    + Response 200 (application/json)
        + Attributes
            + b
                + c
                    + Include X

    # Data Structures
    ## X
    + id: pavan
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast

      assert.equal result.ast.resourceGroups.length, 1
      assert.equal result.ast.resourceGroups[0].resources.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions[0].examples.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions[0].examples[0].responses.length, 1

      response = result.ast.resourceGroups[0].resources[0].actions[0].examples[0].responses[0]
      assert.equal response.body, '{"b":{"c":{"id":"pavan"}}}'

      done()

  it 'correctly expands named type when it is nested type for a member type', (done) ->
    drafter = new Drafter

    blueprint = '''
    # GET /

    + Response 200 (application/json)
        + Attributes
            + a (array[X])

    # Data Structures
    ## X
    + id: pavan
    '''

    drafter.make blueprint, (error, result) ->
      assert.isNull error
      assert.ok result.ast

      assert.equal result.ast.resourceGroups.length, 1
      assert.equal result.ast.resourceGroups[0].resources.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions[0].examples.length, 1
      assert.equal result.ast.resourceGroups[0].resources[0].actions[0].examples[0].responses.length, 1

      response = result.ast.resourceGroups[0].resources[0].actions[0].examples[0].responses[0]
      assert.equal response.body, '{"a":[{"id":"pavan"}]}'

      done()
