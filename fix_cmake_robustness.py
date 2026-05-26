import sys

with open("CMakeLists.txt", "r") as f:
    content = f.read()

# 1. Fix add_subdirectory(cbflib) to run every time
old_cbf_block = """        if(NOT cbflib_POPULATED)
            fetchcontent_populate(cbflib)
            # Patch CBFlib/CMakeLists.txt to find CQRlib
            file(READ ${cbflib_SOURCE_DIR}/CMakeLists.txt CBF_CMAKE)
            string(REPLACE "find_path(CQRLIB_INCLUDE_DIR cqrlib.h)" "set(CQRLIB_INCLUDE_DIR \\"${CQRLIB_INCLUDE_DIR}\\")" CBF_CMAKE "${CBF_CMAKE}")
            string(REPLACE "find_library(CQRLIB_LIBRARY CQRlib)" "set(CQRLIB_LIBRARY \\"${CQRLIB_LIBRARY}\\")" CBF_CMAKE "${CBF_CMAKE}")
            # Specifically fix hardcoded 'CQR' or '-lCQR' in CBFlib.
            string(REGEX REPLACE "([^a-zA-Z0-9_])CQR([^a-zA-Z0-9_])" "\\\\1${CQRLIB_LIBRARY}\\\\2" CBF_CMAKE "${CBF_CMAKE}")
            string(REPLACE "-lCQR" "${CQRLIB_LIBRARY}" CBF_CMAKE "${CBF_CMAKE}")
            string(PREPEND CBF_CMAKE "include_directories(\\"${CQRLIB_INCLUDE_DIR}\\")\\n")
            if(APPLE)
                # Enable all optional TIFF codecs and ensure they are linked
                set(TIFF_PATCH [=[
set(ZSTD ON CACHE BOOL "" FORCE)
set(WEBP ON CACHE BOOL "" FORCE)
set(LERC ON CACHE BOOL "" FORCE)
set(DEFLATE ON CACHE BOOL "" FORCE)
set(JBIG ON CACHE BOOL "" FORCE)
set(LZMA ON CACHE BOOL "" FORCE)
set(JPEG ON CACHE BOOL "" FORCE)

find_package(JPEG REQUIRED)
find_package(ZLIB REQUIRED)
find_library(ZSTD_LIB NAMES zstd HINTS /opt/local/lib)
find_library(WEBP_LIB NAMES webp HINTS /opt/local/lib)
find_library(LERC_LIB NAMES Lerc lerc HINTS /opt/local/lib)
find_library(DEFLATE_LIB NAMES deflate HINTS /opt/local/lib)
find_library(JBIG_LIB NAMES jbig HINTS /opt/local/lib)
find_library(LZMA_LIB NAMES lzma HINTS /opt/local/lib)

link_libraries(${JPEG_LIBRARIES} ${ZLIB_LIBRARIES})
if(ZSTD_LIB)
    link_libraries(${ZSTD_LIB})
endif()
if(WEBP_LIB)
    link_libraries(${WEBP_LIB})
endif()
if(LERC_LIB)
    link_libraries(${LERC_LIB})
endif()
if(DEFLATE_LIB)
    link_libraries(${DEFLATE_LIB})
endif()
if(JBIG_LIB)
    link_libraries(${JBIG_LIB})
endif()
if(LZMA_LIB)
    link_libraries(${LZMA_LIB})
endif()]=])
                string(REPLACE "add_subdirectory(libtiff)" "${TIFF_PATCH}" CBF_CMAKE "${CBF_CMAKE}")
            endif()
            file(WRITE ${cbflib_SOURCE_DIR}/CMakeLists.txt "${CBF_CMAKE}")
            add_subdirectory(${cbflib_SOURCE_DIR} ${cbflib_BINARY_DIR})
        endif()"""

new_cbf_block = """        if(NOT cbflib_POPULATED)
            fetchcontent_populate(cbflib)
            # Patch CBFlib/CMakeLists.txt to find CQRlib
            file(READ ${cbflib_SOURCE_DIR}/CMakeLists.txt CBF_CMAKE)
            string(REPLACE "find_path(CQRLIB_INCLUDE_DIR cqrlib.h)" "set(CQRLIB_INCLUDE_DIR \\"${CQRLIB_INCLUDE_DIR}\\")" CBF_CMAKE "${CBF_CMAKE}")
            string(REPLACE "find_library(CQRLIB_LIBRARY CQRlib)" "set(CQRLIB_LIBRARY \\"${CQRLIB_LIBRARY}\\")" CBF_CMAKE "${CBF_CMAKE}")
            # Specifically fix hardcoded 'CQR' or '-lCQR' in CBFlib.
            string(REGEX REPLACE "([^a-zA-Z0-9_])CQR([^a-zA-Z0-9_])" "\\\\1${CQRLIB_LIBRARY}\\\\2" CBF_CMAKE "${CBF_CMAKE}")
            string(REPLACE "-lCQR" "${CQRLIB_LIBRARY}" CBF_CMAKE "${CBF_CMAKE}")
            string(PREPEND CBF_CMAKE "include_directories(\\"${CQRLIB_INCLUDE_DIR}\\")\\n")
            if(APPLE)
                # Enable all optional TIFF codecs and ensure they are linked
                set(TIFF_PATCH [=[
set(ZSTD ON CACHE BOOL "" FORCE)
set(WEBP ON CACHE BOOL "" FORCE)
set(LERC ON CACHE BOOL "" FORCE)
set(DEFLATE ON CACHE BOOL "" FORCE)
set(JBIG ON CACHE BOOL "" FORCE)
set(LZMA ON CACHE BOOL "" FORCE)
set(JPEG ON CACHE BOOL "" FORCE)

find_package(JPEG REQUIRED)
find_package(ZLIB REQUIRED)
find_library(ZSTD_LIB NAMES zstd HINTS /opt/local/lib)
find_library(WEBP_LIB NAMES webp HINTS /opt/local/lib)
find_library(LERC_LIB NAMES Lerc lerc HINTS /opt/local/lib)
find_library(DEFLATE_LIB NAMES deflate HINTS /opt/local/lib)
find_library(JBIG_LIB NAMES jbig HINTS /opt/local/lib)
find_library(LZMA_LIB NAMES lzma HINTS /opt/local/lib)

link_libraries(${JPEG_LIBRARIES} ${ZLIB_LIBRARIES})
if(ZSTD_LIB)
    link_libraries(${ZSTD_LIB})
endif()
if(WEBP_LIB)
    link_libraries(${WEBP_LIB})
endif()
if(LERC_LIB)
    link_libraries(${LERC_LIB})
endif()
if(DEFLATE_LIB)
    link_libraries(${DEFLATE_LIB})
endif()
if(JBIG_LIB)
    link_libraries(${JBIG_LIB})
endif()
if(LZMA_LIB)
    link_libraries(${LZMA_LIB})
endif()]=])
                string(REPLACE "add_subdirectory(libtiff)" "${TIFF_PATCH}" CBF_CMAKE "${CBF_CMAKE}")
            endif()
            file(WRITE ${cbflib_SOURCE_DIR}/CMakeLists.txt "${CBF_CMAKE}")
        endif()
        add_subdirectory(${cbflib_SOURCE_DIR} ${cbflib_BINARY_DIR})"""

content = content.replace(old_cbf_block, new_cbf_block)

# 2. Fix relative paths in install commands
content = content.replace("install(DIRECTORY data/ DESTINATION share/rasmol/data)", "install(DIRECTORY ${CMAKE_SOURCE_DIR}/data/ DESTINATION share/rasmol/data)")
content = content.replace("install(DIRECTORY doc/ DESTINATION share/rasmol/doc)", "install(DIRECTORY ${CMAKE_SOURCE_DIR}/doc/ DESTINATION share/rasmol/doc)")

with open("CMakeLists.txt", "w") as f:
    f.write(content)
