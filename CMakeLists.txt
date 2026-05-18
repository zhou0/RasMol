cmake_minimum_required(VERSION 3.11)
project(RasMol C CXX)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
# Default output directories used to avoid installation conflicts on Windows

if(POLICY CMP0169)
  cmake_policy(SET CMP0169 OLD)
endif()

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

set(PIXELDEPTH "32" CACHE STRING "Pixel depth (8, 16, or 32)")
if(APPLE OR WIN32)
    option(WITH_X11 "Build with X11 support" OFF)
else()
    option(WITH_X11 "Build with X11 support" ON)
endif()

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
    set(CQRLIB_LIBRARY CQRlib CACHE STRING "" FORCE)
    set(CQRLIB_INCLUDE_DIR ${cqrlib_SOURCE_DIR} CACHE PATH "" FORCE)
endif()


if(NOT CVECTOR_LIBRARY)
    message(STATUS "CVector not found. Fetching from GitHub...")
    fetchcontent_declare(cvector
        GIT_REPOSITORY https://github.com/zhou0/CVector.git
        GIT_TAG master
    )
    fetchcontent_makeavailable(cvector)
    set(CVECTOR_LIBRARY CV_shared CACHE STRING "" FORCE)
    set(CVECTOR_INCLUDE_DIR ${cvector_SOURCE_DIR} CACHE PATH "" FORCE)
endif()


if(NOT NEARTREE_LIBRARY)
    message(STATUS "NearTree not found. Fetching from GitHub...")
    fetchcontent_declare(neartree
        GIT_REPOSITORY https://github.com/zhou0/NearTree.git
        GIT_TAG main
    )
    fetchcontent_makeavailable(neartree)
    set(NEARTREE_LIBRARY CNearTree CACHE STRING "" FORCE)
    set(NEARTREE_INCLUDE_DIR ${neartree_SOURCE_DIR} CACHE PATH "" FORCE)
endif()

if(NOT CBF_LIBRARY)
    message(STATUS "CBFlib not found. Fetching from GitHub...")
    fetchcontent_declare(cbflib
        GIT_REPOSITORY https://github.com/yayahjb/cbflib.git
        GIT_TAG ebe2164f6cc356e9c44c0ee1a7fda8631c3bfc6a
    )
    set(CBF_ENABLE_FORTRAN OFF CACHE BOOL "" FORCE)
    set(CBF_ENABLE_JAVA OFF CACHE BOOL "" FORCE)
    set(CBF_ENABLE_PYTHON OFF CACHE BOOL "" FORCE)
    set(CBF_ENABLE_DOC OFF CACHE BOOL "" FORCE)
    find_package(BISON)
    if(BISON_FOUND)
        fetchcontent_getproperties(cbflib)
        if(NOT cbflib_POPULATED)
            fetchcontent_populate(cbflib)
            # Patch CBFlib/CMakeLists.txt to find CQRlib
            file(READ ${cbflib_SOURCE_DIR}/CMakeLists.txt CBF_CMAKE)
            string(REPLACE "find_path(CQRLIB_INCLUDE_DIR cqrlib.h)" "set(CQRLIB_INCLUDE_DIR \"${CQRLIB_INCLUDE_DIR}\")" CBF_CMAKE "${CBF_CMAKE}")
            string(REPLACE "find_library(CQRLIB_LIBRARY CQRlib)" "set(CQRLIB_LIBRARY \"${CQRLIB_LIBRARY}\")" CBF_CMAKE "${CBF_CMAKE}")
            # Specifically fix hardcoded 'CQR' or '-lCQR' if it exists in CBFlib link commands
            string(REPLACE " CQR " " ${CQRLIB_LIBRARY} " CBF_CMAKE "${CBF_CMAKE}")
            string(REPLACE " CQR)" " ${CQRLIB_LIBRARY})" CBF_CMAKE "${CBF_CMAKE}")
            string(REPLACE "-lCQR" "${CQRLIB_LIBRARY}" CBF_CMAKE "${CBF_CMAKE}")
            string(PREPEND CBF_CMAKE "include_directories(\"${CQRLIB_INCLUDE_DIR}\")\n")
            if(APPLE)
                string(APPEND CBF_CMAKE "\nfind_package(JPEG REQUIRED)\nlink_libraries(\${JPEG_LIBRARIES})\n")
                # Also try to specifically link the internal tiff if it exists
                string(REPLACE "add_subdirectory(libtiff)" "add_subdirectory(libtiff)\nif(TARGET tiff)\ntarget_link_libraries(tiff \${JPEG_LIBRARIES})\nendif()" CBF_CMAKE "${CBF_CMAKE}")
            endif()
            file(WRITE ${cbflib_SOURCE_DIR}/CMakeLists.txt "${CBF_CMAKE}")
            add_subdirectory(${cbflib_SOURCE_DIR} ${cbflib_BINARY_DIR})
        endif()
        set(CBF_LIBRARY cbf CACHE STRING "" FORCE)
        set(CBF_INCLUDE_DIR ${cbflib_SOURCE_DIR}/include CACHE PATH "" FORCE)
    else()
        message(WARNING "Bison not found. Cannot build external CBFlib fallback. CIF support will use internal code.")
        set(CBF_LIBRARY "" CACHE STRING "" FORCE)
        set(CBF_INCLUDE_DIR "" CACHE PATH "" FORCE)
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
if(NOT VTK_FOUND)
    if(MSVC)
        message(STATUS "VTK 9.3.1 not found. On MSVC, please install it via vcpkg: 'vcpkg install vtk'")
    elseif(NOT UNIX)
        message(STATUS "VTK 9.3.1 not found. Fetching from vtk.org...")
        fetchcontent_declare(vtk URL https://vtk.org/files/release/9.3/VTK-9.3.1.tar.gz)
        set(VTK_ENABLE_REMOTE_MODULES OFF CACHE BOOL "" FORCE)
        set(VTK_BUILD_TESTING OFF CACHE BOOL "" FORCE)
        set(VTK_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
        set(VTK_GROUP_ENABLE_Qt NO CACHE STRING "" FORCE)
        fetchcontent_makeavailable(vtk)
        find_package(VTK 9.3.1 QUIET COMPONENTS ${VTK_COMPONENTS})
    endif()
endif()

if(VTK_FOUND)
    add_definitions(-DUSE_VTK)
    message(STATUS "VTK found: ${VTK_VERSION}")
endif()

# Set default output directories EARLY to prevent subprojects from overriding them

add_definitions(-D_USE_RASMOL_H_ -DFUNCPROTO)
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
    if(APPLE)
        find_package(JPEG REQUIRED)
        list(APPEND EXTERNAL_LIBRARIES ${JPEG_LIBRARIES})
    endif()
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
if(APPLE)
    # macOS framework logic hints
    set(CMAKE_FRAMEWORK_PATH /Library/Frameworks /System/Library/Frameworks)
    find_library(TCL_LIBRARY Tcl)
    find_library(TK_LIBRARY Tk)
    find_path(TCL_INCLUDE_PATH tcl.h PATH_SUFFIXES Tcl.framework/Headers)
    find_path(TK_INCLUDE_PATH tk.h PATH_SUFFIXES Tk.framework/Headers)
endif()

if(NOT TCL_LIBRARY OR NOT TK_LIBRARY)
    find_package(TCL QUIET)
    find_package(TK QUIET)
endif()

if(NOT TCL_INCLUDE_PATH OR NOT TK_INCLUDE_PATH OR NOT TCL_LIBRARY OR NOT TK_LIBRARY)
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
endif()

if(TCL_LIBRARY AND TK_LIBRARY)
    set(RASMOL_TCL_SOURCES warpings/tcl/rasmol_tcl.c ${CORE_SOURCES})
    if(VTK_FOUND)
        list(APPEND RASMOL_TCL_SOURCES warpings/tcl/rasmol_vtk.cpp)
    endif()
    add_executable(rasmol_tcl ${RASMOL_TCL_SOURCES})
    target_include_directories(rasmol_tcl PRIVATE src ${TCL_INCLUDE_PATH} ${TK_INCLUDE_PATH})
    target_link_libraries(rasmol_tcl ${TCL_LIBRARY} ${TK_LIBRARY} ${EXTERNAL_LIBRARIES})
    if(VTK_FOUND)
        target_link_libraries(rasmol_tcl PRIVATE ${VTK_LIBRARIES})
        vtk_module_autoinit(TARGETS rasmol_tcl MODULES ${VTK_LIBRARIES})
    endif()
    if(UNIX AND NOT APPLE AND WITH_X11)
        target_link_libraries(rasmol_tcl ${X11_LIBRARIES})
    endif()
    if(APPLE)
        target_link_libraries(rasmol_tcl "-framework Cocoa" "-framework IOKit" "-framework CoreFoundation" "-framework CoreGraphics")
        target_compile_definitions(rasmol_tcl PRIVATE MAC_OSX_TK)
    endif()
    install(TARGETS rasmol_tcl DESTINATION bin)
    install(FILES gui/tcltk/rasmol_ui.tcl gui/tcltk/logo.tcl DESTINATION share/rasmol)
else()
    message(WARNING "Tcl/Tk dependencies not fully found. rasmol_tcl target will not be created.")
    message(STATUS "TCL_INCLUDE_PATH: ${TCL_INCLUDE_PATH}")
    message(STATUS "TK_INCLUDE_PATH: ${TK_INCLUDE_PATH}")
    message(STATUS "TCL_LIBRARY: ${TCL_LIBRARY}")
    message(STATUS "TK_LIBRARY: ${TK_LIBRARY}")
endif()

# CPack Configuration for Installer Generation
set(CPACK_PACKAGE_NAME "RasMol")
set(CPACK_PACKAGE_VENDOR "RasMol Maintenance Team")
set(CPACK_PACKAGE_VERSION "2.8.0")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "RasMol Molecular Graphics Visualisation Tool")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/RASLIC")

if(WIN32)
    set(CPACK_GENERATOR "WIX")
    set(CPACK_WIX_UPGRADE_GUID "D9A1B1C1-E2F3-4G5H-6I7J-8K9L0M1N2O3P") # Placeholder UUID

    # Ensure compatibility with Windows 8.1 (Standard MSI features)
    #set(CPACK_WIX_PRODUCT_ICON "${CMAKE_SOURCE_DIR}/assets/rasmol.ico")

    # Optional: Add desktop shortcuts if supported by CPack WiX
    set(CPACK_WIX_PROGRAM_MENU_FOLDER "RasMol")
elseif(APPLE)
    set(CPACK_GENERATOR "DragNDrop")
    set(CPACK_DMG_VOLUME_NAME "RasMol")
    set(CPACK_PACKAGE_FILE_NAME "RasMol-${CPACK_PACKAGE_VERSION}-${CMAKE_SYSTEM_PROCESSOR}")
endif()

include(CPack)
