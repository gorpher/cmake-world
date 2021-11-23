find_package(PythonInterp REQUIRED)


enable_testing()
add_test(test_py_failed ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.py)
set_tests_properties(test_py_failed PROPERTIES WILL_FAIL true)