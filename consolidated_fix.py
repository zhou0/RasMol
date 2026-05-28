import sys

with open('CMakeLists.txt', 'r') as f:
    content = f.read()

# 1. Global macOS RPATH
content = content.replace('set(CMAKE_POSITION_INDEPENDENT_CODE ON)',
                          'set(CMAKE_POSITION_INDEPENDENT_CODE ON)\nset(CMAKE_MACOSX_RPATH ON)')

# 2. CVector Windows Fix (Target names)
search_cv = 'string(REPLACE "set(CMAKE_LIBRARY_OUTPUT_DIRECTORY" "#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY" CV_CMAKE "${CV_CMAKE}")'
replace_cv = """string(REPLACE "set(CMAKE_LIBRARY_OUTPUT_DIRECTORY" "#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY" CV_CMAKE "${CV_CMAKE}")
        # Resolve MSVC duplicate .lib name conflict between CV_static and CV_shared
        string(REPLACE "set_target_properties(CV_static PROPERTIES OUTPUT_NAME CVector)" "set_target_properties(CV_static PROPERTIES OUTPUT_NAME CVectorStatic)" CV_CMAKE "${CV_CMAKE}")
        string(REPLACE "set_target_properties(CV_static PROPERTIES OUTPUT_NAME \\"CVector\\")" "set_target_properties(CV_static PROPERTIES OUTPUT_NAME \\"CVectorStatic\\")" CV_CMAKE "${CV_CMAKE}")"""
content = content.replace(search_cv, replace_cv)

# 3. rasmol_tcl macOS Bundle RPATH
search_bundle = 'add_executable(rasmol_tcl MACOSX_BUNDLE ${RASMOL_TCL_SOURCES})'
replace_bundle = """add_executable(rasmol_tcl MACOSX_BUNDLE ${RASMOL_TCL_SOURCES})
        set_target_properties(rasmol_tcl PROPERTIES
            INSTALL_RPATH "@executable_path/../Frameworks"
        )"""
content = content.replace(search_bundle, replace_bundle)

# 4. macOS Installation into Bundle
search_inst = 'install(TARGETS rasmol_tcl BUNDLE DESTINATION .)'
replace_inst = """install(TARGETS rasmol_tcl BUNDLE DESTINATION .)
        # Install internal shared libraries into the bundle
        install(TARGETS cbf CQRlib CV_shared CNearTree
                DESTINATION RasMol.app/Contents/Frameworks)"""
content = content.replace(search_inst, replace_inst)

with open('CMakeLists.txt', 'w') as f:
    f.write(content)
print("Success")
