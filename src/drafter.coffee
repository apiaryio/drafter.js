protagonist = require 'protagonist'
boutique = require 'boutique'
options = require './options'
fs = require 'fs'
async = require 'async'
deepcopy = require 'deepcopy'
deepEqual = require 'deep-equal'

# Gather all payloads from the given parse result
#
# @param result [Object] Parse Result
gatherPayloads = (result) ->
  payloads = []

  for element in result.ast.content
    if element.element is 'category'

      for subElement in element.content
        if subElement.element is 'resource'

          for action in subElement.actions
            attributes = null
            resolvedAttributes = null

            for actionElement in action.content
              attributes = actionElement if actionElement.element is 'dataStructure'
              resolvedAttributes = actionElement if actionElement.element is 'resolvedDataStructure'

            resolvedAttributes ?= attributes

            for example in action.examples
              payloads.push {payload: request, actionAttributes: resolvedAttributes} for request in example.requests
              payloads.push {payload: response, actionAttributes: resolvedAttributes} for response in example.responses

  return payloads

# Generate payload body if MSON is provided and no body
#
# @param payload [Object] Payload object
# @param attributes [Object] Payload attributes object
# @param contentType [Object] Payload content type
generateBody = (payload, attributes, contentType, callback) ->
  if not attributes? or not contentType? or payload.body
    return callback null, payload, attributes, contentType

  boutique.represent
    ast: attributes,
    contentType: contentType
  , (error, body) ->
    if not error? and body
      resolved =
        element: 'resolvedAsset'
        attributes:
          role: 'bodyExample'
        content: body

      payload.content.push resolved
      payload.body = body

    # For waterfall
    callback null, payload, attributes, contentType

# Generate payload schema if MSON is provided and no schema and ContentType is json
#
# @param payload [Object] Payload object
# @param attributes [Object] Payload attributes object
# @param contentType [Object] Payload content type
generateSchema = (payload, attributes, contentType, callback) ->
  if not attributes? or payload.schema or contentType.indexOf('json') is -1
    return callback null, payload, attributes, contentType

  boutique.represent
    ast: attributes,
    contentType: 'application/schema+json'
  , (error, body) ->
    if not error? and body
      resolved =
        element: 'resolvedAsset'
        attributes:
          role: 'bodySchema'
        content: body

      payload.content.push resolved
      payload.schema = body

    # For waterfall
    callback null, payload, attributes, contentType

#
# Drafter
#
class Drafter

  # List of data structures
  @dataStructures: {}
  @origDataStructures: {}

  # References denoting where to append the resolved data structures
  @appendResolved: {}

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
      return callback error if error

      ruleList = ['mson-inheritance', 'mson-mixin', 'mson-member-type-name']
      rules = (require './rules/' + rule for rule in ruleList)

      @dataStructures = {}
      @origDataStructures = {}
      @appendResolved = {}

      delete result.ast.resourceGroups

      @expandNode result.ast, rules, 'blueprint'
      payloads = gatherPayloads result

      async.each payloads, @resolvePayload, (error) =>
        @reconstructResourceGroups result.ast
        callback error or null, result

  # Resolve assets of a payload
  resolvePayload: ({payload, actionAttributes}, callback) ->
    attributes = null
    resolvedAttributes = null
    contentType = ''

    for header in payload.headers
      contentType = header.value if header.name is 'Content-Type'

    for element in payload.content
      attributes = element if element.element is 'dataStructure'
      resolvedAttributes = element if element.element is 'resolvedDataStructure'

    resolvedAttributes ?= attributes
    resolvedAttributes ?= actionAttributes

    async.waterfall [
      (cb) ->
        cb null, payload, resolvedAttributes, contentType
      , generateBody
      , generateSchema
    ], (error) ->
      callback error or null

  # Expand a certain node with the given rules
  #
  # @param node [Object] A node of API Blueprint
  # @param rules [Array] List of rules to apply
  # @param elementTye [String] The element type of the node
  # @param parentContent [Object] Parent node's content of which the current node is a part of
  # @param parentElementType [String] The element type of the parent node
  expandNode: (node, rules, elementType, parentContent, parentElementType) ->
    elementType ?= node.element

    # On root node, Gather data structures first before applying rules to any of the children nodes
    if elementType is 'blueprint'
      for element in node.content

        if element.element is 'category'
          for subElement in element.content

            switch subElement.element
              when 'dataStructure'
                @dataStructures[subElement.name.literal] = deepcopy subElement
                @origDataStructures[subElement.name.literal] = subElement
                @appendResolved[subElement.name.literal] = element.content
              when 'resource'
                for resourceSubElement in subElement.content
                  if resourceSubElement.element is 'dataStructure'

                    @dataStructures[resourceSubElement.name.literal] = deepcopy resourceSubElement
                    @origDataStructures[resourceSubElement.name.literal] = resourceSubElement
                    @appendResolved[resourceSubElement.name.literal] = subElement.content

      # Expand the gathered data structures
      for rule in rules
        rule.init.call rule, @dataStructures if rule.init

      # Append resolved data structures
      for name, dataStructure of @dataStructures
        if not deepEqual dataStructure, @origDataStructures[name]
          dataStructure.element = 'resolvedDataStructure'
          @appendResolved[name].push dataStructure

    # Don't expand data structures in place
    if elementType is 'dataStructure'
      newNode = deepcopy node
    else
      newNode = node

    # Apply rules to the current node
    for rule in rules
      rule[elementType].call rule, newNode if elementType in Object.keys(rule)

    # Append resolved data structures
    if parentElementType not in ['resource', 'blueprint'] and elementType is 'dataStructure' and not deepEqual node, newNode
      newNode.element = 'resolvedDataStructure'
      parentContent.push newNode

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
      @expandNode element, rules, null, node.content, elementType for element in node.content

  # Reconstruct deprecated resource groups key from elements
  #
  # @param ast [Object] Blueprint ast
  reconstructResourceGroups: (ast) ->
    ast.resourceGroups = []

    for element in ast.content
      if element.element is 'category'
        resources = []

        for subElement in element.content
          resources.push subElement if subElement.element is 'resource'

        if resources.length
          description = element.content[0].content if element.content[0].element is 'copy'

          ast.resourceGroups.push
            name: element.attributes?.name || ''
            description: description || ''
            resources: resources

module.exports = Drafter
module.exports.options = options
