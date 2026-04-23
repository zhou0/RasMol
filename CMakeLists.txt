cmake_minimum_required(VERSION 3.5)
project(RasMol C)

# Options
set(PIXELDEPTH "8" CACHE STRING "Pixel depth (8, 16, or 32)")
option(WITH_X11 "Build with X11 support" ON)

if(NOT PIXELDEPTH MATCHES "^(8|16|32)$")
    message(FATAL_ERROR "PIXELDEPTH must be 8, 16, or 32")
endif()

# Dependencies
find_library(MATH_LIBRARY m)

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
add_definitions(-D_USE_RASMOL_H_ -DUNIX)
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
    find_package(X11 REQUIRED)

    # In a real environment, you would also need to find or build:
    # CBFlib, CQRlib, CVector, NearTree

    add_executable(rasmol src/rasmol.c src/x11win.c ${CORE_SOURCES})
    target_include_directories(rasmol PRIVATE src ${X11_INCLUDE_DIR})
    target_link_libraries(rasmol ${X11_LIBRARIES} ${MATH_LIBRARY})
    target_compile_definitions(rasmol PRIVATE X11WIN)
endif()

# rastxt executable (Text-only)
add_executable(rastxt src/rastxt.c ${CORE_SOURCES})
# rastxt needs src/txt before src/ to get the text-only rasmol.h
target_include_directories(rastxt PRIVATE src/txt src)
target_link_libraries(rastxt ${MATH_LIBRARY})

# Installation
install(TARGETS rastxt DESTINATION bin)
if(WITH_X11)
    install(TARGETS rasmol DESTINATION bin)
endif()

# Install data files
install(DIRECTORY data/ DESTINATION share/rasmol/data)

# Install documentation
install(DIRECTORY doc/ DESTINATION share/rasmol/doc)

# Install help file to the expected location
install(FILES doc/rasmol.hlp DESTINATION share/rasmol)
