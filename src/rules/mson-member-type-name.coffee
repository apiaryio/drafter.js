rule = require './rule'

module.exports =

  # Variables
  expanded: {}
  dataStructures: {}

  # Given a data structure, expand its member type recusrively
  #
  # @param name [String] Name of the data structure
  # @param dataStructure [Object] Data structure
  expandMember: (name, dataStructure) ->
    return if @expanded[name]

    # Denote this type as expanded
    @expanded[name] = true

  init: (dataStructures) ->
    @expanded = {}
    @dataStructures = dataStructures

    # Initiate flags
    for name, dataStructure of @dataStructures
      @expanded[name] = false

    # Actual expansion
    for name, dataStructure of @dataStructures
      @expandMember name, dataStructure
