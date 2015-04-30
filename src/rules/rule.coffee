module.exports =

  # Copy all member types from one data structure to another
  #
  # @param dataStructure [Object] The super type data structure
  # @param content [Object] Content of Member Type Section to be copied into
  copyMembers: (dataStructure, content) ->
    return if not dataStructure or not content

    for section in dataStructure.sections
      if section['class'] is 'memberType' and section.content?

        for member in section.content
          content.push member
