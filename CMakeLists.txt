cmake_minimum_required(VERSION 3.5)
project(RasMol C)

# Options
set(PIXELDEPTH "8" CACHE STRING "Pixel depth (8, 16, or 32)")
option(WITH_X11 "Build with X11 support" ON)

if(NOT PIXELDEPTH MATCHES "^(8|16|32)$")
    message(FATAL_ERROR "PIXELDEPTH must be 8, 16, or 32")
endif()

# Dependencies
set(EXTERNAL_LIBRARIES)
if(NOT MSVC)
    find_library(MATH_LIBRARY m)
    if(MATH_LIBRARY)
        list(APPEND EXTERNAL_LIBRARIES ${MATH_LIBRARY})
    endif()
endif()

# Required libraries - Use find_path with common suffixes to handle various distributions
find_path(CBF_INCLUDE_DIR NAMES cbf.h PATH_SUFFIXES cbf cbflib)
find_path(NEARTREE_INCLUDE_DIR NAMES CNearTree.h PATH_SUFFIXES NearTree neartree)
find_path(CQRLIB_INCLUDE_DIR NAMES cqrlib.h PATH_SUFFIXES cqrlib)
find_path(CVECTOR_INCLUDE_DIR NAMES CVector.h PATH_SUFFIXES cvector)

if(CBF_INCLUDE_DIR)
    include_directories(${CBF_INCLUDE_DIR})
endif()
if(NEARTREE_INCLUDE_DIR)
    include_directories(${NEARTREE_INCLUDE_DIR})
endif()
if(CQRLIB_INCLUDE_DIR)
    include_directories(${CQRLIB_INCLUDE_DIR})
endif()
if(CVECTOR_INCLUDE_DIR)
    include_directories(${CVECTOR_INCLUDE_DIR})
endif()

find_library(CBF_LIBRARY NAMES cbf)
find_library(NEARTREE_LIBRARY NAMES CNearTree neartree)
find_library(CQRLIB_LIBRARY NAMES cqrlib)
find_library(CVECTOR_LIBRARY NAMES CVector cvector)

if(CBF_LIBRARY)
    list(APPEND EXTERNAL_LIBRARIES ${CBF_LIBRARY})
endif()
if(NEARTREE_LIBRARY)
    list(APPEND EXTERNAL_LIBRARIES ${NEARTREE_LIBRARY})
endif()
if(CQRLIB_LIBRARY)
    list(APPEND EXTERNAL_LIBRARIES ${CQRLIB_LIBRARY})
endif()
if(CVECTOR_LIBRARY)
    list(APPEND EXTERNAL_LIBRARIES ${CVECTOR_LIBRARY})
endif()

# Core source files shared by both rasmol and rastxt
set(CORE_SOURCES
    src/abstree.c
    src/cif.c
    src/cif_ctonum.c
    src/cif_fract.c
    src/cif_stx.c
    src/cmndline.c
    src/command.c
    src/infile.c
    src/langsel_unix.c
    src/maps.c
    src/molecule.c
    src/multiple.c
    src/outfile.c
    src/pixutils.c
    src/render.c
    src/repres.c
    src/script.c
    src/tokens.c
    src/transfor.c
    src/vector.c
    src/wbrotate.c
)

# Common definitions
add_definitions(-D_USE_RASMOL_H_)
if(NOT WIN32)
    add_definitions(-DUNIX)
endif()

if(PIXELDEPTH EQUAL 8)
    add_definitions(-DEIGHTBIT)
elseif(PIXELDEPTH EQUAL 16)
    add_definitions(-DSIXTEENBIT)
elseif(PIXELDEPTH EQUAL 32)
    add_definitions(-DTHIRTYTWOBIT)
endif()

# RasMol directory for data/help files
if(NOT RASMOLDIR)
    set(RASMOLDIR "${CMAKE_INSTALL_PREFIX}/share/rasmol/")
endif()
add_definitions(-DRASMOLDIR="${RASMOLDIR}")

# rasmol executable (GUI)
if(WITH_X11)
    find_package(X11)
    if(X11_FOUND)
        add_executable(rasmol src/rasmol.c src/x11win.c ${CORE_SOURCES})
        target_include_directories(rasmol PRIVATE src ${X11_INCLUDE_DIR})
        target_link_libraries(rasmol ${X11_LIBRARIES} ${EXTERNAL_LIBRARIES})
        target_compile_definitions(rasmol PRIVATE X11WIN)
    endif()
endif()

# rastxt executable (Text-only)
add_executable(rastxt src/rastxt.c ${CORE_SOURCES})
# rastxt needs src/txt before src/ to get the text-only rasmol.h
target_include_directories(rastxt PRIVATE src/txt src)
target_link_libraries(rastxt ${EXTERNAL_LIBRARIES})

# Installation
install(TARGETS rastxt DESTINATION bin)
if(TARGET rasmol)
    install(TARGETS rasmol DESTINATION bin)
endif()

# Install data files
install(DIRECTORY data/ DESTINATION share/rasmol/data)

# Install documentation
install(DIRECTORY doc/ DESTINATION share/rasmol/doc)

# Install help file
if(EXISTS "${CMAKE_SOURCE_DIR}/doc/rasmol.hlp")
    install(FILES doc/rasmol.hlp DESTINATION share/rasmol)
endif()
