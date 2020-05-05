cmake_minimum_required(VERSION 3.6 FATAL_ERROR)
project(DrafterJsProjects)

set(CMAKE_PREFIX_PATH "/prefix")
set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY TRUE)
set(as_subproject
    Drafter
    DrafterJs)

macro(find_package)
    if(NOT "${ARGV0}" IN_LIST as_subproject)
        _find_package(${ARGV})
    endif()
endmacro()

# add external dependencies living in `ext`
add_subdirectory(ext/protagonist/drafter EXCLUDE_FROM_ALL)

# drafter.js
add_subdirectory(src)
