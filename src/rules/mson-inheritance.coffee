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

    @expandInheritance typeName.literal, element
    delete @expanded['']

  # Given a data structure, expand its inheritance recursively
  #
  # @param name [String] Name of the data structure
  # @param dataStructure [Object] Data structure
  expandInheritance: (name, dataStructure) ->
    return if @expanded[name]

    # Check for inheritance
    superType = dataStructure.typeDefinition.typeSpecification.name

    # If super type is array and if it has nested type, append them as value members only if there are no value members
    if superType is 'array'
      nestedTypes = dataStructure.typeDefinition.typeSpecification.nestedTypes
      valueMembersExist = false

      for section in dataStructure.sections
        if section['class'] is 'memberType'
          valueMembersExist = true

      if not valueMembersExist and nestedTypes.length
        memberTypeSection =
          content: []

        memberTypeSection['class'] = 'memberType'

        for nestedType in nestedTypes
          valueMember =
            content:
              description: ''
              valueDefinition:
                values: []
                typeDefinition:
                  typeSpecification:
                    name: nestedType,
                    nestedTypes: []
                  attributes: []
              sections: []

          valueMember['class'] = 'value'
          memberTypeSection.content.push valueMember

        # Push the value members
        dataStructure.sections.push memberTypeSection
        dataStructure.typeDefinition.typeSpecification.nestedTypes = []

    # Make sure super type is valid
    if superType is null or typeof superType isnt 'object' or not superType?.literal or not @dataStructures[superType.literal]
      return @expanded[name] = true

    # Expand the super type first
    @expandInheritance superType.literal, @dataStructures[superType.literal]

    # If super type is not an object or array or enum
    superTypeBaseName = @dataStructures[superType.literal].typeDefinition.typeSpecification.name

    if superTypeBaseName not in ['object', 'array', 'value']
      dataStructure.typeDefinition.typeSpecification.name = superTypeBaseName
      memberTypeSection =
        content: []

      memberTypeSection['class'] = 'memberType'
      rule.copyMembers @dataStructures[superType.literal], memberTypeSection

      dataStructure.sections.push memberTypeSection if memberTypeSection.content.length
      return @expanded[name] = true

    # Find member type section of the current data structure
    memberTypeSection = null
    push = false

    for section in dataStructure.sections
      memberTypeSection = section if section['class'] is 'memberType'

    # If no member type sections, create one
    if not memberTypeSection
      memberTypeSection = 
        content: []

      memberTypeSection['class'] = 'memberType'
      push = true

    # Copy super-type and all the member types to sub type
    rule.copyMembers @dataStructures[superType.literal], memberTypeSection
    dataStructure.typeDefinition.typeSpecification =
      name: superTypeBaseName
      nestedTypes: @dataStructures[superType.literal].typeDefinition.typeSpecification.nestedTypes

    # Push the created type section
    dataStructure.sections.push memberTypeSection if push and memberTypeSection.content.length

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
      @expandInheritance name, dataStructure
