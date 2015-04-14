rule = require './rule'

module.exports =

  # Variables
  expanded: {}
  dataStructures: {}

  # Expand dataStructure element
  dataStructure: (element) ->
    superType = element.typeDefinition.name
    typeName = element.name

    if not typeName
      typeName =
        literal: ''

    @expandMixin typeName.literal, element
    delete @expanded['']

  # Given a list of elements, recursively expand mixins contained
  # in a group of elements inside the initial group of elements
  #
  # @param elements [Object] List of elements either from type section or a member type
  # @param sectionOrMember [Object] Type section or a member type
  diveIntoElements: (elements, sectionOrMember) ->
    for member in elements
      switch member['class']

        when 'mixin'
          superType = member.content.typeSpecification.name

          # Make sure the super type exists
          if typeof superType is 'object' and superType?.literal and @dataStructures[superType.literal]

            # Expand the super type first
            @expandMixin superType.literal, @dataStructures[superType.literal]
            rule.copyMembers @dataStructures[superType.literal], sectionOrMember

        when 'oneOf', 'group'
          memberType =
            content: []

          # Recursively dive into the elements
          @diveIntoElements member.content, memberType

          # Replace the original member with out new member
          member.content = memberType.content
          sectionOrMember.content.push member

        else
          sectionOrMember.content.push member

  # Given a data structure, expand its mixins recusrively
  #
  # @param name [String] Name of the data structure
  # @param dataStructure [Object] Data structure
  expandMixin: (name, dataStructure) ->
    return if @expanded[name]

    # Check for mixin
    for section in dataStructure.sections
      if section['class'] is 'memberType' and section.content?

        # New content for the section
        memberTypeSection =
          content: []

        @diveIntoElements section.content, memberTypeSection

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
