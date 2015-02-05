module.exports =

  # Variables
  expanded: {}
  dataStructures: {}

  # Copy all member types from one data structure to another
  #
  # @param supertTypeName [String] The name of the super type data structure
  # @param memberTypeSection [Object] Member Type Section to be copied into
  copyMembers: (superTypeName, memberTypeSection) ->
    return if not @dataStructures[superTypeName]

    for section in @dataStructures[superTypeName].sections
      if section['class'] is 'memberType'

        for member in section.content
          memberTypeSection.content.push member if member['class'] in ['property', 'mixin']

  # Given a data structure, expand it's inheritance recursively
  #
  # @param name [String] Name of the data structure
  # @param dataStructure [Object] Data structure
  expandInheritance: (name, dataStructure) ->
    return if @expanded[name]

    # Check for inheritance
    superType = dataStructure.typeDefinition.typeSpecification.name

    if superType is null or typeof superType isnt 'object' or not superType?.literal
      return @expanded[superType] = true

    # Expand the super type first
    @expandInheritance superType, @dataStructures[superType.literal]

    # If super type is not an object or array or enum
    superTypeBaseName = @dataStructures[superType.literal].typeDefinition.typeSpecification.name

    if superTypeBaseName not in ['object', 'array', 'value']
      dataStructure.typeDefinition.typeSpecification.name = superTypeBaseName
      memberTypeSection =
        content: []

      memberTypeSection['class'] = 'memberType'
      @copyMembers superType.literal, memberTypeSection

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
    dataStructure.typeDefinition.typeSpecification.name = superTypeBaseName
    @copyMembers superType.literal, memberTypeSection

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
