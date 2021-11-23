
find_package(PkgConfig REQUIRED QUIET)

pkg_search_module(
        ZeroMQ
        REQUIRED
        libzeromq libzmq lib0mq
)

if(ZeroMQ_FOUND)
    message(STATUS "Found ZeroMQ")
endif()

add_executable(hwserver hwserver.c)

target_include_directories(hwserver
        PRIVATE
        ${ZeroMQ_INCLUDE_DIRS}
        )
target_link_libraries(hwserver
        PRIVATE
        ${ZeroMQ_LIBRARIES}
        )

add_executable(hwclient hwclient.c)

target_include_directories(hwclient
        PRIVATE
        ${ZeroMQ_INCLUDE_DIRS}
        )
target_link_libraries(hwclient
        PRIVATE
        ${ZeroMQ_LIBRARIES}
        )