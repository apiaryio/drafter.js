rule = require './rule'

module.exports =

  # Variables
  expanded: {}
  dataStructures: {}

  # Given a list of elements, recursively expand member type name contained
  # in a group of elements inside the initial group of elements
  #
  # @param elements [Object] List of elements either from type section or a member type
  diveIntoElements: (elements) ->
    for member in elements
      switch member['class']

        when 'property', 'value'
          superType = member.content.valueDefinition.typeDefinition.typeSpecification.name

          # If super type is a valid symbol
          if typeof superType is 'object' and superType?.literal
            @expandMember superType.literal, @dataStructures[superType.literal]

            superTypeBaseName = @dataStructures[superType.literal].typeDefinition.typeSpecification.name
            member.content.valueDefinition.typeDefinition.typeSpecification.name = superTypeBaseName

            # If super type is not an object or array or enum
            if superTypeBaseName in ['object', 'array', 'value']
              memberTypeSection =
                content: []

              memberTypeSection['class'] = 'memberType'
              rule.copyMembers @dataStructures[superType.literal], memberTypeSection
              member.content.sections.push memberTypeSection if memberTypeSection.content.length

        when 'oneOf', 'group'
          @diveIntoElements member.content

  # Given a data structure, expand its member type recusrively
  #
  # @param name [String] Name of the data structure
  # @param dataStructure [Object] Data structure
  expandMember: (name, dataStructure) ->
    return if @expanded[name]

    # Check for member type name
    for section in dataStructure.sections
      if section['class'] is 'memberType'

        @diveIntoElements section.content

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
