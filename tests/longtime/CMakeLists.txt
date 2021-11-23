# detect python
find_package(PythonInterp REQUIRED)
# define tests
enable_testing()
# we expect this test to run for 2 seconds
add_test(longtime_test ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/longtime_test.py)
set_tests_properties(longtime_test PROPERTIES TIMEOUT 10)