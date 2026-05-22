# CMake generated Testfile for
# Source directory: /app/build_test/_deps/cvector-src
# Build directory: /app/build_test/_deps/cvector-build
#
# This file includes the relevant testing commands required for
# testing this directory and lists subdirectories to be tested as well.
add_test(CVectorBasicTest "/app/build_test/bin/CVectorBasicTest" "CVectorBasicTest.lst")
set_tests_properties(CVectorBasicTest PROPERTIES  _BACKTRACE_TRIPLES "/app/build_test/_deps/cvector-src/CMakeLists.txt;165;add_test;/app/build_test/_deps/cvector-src/CMakeLists.txt;0;")
add_test(cmp-CVectorBasicTest_orig.lst-CVectorBasicTest.lst "/usr/bin/cmake" "-E" "compare_files" "/app/build_test/_deps/cvector-src/CVectorBasicTest_orig.lst" "CVectorBasicTest.lst")
set_tests_properties(cmp-CVectorBasicTest_orig.lst-CVectorBasicTest.lst PROPERTIES  _BACKTRACE_TRIPLES "/app/build_test/_deps/cvector-src/CMakeLists.txt;166;add_test;/app/build_test/_deps/cvector-src/CMakeLists.txt;0;")
