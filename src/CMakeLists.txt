cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(DrafterJs VERSION 4.0 LANGUAGES CXX)

set(DrafterJs_COMPILE_FEATURES
    cxx_alias_templates
    cxx_alignas
    cxx_alignof
    cxx_attribute_deprecated
    cxx_auto_type
    cxx_constexpr
    cxx_contextual_conversions
    cxx_decltype
    cxx_decltype_auto
    cxx_defaulted_functions
    cxx_defaulted_move_initializers
    cxx_delegating_constructors
    cxx_deleted_functions
    cxx_digit_separators
    cxx_explicit_conversions
    cxx_final
    cxx_generalized_initializers
    cxx_generic_lambdas
    cxx_inheriting_constructors
    cxx_lambdas
    cxx_lambda_init_captures
    cxx_noexcept
    cxx_nonstatic_member_init
    cxx_nullptr
    cxx_override
    cxx_range_for
    cxx_raw_string_literals
    cxx_return_type_deduction
    cxx_rvalue_references
    cxx_sizeof_member
    cxx_static_assert
    cxx_strong_enums
    cxx_thread_local
    cxx_trailing_return_types
    cxx_unicode_literals
    cxx_uniform_initialization
    cxx_unrestricted_unions
    cxx_user_literals
    cxx_variable_templates
    cxx_variadic_macros
    cxx_variadic_templates
    cxx_template_template_parameters
    )

set(DrafterJs_EXPORTED_FUNCTIONS "['_drafter_init_parse_options', '_drafter_free_parse_options', '_drafter_set_name_required', '_drafter_set_skip_gen_bodies', '_drafter_set_skip_gen_body_schemas', '_drafter_init_serialize_options', '_drafter_free_serialize_options', '_drafter_set_sourcemaps_included', '_drafter_set_format', '_drafter_free_result', '_c_serialize_json_options', '_c_buffer_ptr', '_c_buffer_string', '_c_free_buffer_ptr', '_c_parse_to', '_c_validate_to']")
set(DrafterJs_EXPORTED_RUNTIME "['stringToUTF8', 'getValue', 'Pointer_stringify', 'lengthBytesUTF8', 'UTF8ToString']")
set(DrafterJs_PRE_JS "${CMAKE_CURRENT_LIST_DIR}/pre.js")
set(DrafterJs_POST_JS "${CMAKE_CURRENT_LIST_DIR}/post.js")

# production dependencies
find_package(Drafter 4.0 REQUIRED)

# mem
add_library(drafter-js cparse.cc)

target_link_libraries(drafter-js
    PRIVATE
        drafter::drafter
        "--pre-js ${DrafterJs_PRE_JS}"
        "--post-js ${DrafterJs_POST_JS}"
        "-s EXPORTED_FUNCTIONS=\"${DrafterJs_EXPORTED_FUNCTIONS}\""
        "-s DISABLE_EXCEPTION_CATCHING=0"
        "-s EXPORTED_RUNTIME_METHODS=\"${DrafterJs_EXPORTED_RUNTIME}\""
        #"-s ASSERTIONS=${ASSERT}"
        "-s DOUBLE_MODE=0"
        "-s ALLOW_MEMORY_GROWTH=1"
        "-s NO_EXIT_RUNTIME=1"
        "-s INVOKE_RUN=0"
        "-s INLINING_LIMIT=50"
        "-s NO_FILESYSTEM=1"
        "-s NODEJS_CATCH_EXIT=0"
        "-s ELIMINATE_DUPLICATE_FUNCTIONS=1"
        "-s AGGRESSIVE_VARIABLE_ELIMINATION=1"
        "-s WASM=0"
    )

target_include_directories(drafter-js PUBLIC
    $<BUILD_INTERFACE:${DrafterJs_BINARY_DIR}>
    $<BUILD_INTERFACE:${DrafterJs_SOURCE_DIR}>
    )

target_compile_features(drafter-js PUBLIC ${DrafterJs_COMPILE_FEATURES})

set_target_properties(drafter-js PROPERTIES OUTPUT_NAME drafter)

# nomem
add_library(drafter-nomem-js cparse.cc)

target_link_libraries(drafter-nomem-js
    PRIVATE
        drafter::drafter
        "--memory-init-file 0"
        "--pre-js ${DrafterJs_PRE_JS}"
        "--post-js ${DrafterJs_POST_JS}"
        "-s EXPORTED_FUNCTIONS=\"${DrafterJs_EXPORTED_FUNCTIONS}\""
        "-s DISABLE_EXCEPTION_CATCHING=0"
        "-s EXPORTED_RUNTIME_METHODS=\"${DrafterJs_EXPORTED_RUNTIME}\""
        #"-s ASSERTIONS=${ASSERT}"
        "-s DOUBLE_MODE=0"
        "-s ALLOW_MEMORY_GROWTH=1"
        "-s NO_EXIT_RUNTIME=1"
        "-s INVOKE_RUN=0"
        "-s INLINING_LIMIT=50"
        "-s NO_FILESYSTEM=1"
        "-s NODEJS_CATCH_EXIT=0"
        "-s ELIMINATE_DUPLICATE_FUNCTIONS=1"
        "-s AGGRESSIVE_VARIABLE_ELIMINATION=1"
        "-s WASM=0"
    )

target_include_directories(drafter-nomem-js PUBLIC
    $<BUILD_INTERFACE:${DrafterJs_BINARY_DIR}>
    $<BUILD_INTERFACE:${DrafterJs_SOURCE_DIR}>
    )

target_compile_features(drafter-nomem-js PUBLIC ${DrafterJs_COMPILE_FEATURES})

set_target_properties(drafter-nomem-js PROPERTIES OUTPUT_NAME drafter.nomem)

install(TARGETS drafter-js drafter-nomem-js EXPORT drafter-js-targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION lib
    FRAMEWORK DESTINATION lib
    BUNDLE DESTINATION lib
    PRIVATE_HEADER DESTINATION lib
    PUBLIC_HEADER DESTINATION lib
    RESOURCE DESTINATION lib
    )

install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/drafter.js.mem"
    DESTINATION
        lib
    )

