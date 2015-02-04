protagonist = require 'protagonist-experimental'
options = require './options'
fs = require 'fs'

#
# Drafter
#
class Drafter

  # List of data structures
  @dataStructures: []

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
    protagonist.parse source, @config, (error, result) =>
      callback error if error

      ruleList = []
      rules = (require './rules/' + rule for rule in ruleList)

      @dataStructures = []

      @expandNode result.ast, rules, 'blueprint'
      callback error, result

  # Expand a certain node with the given rules
  #
  # @param node [Object] A node of API Blueprint
  # @param rules [Array] List of rules to apply
  # @param elementTye [String] The element type of the node
  expandNode: (node, rules, elementType) ->
    elementType ?= node.element

    # On root node, Gather data structures first before applying rules to any of the children nodes
    if elementType is 'blueprint'
      for element in node.content

        if element.element is 'category'
          for subElement in element.content
            @dataStructures.push subElement if subElement.element is 'dataStructure'

      # Expand the gathered data structures
      for rule in rules
        rule.dataStructures.call @dataStructures if 'dataStructures' in rule

    # Apply rules to the current node
    for rule in rules
      rule[elementType].call node, @dataStructures if elementType in rule

    # Recursively do the same for children nodes
    switch elementType
      when 'resource'
        @expandNode action, rules, 'action' for action in node.actions

      when 'action'
        @expandNode example, rules, 'transactionExample' for example in node.examples

      when 'transactionExample'
        @expandNode request, rules, 'payload' for request in node.requests
        @expandNode response, rules, 'payload' for response in node.responses

    if node.content and Array.isArray node.content
      @expandNode element, rules for element in node.content

module.exports = Drafter
module.exports.options = options
