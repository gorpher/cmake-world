
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# example library
#add_library(sum_integers sum_integers.cpp)
# main code
#add_executable(sum_up main.cpp)
#target_link_libraries(sum_up sum_integers)

# 记得检查自己当前版本
find_package(Boost 1.76.0 REQUIRED COMPONENTS unit_test_framework)
add_executable(boost_cpp_test sum_integers_test.cpp)
target_link_libraries(boost_cpp_test
        PRIVATE
        sum_integers
        Boost::unit_test_framework
        )
# avoid undefined reference to "main" in test.cpp
target_compile_definitions(boost_cpp_test
        PRIVATE
        BOOST_TEST_DYN_LINK
        )