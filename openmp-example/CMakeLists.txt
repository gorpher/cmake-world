find_package(OpenMP REQUIRED)
add_executable(example example.cpp)

target_link_libraries(example
        PUBLIC
        OpenMP::OpenMP_CXX
        )