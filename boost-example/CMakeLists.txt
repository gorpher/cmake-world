find_package(Boost 1.54 REQUIRED COMPONENTS filesystem)

add_executable(path-info path-info.cpp)


target_link_libraries(path-info
        PUBLIC
        Boost::filesystem
        )