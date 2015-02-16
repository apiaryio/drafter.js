module.exports =

  # Copy all member types from one data structure to another
  #
  # @param dataStructure [Object] The super type data structure
  # @param memberTypeSection [Object] Member Type Section to be copied into
  copyMembers: (dataStructure, memberTypeSection) ->
    return if not dataStructure

    for section in dataStructure.sections
      if section['class'] is 'memberType'

        for member in section.content
          memberTypeSection.content.push member
