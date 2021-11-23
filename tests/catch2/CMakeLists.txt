# require C++11
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# example library
# add_library(sum_integers sum_integers.cpp)


# main code
add_executable(sum_catch main.cpp)
target_link_libraries(sum_catch sum_integers)
# testing binary
add_executable(cpp_catch_test sum_integers_test.cpp)
target_link_libraries(cpp_catch_test sum_integers)


enable_testing()
add_test(
        NAME catch_test
        COMMAND $<TARGET_FILE:cpp_test> --success
)