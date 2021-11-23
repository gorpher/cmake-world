add_executable(git-hash git-hash.cpp)

target_include_directories(git-hash
        PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/generated
        )

add_custom_command(
        OUTPUT
        ${CMAKE_CURRENT_BINARY_DIR}/generated/git-hash.hpp
        ALL
        COMMAND
        ${CMAKE_COMMAND} -D TARGET_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/git-hash.cmake
        WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
)


add_custom_target(
        get_git_hash
        ALL
        DEPENDS
        ${CMAKE_CURRENT_BINARY_DIR}/generated/git-hash.hpp
)


add_dependencies(git-hash get_git_hash)