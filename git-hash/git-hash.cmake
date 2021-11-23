set(GIT_HASH "unknown")
# find Git and if available set GIT_HASH variable
find_package(Git QUIET)
if (GIT_FOUND)
    execute_process(
            COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
            OUTPUT_VARIABLE git-hash
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
    )
endif ()
message(STATUS "Git hash is ${GIT_HASH}")


# generate file version.hpp based on version.hpp.in
configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/git-hash.hpp.in
        ${TARGET_DIR}/generated/git-hash.hpp
        @ONLY
)