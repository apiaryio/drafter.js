rule = require './rule'

module.exports =

  # Variables
  expanded: {}
  dataStructures: {}

  # Given a data structure, expand its mixins recusrively
  #
  # @param name [String] Name of the data structure
  # @param dataStructure [Object] Data structure
  expandMixin: (name, dataStructure) ->
    return if @expanded[name]

    # Check for mixin
    for section in dataStructure.sections
      if section['class'] is 'memberType'

        # New content for the section
        memberTypeSection =
          content: []

        for member in section.content
          if member['class'] is 'mixin'

            # Expand the super type first
            superType = member.content.typeSpecification.name
            @expandMixin superType.literal, @dataStructures[superType.literal]

            rule.copyMembers @dataStructures[superType.literal], memberTypeSection

          else
            memberTypeSection.content.push member

        # Replace section content with the new content
        section.content = memberTypeSection.content

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
      @expandMixin name, dataStructure
