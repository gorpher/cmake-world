set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_library(leaky_implementation_library leaky_implementation.cpp)
add_executable(leaky_cpp_test leaky_implementation_test.cpp)
target_link_libraries(leaky_cpp_test leaky_implementation_library)

find_program(MEMORYCHECK_COMMAND NAMES valgrind)
set(MEMORYCHECK_COMMAND_OPTIONS "--trace-children=yes --leak-check=full")
# add memcheck test action
include(CTest)
enable_testing()
add_test(
        NAME leaky_cpp_test
        COMMAND $<TARGET_FILE:leaky_cpp_test>
)