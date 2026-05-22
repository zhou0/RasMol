# CMake generated Testfile for
# Source directory: /app/build_test/_deps/cqrlib-src
# Build directory: /app/build_test/_deps/cqrlib-build
#
# This file includes the relevant testing commands required for
# testing this directory and lists subdirectories to be tested as well.
add_test(CQRlibTest "/usr/bin/cmake" "-DTEST_EXECUTABLE=/app/build_test/bin/CQRlibTest" "-DREFERENCE_FILE=/app/build_test/_deps/cqrlib-src/CQRlibTest_orig.lst" "-DOUTPUT_FILE=CQRlibTest.lst" "-P" "/app/build_test/_deps/cqrlib-src/run_test.cmake")
set_tests_properties(CQRlibTest PROPERTIES  _BACKTRACE_TRIPLES "/app/build_test/_deps/cqrlib-src/CMakeLists.txt;33;add_test;/app/build_test/_deps/cqrlib-src/CMakeLists.txt;0;")
add_test(CPPQRTest "/usr/bin/cmake" "-DTEST_EXECUTABLE=/app/build_test/bin/CPPQRTest" "-DREFERENCE_FILE=/app/build_test/_deps/cqrlib-src/CPPQRTest_orig.lst" "-DOUTPUT_FILE=CPPQRTest.lst" "-P" "/app/build_test/_deps/cqrlib-src/run_test.cmake")
set_tests_properties(CPPQRTest PROPERTIES  _BACKTRACE_TRIPLES "/app/build_test/_deps/cqrlib-src/CMakeLists.txt;41;add_test;/app/build_test/_deps/cqrlib-src/CMakeLists.txt;0;")
