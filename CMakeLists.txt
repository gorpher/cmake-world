cmake_minimum_required(VERSION 3.0.0)

project(cmake-world VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置VCPKG 作为包管理
if (NOT DEFINED ENV{VCPKG_ROOT})
    set(VCPKG_ROOT "${CMAKE_SOURCE_DIR}/../vcpkg")
else ()
    set(VCPKG_ROOT "$ENV{VCPKG_ROOT}")
endif ()

set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
# 根据环境修改
set(CMAKE_PREFIX_PATH "${VCPKG_ROOT}/installed/x64-osx")


MESSAGE(STATUS "========output========> variable VCPKG_ROOT  = ${VCPKG_ROOT} <================")
MESSAGE(STATUS "========output========> variable CMAKE_TOOLCHAIN_FILE  = ${CMAKE_TOOLCHAIN_FILE} <================")
MESSAGE(STATUS "========output========> variable CMAKE_PREFIX_PATH  = ${VCPKG_ROOT}/installed/x${ARCH}-${OS} <================")


# 检查操作系统
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(STATUS "Configuring on/for Linux")
elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(STATUS "Configuring on/for macOS")
elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    message(STATUS "Configuring on/for Windows")
elseif (CMAKE_SYSTEM_NAME STREQUAL "AIX")
    message(STATUS "Configuring on/for IBM AIX")
else ()
    message(STATUS "Configuring on/for ${CMAKE_SYSTEM_NAME}")
endif ()

add_executable(check_def check_def.cpp)

# 预处理器与平台相关源代码
#PRIVATE，编译定义将只应用于给定的目标，而不应用于相关的其他目标。
#INTERFACE，对给定目标的编译定义将只应用于使用它的目标。
#PUBLIC，编译定义将应用于给定的目标和使用它的所有其他目标。
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(check_def PUBLIC "IS_LINUX")
endif ()
if (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    target_compile_definitions(check_def PUBLIC "IS_MACOS")
endif ()
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    target_compile_definitions(check_def PUBLIC "IS_WINDOWS")
endif ()

# 预处理器与编译器相关代码

add_executable(check_compile check_compile.cpp)

target_compile_definitions(check_compile PUBLIC "COMPILER_NAME=\"${CMAKE_CXX_COMPILER_ID}\"")
if (CMAKE_CXX_COMPILER_ID MATCHES Intel)
    target_compile_definitions(check_compile PUBLIC "IS_INTEL_CXX_COMPILER")
endif ()
if (CMAKE_CXX_COMPILER_ID MATCHES GNU)
    target_compile_definitions(check_compile PUBLIC "IS_GNU_CXX_COMPILER")
endif ()
if (CMAKE_CXX_COMPILER_ID MATCHES PGI)
    target_compile_definitions(check_compile PUBLIC "IS_PGI_CXX_COMPILER")
endif ()
if (CMAKE_CXX_COMPILER_ID MATCHES XL)
    target_compile_definitions(check_compile PUBLIC "IS_XL_CXX_COMPILER")
endif ()

# 预处理器与架构相关代码
add_executable(check_arch check_arch.cpp)
if (CMAKE_SIZEOF_VOID_P EQUAL 8)
    target_compile_definitions(check_arch PUBLIC "IS_64_BIT_ARCH")
    message(STATUS "Target is 64 bits")
else ()
    target_compile_definitions(check_arch PUBLIC "IS_32_BIT_ARCH")
    message(STATUS "Target is 32 bits")
endif ()

if (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i386")
    message(STATUS "i386 architecture detected")
elseif (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i686")
    message(STATUS "i686 architecture detected")
elseif (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "x86_64")
    message(STATUS "x86_64 architecture detected")
else ()
    message(STATUS "host processor architecture is unknown")
endif ()
target_compile_definitions(check_arch
        PUBLIC "ARCHITECTURE=${CMAKE_HOST_SYSTEM_PROCESSOR}")


# 不同架构代码放到不同架构源码文件中

add_executable(arch-dependent "")
if (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i386")
    message(STATUS "i386 architecture detected")
    target_sources(arch-dependent
            PRIVATE
            arch-dependent-i386.cpp
            )
elseif (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i686")
    message(STATUS "i686 architecture detected")
    target_sources(arch-dependent
            PRIVATE
            arch-dependent-i686.cpp
            )
elseif (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "x86_64")
    message(STATUS "x86_64 architecture detected")
    target_sources(arch-dependent
            PRIVATE
            arch-dependent-x86_64.cpp
            )
else ()
    message(STATUS "host processor architecture is unknown")
endif ()

# 处理器指令集

add_executable(processor-info "")
target_sources(processor-info
        PRIVATE
        processor-info.cpp)

target_include_directories(processor-info
        PRIVATE
        ${PROJECT_BINARY_DIR})


foreach (key
        IN ITEMS
        NUMBER_OF_LOGICAL_CORES
        NUMBER_OF_PHYSICAL_CORES
        TOTAL_VIRTUAL_MEMORY
        AVAILABLE_VIRTUAL_MEMORY
        TOTAL_PHYSICAL_MEMORY
        AVAILABLE_PHYSICAL_MEMORY
        IS_64BIT
        HAS_FPU
        HAS_MMX
        HAS_MMX_PLUS
        HAS_SSE
        HAS_SSE2
        HAS_SSE_FP
        HAS_SSE_MMX
        HAS_AMD_3DNOW
        HAS_AMD_3DNOW_PLUS
        HAS_IA64
        OS_NAME
        OS_RELEASE
        OS_VERSION
        OS_PLATFORM
        )
    cmake_host_system_information(RESULT _${key} QUERY ${key})
endforeach ()

configure_file(config.h.in config.h @ONLY)


# 线性代数
# vcpkg install Eigen3
find_package(Eigen3 3.3 CONFIG REQUIRED)
include(CheckCXXCompilerFlag)
check_cxx_compiler_flag("-march=native" _march_native_works)
check_cxx_compiler_flag("-xHost" _xhost_works)
set(_CXX_FLAGS)
if (_march_native_works)
    message(STATUS "Using processor's vector instructions (-march=native compiler flag set)")
    set(_CXX_FLAGS "-march=native")
elseif (_xhost_works)
    message(STATUS "Using processor's vector instructions (-xHost compiler flag set)")
    set(_CXX_FLAGS "-xHost")
else ()
    message(STATUS "No suitable compiler flag found for vectorization")
endif ()


# 未优化的版本定义了一个可执行目标，不使用优化标志
add_executable(linear-algebra-unoptimized linear-algebra.cpp)
target_link_libraries(linear-algebra-unoptimized
        PRIVATE
        Eigen3::Eigen
        )

# 优化版本
add_executable(linear-algebra linear-algebra.cpp)
target_compile_options(linear-algebra
        PRIVATE
        ${_CXX_FLAGS}
        )
target_link_libraries(linear-algebra
        PRIVATE
        Eigen3::Eigen
        )


# 检查外部依赖环境
#find_file：在相应路径下查找命名文件
#find_library：查找一个库文件
#find_package：从外部项目查找和加载设置
#find_path：查找包含指定文件的目录
#find_program：找到一个可执行程序


# 检测Python解释器
find_package(PythonInterp REQUIRED)
execute_process(
        COMMAND
        ${PYTHON_EXECUTABLE} "-c" "print('Hello, world!')"
        RESULT_VARIABLE _status
        OUTPUT_VARIABLE _hello_world
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "RESULT_VARIABLE is: ${_status}")
message(STATUS "OUTPUT_VARIABLE is: ${_hello_world}")

#PYTHONINTERP_FOUND：是否找到解释器
#PYTHON_EXECUTABLE：Python解释器到可执行文件的路径
#PYTHON_VERSION_STRING：Python解释器的完整版本信息
#PYTHON_VERSION_MAJOR：Python解释器的主要版本号
#PYTHON_VERSION_MINOR ：Python解释器的次要版本号
#PYTHON_VERSION_PATCH：Python解释器的补丁版本号


# 检测Python库
#PYTHON_LIBRARY：指向Python库的路径
#PYTHON_INCLUDE_DIR：Python.h所在的路径

find_package(PythonLibs ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} EXACT REQUIRED)
add_executable(hello-embedded-python hello-embedded-python.c)
target_include_directories(hello-embedded-python
        PRIVATE
        ${PYTHON_INCLUDE_DIRS}
        )
target_link_libraries(hello-embedded-python
        PRIVATE
        ${PYTHON_LIBRARIES}
        )


# 检测Python模块和包

execute_process(
        COMMAND
        ${PYTHON_EXECUTABLE} "-c" "import re, numpy; print(re.compile('/__init__.py.*').sub('',numpy.__file__))"
        RESULT_VARIABLE _numpy_status
        OUTPUT_VARIABLE _numpy_location
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
)

if (NOT _numpy_status)
    set(NumPy ${_numpy_location} CACHE STRING "Location of NumPy")
endif ()

execute_process(
        COMMAND
        ${PYTHON_EXECUTABLE} "-c" "import numpy; print(numpy.__version__)"
        OUTPUT_VARIABLE _numpy_version
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
)

include(FindPackageHandleStandardArgs)
# FindPackageHandleStandardArgs的CMake包以正确的格式设置NumPy_FOUND变量和输出信息
find_package_handle_standard_args(NumPy
        FOUND_VAR NumPy_FOUND
        REQUIRED_VARS NumPy
        VERSION_VAR _numpy_version
        )

add_executable(pure-embedding "")
target_sources(pure-embedding
        PRIVATE
        Py${PYTHON_VERSION_MAJOR}-pure-embedding.cpp
        )
target_include_directories(pure-embedding
        PRIVATE
        ${PYTHON_INCLUDE_DIRS}
        )
target_link_libraries(pure-embedding
        PRIVATE
        ${PYTHON_LIBRARIES}
        )

#保证use_numpy.py在build目录中可用
add_custom_command(
        OUTPUT
        ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
        COMMAND
        ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/use_numpy.py
        ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
        DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/use_numpy.py
)
# make sure building pure-embedding triggers the above custom command
target_sources(pure-embedding
        PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
        )

# 测试嵌入代码： ./pure-embedding use_numpy print_ones 2 3


# 检测BLAS和LAPACK数学库
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

add_library(math "")
target_sources(math
        PRIVATE
        CxxBLAS.cpp
        CxxLAPACK.cpp
        )
target_include_directories(math
        PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
        )
target_link_libraries(math
        PUBLIC
        ${LAPACK_LIBRARIES}
        )
add_executable(linear-algebra-BLAS-LAPACK "")

target_sources(linear-algebra-BLAS-LAPACK
        PRIVATE
        linear-algebra-BLAS-LAPACK.cpp
        )

target_link_libraries(linear-algebra-BLAS-LAPACK
        PRIVATE
        math
        )
# 检测OpenMP并行环境
add_subdirectory(openmp-example)

# 检测MPI并行环境
add_subdirectory(mpi-example)
# 检测Boost库

add_subdirectory(boost-example)
# 检测外部库:Ⅰ. 使用pkg-config

#目前为止，我们已经讨论了两种检测外部依赖关系的方法:
#
#使用CMake自带的find-module，但并不是所有的包在CMake的find模块都找得到。
#使用<package>Config.cmake, <package>ConfigVersion.cmake和<package>Targets.cmake，这些文件由软件包供应商提供，并与软件包一起安装在标准位置的cmake文件夹下。
#如果某个依赖项既不提供查找模块，也不提供供应商打包的CMake文件，该怎么办?在这种情况下，我们只有两个选择:
#
#依赖pkg-config程序，来找到系统上的包。这依赖于包供应商在.pc配置文件中，其中有关于发行包的元数据。
#为依赖项编写自己的find-package模块。
#add_subdirectory(zeromq-example)
# 检测外部库:Ⅱ. 书写find模块
# https://www.bookstack.cn/read/CMake-Cookbook/content-chapter3-3.10-chinese.md


# 生成代码
execute_process(
        COMMAND
        whoami
        TIMEOUT
        1
        OUTPUT_VARIABLE
        _user_name
        OUTPUT_STRIP_TRAILING_WHITESPACE
)

# host name information
cmake_host_system_information(RESULT _host_name QUERY HOSTNAME)
cmake_host_system_information(RESULT _fqdn QUERY FQDN)
# processor information
cmake_host_system_information(RESULT _processor_name QUERY PROCESSOR_NAME)
cmake_host_system_information(RESULT _processor_description QUERY PROCESSOR_DESCRIPTION)
# os information
cmake_host_system_information(RESULT _os_name QUERY OS_NAME)
cmake_host_system_information(RESULT _os_release QUERY OS_RELEASE)
cmake_host_system_information(RESULT _os_version QUERY OS_VERSION)
cmake_host_system_information(RESULT _os_platform QUERY OS_PLATFORM)

string(TIMESTAMP _configuration_time "%Y-%m-%d %H:%M:%S [UTC]" UTC)

configure_file(print_info.c.in print_info.c @ONLY)


add_executable(print_info "")
target_sources(print_info
        PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/print_info.c
        )


# 记录项目信息
configure_file(
        version.h.in
        generated/version.h
        @ONLY
)
add_executable(version version.c)
target_include_directories(version
        PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/generated
        )


# 从文件中读取版本信息

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION" PROGRAM_VERSION)
    string(STRIP "${PROGRAM_VERSION}" PROGRAM_VERSION)
else ()
    message(FATAL_ERROR "File ${CMAKE_CURRENT_SOURCE_DIR}/VERSION not found")
endif ()

configure_file(
        version.hpp.in
        generated/version.hpp
        @ONLY
)
add_executable(version_cpp version.cpp)
target_include_directories(version_cpp
        PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/generated
        )


# 配置时记录hash值
# in case Git is not available, we default to "unknown"
set(GIT_HASH "unknown")
# find Git and if available set GIT_HASH variable
find_package(Git QUIET)
if (GIT_FOUND)
    execute_process(
            COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
            OUTPUT_VARIABLE git-hash
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
            WORKING_DIRECTORY
            ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif ()
message(STATUS "Git hash is ${GIT_HASH}")

# generate file version.hpp based on version.hpp.in
configure_file(
        hash.hpp.in
        generated/version.hpp
        @ONLY
)
# example code
add_executable(hash hash.cpp)
# needs to find the generated header file
target_include_directories(hash
        PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/generated
        )

# 构建时记录hash值

add_subdirectory(git-hash)


#https://github.com/Kitware/CMake/blob/master/Modules/FindPythonLibs.cmake


# 创建一个简单的单元测试
add_subdirectory(tests/sample)
# 使用Catch2库进行单元测试
add_subdirectory(tests/catch2)

# 使用Google Test库进行单元测试

add_subdirectory(tests/google)

# 使用Boost Test进行单元测试
add_subdirectory(tests/boost)

# 使用动态分析来检测内存缺陷
add_subdirectory(tests/memory)

# 预期测试失败
add_subdirectory(tests/failed)

# 使用超时测试运行时间过长的测试
add_subdirectory(tests/longtime)

# 并行测试
# ctest --parallel 10
add_subdirectory(tests/parallel)
# 运行测试子集
add_subdirectory(tests/subset)
# 使用测试固件
add_subdirectory(tests/fixtures)


#安装项目

#install(
#        TARGETS
#        processor-info
#        ARCHIVE
#        DESTINATION ${INSTALL_LIBDIR}
#        COMPONENT lib
#        RUNTIME
#        DESTINATION ${INSTALL_BINDIR}
#        COMPONENT bin
#        LIBRARY
#        DESTINATION ${INSTALL_LIBDIR}
#        COMPONENT lib
#
#)
#生成输出头文件
#输出目标
#安装超级构建