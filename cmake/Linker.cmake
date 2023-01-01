option(ENABLE_USER_LINKER "Enable a specific linker if available" OFF)

include(CheckCXXCompilerFlag)

set(USER_LINKER_OPTION
    "lld"
    CACHE STRING "Linker to be used")
set(USER_LINKER_OPTION_VALUES "lld" "gold" "bfd" "mold")
set_property(CACHE USER_LINKER_OPTION PROPERTY STRINGS ${USER_LINKER_OPTION_VALUES})
list(
    FIND
    USER_LINKER_OPTION_VALUES
    ${USER_LINKER_OPTION}
    USER_LINKER_OPTION_INDEX)

if(${USER_LINKER_OPTION_INDEX} EQUAL -1)
    message(
        STATUS
        "Using custom linker: '${USER_LINKER_OPTION}', explicitly supported entries are ${USER_LINKER_OPTION_VALUES}")
endif()

function(configure_linker project_name)
    if(NOT ENABLE_USER_LINKER)
        return()
    endif()

    set(LINKER_FLAG "-fuse-ld=${USER_LINKER_OPTION}")

    # Check if the compiler supports the user linker
    check_cxx_compiler_flag("${LINKER_FLAG}" CXX_SUPPORTS_USER_LINKER)

    # Only set the linker if the compiler supports it
    if(CXX_SUPPORTS_USER_LINKER)
        target_link_libraries(${project_name} INTERFACE ${LINKER_FLAG})
    endif()
endfunction()

