cmake_minimum_required(VERSION 3.11)
project(RasMol C CXX)

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

set(PIXELDEPTH "32" CACHE STRING "Pixel depth (8, 16, or 32)")
option(WITH_X11 "Build with X11 support" ON)

if(NOT PIXELDEPTH MATCHES "^(8|16|32)$")
    message(FATAL_ERROR "PIXELDEPTH must be 8, 16, or 32")
endif()

set(EXTERNAL_LIBRARIES)
if(NOT MSVC)
    find_library(MATH_LIBRARY m)
    if(MATH_LIBRARY)
        list(APPEND EXTERNAL_LIBRARIES ${MATH_LIBRARY})
    endif()
endif()

# We need PIC for shared libraries on some platforms (like macOS)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_path(CBF_INCLUDE_DIR NAMES cbf.h PATH_SUFFIXES cbf cbflib)
find_path(NEARTREE_INCLUDE_DIR NAMES CNearTree.h PATH_SUFFIXES NearTree neartree)
find_path(CQRLIB_INCLUDE_DIR NAMES cqrlib.h PATH_SUFFIXES cqrlib CQRlib)
find_path(CVECTOR_INCLUDE_DIR NAMES CVector.h PATH_SUFFIXES cvector)
find_library(CBF_LIBRARY NAMES cbf)
find_library(NEARTREE_LIBRARY NAMES CNearTree neartree)
find_library(CQRLIB_LIBRARY NAMES CQRlib cqrlib)
find_library(CVECTOR_LIBRARY NAMES CVector cvector)

include(FetchContent)

if(NOT CQRLIB_LIBRARY)
    message(STATUS "CQRlib not found. Fetching from GitHub...")
    fetchcontent_declare(cqrlib
        GIT_REPOSITORY https://github.com/zhou0/cqrlib.git
        GIT_TAG 73cd0aad2b7240b7fbe8ad928cc67015cc6579d1
    )
    fetchcontent_makeavailable(cqrlib)
    set(CQRLIB_LIBRARY CQRlib)
    set(CQRLIB_INCLUDE_DIR ${cqrlib_SOURCE_DIR})
endif()

if(NOT CVECTOR_LIBRARY)
    message(STATUS "CVector not found. Fetching from GitHub...")
    fetchcontent_declare(cvector
        GIT_REPOSITORY https://github.com/zhou0/CVector.git
        GIT_TAG master
    )
    fetchcontent_makeavailable(cvector)
    set(CVECTOR_LIBRARY CV_static)
    set(CVECTOR_INCLUDE_DIR ${cvector_SOURCE_DIR})
    # Ensure the target produces libCV_static.a/lib so that -lCV_static works
    set_target_properties(CV_static PROPERTIES OUTPUT_NAME "CV_static")
endif()

if(NOT NEARTREE_LIBRARY)
    message(STATUS "NearTree not found. Fetching from GitHub...")
    fetchcontent_declare(neartree
        GIT_REPOSITORY https://github.com/zhou0/NearTree.git
        GIT_TAG main
    )
    # Pass CVector target/dirs to NearTree project
    set(CVECTOR_INCLUDE_DIR ${CVECTOR_INCLUDE_DIR} CACHE PATH "" FORCE)
    set(CVECTOR_LIBRARY ${CVECTOR_LIBRARY} CACHE STRING "" FORCE)
    fetchcontent_makeavailable(neartree)
    set(NEARTREE_LIBRARY CNearTree)
    set(NEARTREE_INCLUDE_DIR ${neartree_SOURCE_DIR})
endif()

if(NOT CBF_LIBRARY)
    message(STATUS "CBFlib not found. Fetching from GitHub...")
    fetchcontent_declare(cbflib
        GIT_REPOSITORY https://github.com/yayahjb/cbflib.git
        GIT_TAG main
    )
    set(CBF_ENABLE_FORTRAN OFF CACHE BOOL "" FORCE)
    set(CBF_ENABLE_JAVA OFF CACHE BOOL "" FORCE)
    set(CBF_ENABLE_PYTHON OFF CACHE BOOL "" FORCE)
    set(CBF_ENABLE_DOC OFF CACHE BOOL "" FORCE)
    find_package(BISON)
    if(BISON_FOUND)
        fetchcontent_makeavailable(cbflib)
        set(CBF_LIBRARY cbf)
        set(CBF_INCLUDE_DIR ${cbflib_SOURCE_DIR}/include)
    else()
        message(WARNING "Bison not found. Cannot build external CBFlib fallback. CIF support will use internal code.")
        set(CBF_LIBRARY "")
        set(CBF_INCLUDE_DIR "")
    endif()
endif()

# VTK Support
set(VTK_COMPONENTS
    CommonCore
    CommonDataModel
    FiltersCore
    IOGeometry
    IOLegacy
    IOPDB
    RenderingCore
    RenderingOpenGL2
    RenderingFreeType
)
find_package(VTK 9.3.1 QUIET COMPONENTS ${VTK_COMPONENTS})
if(NOT VTK_FOUND AND NOT UNIX)
    message(STATUS "VTK 9.3.1 not found. Fetching from vtk.org...")
    fetchcontent_declare(vtk URL https://vtk.org/files/release/9.3/VTK-9.3.1.tar.gz)
    set(VTK_ENABLE_REMOTE_MODULES OFF CACHE BOOL "" FORCE)
    set(VTK_BUILD_TESTING OFF CACHE BOOL "" FORCE)
    set(VTK_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
    set(VTK_GROUP_ENABLE_Qt NO CACHE STRING "" FORCE)
    fetchcontent_makeavailable(vtk)
    find_package(VTK 9.3.1 QUIET COMPONENTS ${VTK_COMPONENTS})
endif()

if(VTK_FOUND)
    add_definitions(-DUSE_VTK)
    message(STATUS "VTK found: ${VTK_VERSION}")
endif()

# Set default output directories EARLY to prevent subprojects from overriding them
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

add_definitions(-D_USE_RASMOL_H_)
if(NOT WIN32)
    add_definitions(-DUNIX)
endif()
if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

if(PIXELDEPTH EQUAL 8)
    add_definitions(-DEIGHTBIT)
else()
    if(PIXELDEPTH EQUAL 16)
        add_definitions(-DSIXTEENBIT)
    else()
        if(PIXELDEPTH EQUAL 32)
            add_definitions(-DTHIRTYTWOBIT)
        endif()
    endif()
endif()

if(NOT RASMOLDIR)
    set(RASMOLDIR "${CMAKE_INSTALL_PREFIX}/share/rasmol/")
endif()
add_definitions(-DRASMOLDIR="${RASMOLDIR}")

if(CBF_LIBRARY)
    add_definitions(-DUSE_CBFLIB)
endif()

find_package(HDF5 COMPONENTS C)
if(HDF5_FOUND)
    include_directories(${HDF5_INCLUDE_DIRS})
    list(APPEND EXTERNAL_LIBRARIES ${HDF5_LIBRARIES})
else()
    find_path(HDF5_INCLUDE_DIR hdf5.h PATH_SUFFIXES hdf5/serial)
    if(HDF5_INCLUDE_DIR)
        include_directories(${HDF5_INCLUDE_DIR})
    endif()
endif()

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

set(CORE_SOURCES src/abstree.c src/cif.c src/cif_ctonum.c src/cif_fract.c src/cif_stx.c src/cmndline.c src/command.c src/infile.c src/langsel_unix.c src/maps.c src/molecule.c src/multiple.c src/outfile.c src/pixutils.c src/render.c src/repres.c src/script.c src/tokens.c src/transfor.c src/vector.c src/wbrotate.c)
if(WIN32)
    list(APPEND CORE_SOURCES src/string_case.c)
endif()

if(WITH_X11)
    find_package(X11)
    if(X11_FOUND)
        add_executable(rasmol src/rasmol.c src/x11win.c ${CORE_SOURCES})
        target_include_directories(rasmol PRIVATE src ${X11_INCLUDE_DIR})
        target_link_libraries(rasmol ${X11_LIBRARIES} ${EXTERNAL_LIBRARIES})
        target_compile_definitions(rasmol PRIVATE X11WIN)
    endif()
endif()

add_executable(rastxt src/rastxt.c ${CORE_SOURCES})
target_include_directories(rastxt PRIVATE src/txt src)
target_link_libraries(rastxt ${EXTERNAL_LIBRARIES})

install(TARGETS rastxt DESTINATION bin)
if(TARGET rasmol)
    install(TARGETS rasmol DESTINATION bin)
endif()

install(DIRECTORY data/ DESTINATION share/rasmol/data)
install(DIRECTORY doc/ DESTINATION share/rasmol/doc)
if(EXISTS "${CMAKE_SOURCE_DIR}/doc/rasmol.hlp")
    install(FILES doc/rasmol.hlp DESTINATION share/rasmol)
endif()

# Tcl/Tk Support
if(WIN32)
    set(TCL_NAMES tcl86 tcl86t)
    set(TK_NAMES tk86 tk86t)
else()
    set(TCL_NAMES tcl8.6 tcl86)
    set(TK_NAMES tk8.6 tk86)
endif()

find_path(TCL_INCLUDE_PATH tcl.h PATH_SUFFIXES tcl8.6 tcl86 tcl)
find_path(TK_INCLUDE_PATH tk.h PATH_SUFFIXES tk8.6 tk86 tk)
find_library(TCL_LIBRARY NAMES ${TCL_NAMES})
find_library(TK_LIBRARY NAMES ${TK_NAMES})

if(TCL_INCLUDE_PATH AND TK_INCLUDE_PATH AND TCL_LIBRARY AND TK_LIBRARY)
    include_directories(${TCL_INCLUDE_PATH} ${TK_INCLUDE_PATH})
    set(RASMOL_TCL_SOURCES warpings/tcl/rasmol_tcl.c ${CORE_SOURCES})
    if(VTK_FOUND)
        list(APPEND RASMOL_TCL_SOURCES warpings/tcl/rasmol_vtk.cpp)
    endif()
    add_executable(rasmol_tcl ${RASMOL_TCL_SOURCES})
    target_include_directories(rasmol_tcl PRIVATE src)
    target_link_libraries(rasmol_tcl ${TCL_LIBRARY} ${TK_LIBRARY} ${EXTERNAL_LIBRARIES})
    if(VTK_FOUND)
        target_link_libraries(rasmol_tcl PRIVATE ${VTK_LIBRARIES})
        vtk_module_autoinit(TARGETS rasmol_tcl MODULES ${VTK_LIBRARIES})
    endif()
    if(UNIX AND NOT APPLE)
        target_link_libraries(rasmol_tcl ${X11_LIBRARIES})
    endif()
    install(TARGETS rasmol_tcl DESTINATION bin)
endif()
