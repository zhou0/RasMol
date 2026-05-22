# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/app/build_test/_deps/cqrlib-src"
  "/app/build_test/_deps/cqrlib-build"
  "/app/build_test/_deps/cqrlib-subbuild/cqrlib-populate-prefix"
  "/app/build_test/_deps/cqrlib-subbuild/cqrlib-populate-prefix/tmp"
  "/app/build_test/_deps/cqrlib-subbuild/cqrlib-populate-prefix/src/cqrlib-populate-stamp"
  "/app/build_test/_deps/cqrlib-subbuild/cqrlib-populate-prefix/src"
  "/app/build_test/_deps/cqrlib-subbuild/cqrlib-populate-prefix/src/cqrlib-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/app/build_test/_deps/cqrlib-subbuild/cqrlib-populate-prefix/src/cqrlib-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/app/build_test/_deps/cqrlib-subbuild/cqrlib-populate-prefix/src/cqrlib-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
