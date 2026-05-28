import sys
import re

with open('CMakeLists.txt', 'r') as f:
    content = f.read()

# 1. Fix duplicate CMAKE_MACOSX_RPATH
content = re.sub(r'(set\(CMAKE_MACOSX_RPATH ON\)\n)+', 'set(CMAKE_MACOSX_RPATH ON)\n', content)

# 2. Fix duplicate INSTALL_RPATH for rasmol_tcl
content = re.sub(r'(set_target_properties\(rasmol_tcl PROPERTIES\s+INSTALL_RPATH "@executable_path/\.\./Frameworks"\s+\)\s+)+',
                 r'set_target_properties(rasmol_tcl PROPERTIES\n            INSTALL_RPATH "@executable_path/../Frameworks"\n        )\n        ', content)

# 3. Fix duplicate install commands
# Matches the specific comment and following install command, repeated
pattern = r'(# Install internal shared libraries into the bundle\s+install\(TARGETS cbf CQRlib CV_shared CNearTree\s+DESTINATION RasMol\.app/Contents/Frameworks\)\s+)+'
content = re.sub(pattern, '# Install internal shared libraries into the bundle\n        install(TARGETS cbf CQRlib CV_shared CNearTree\n                DESTINATION RasMol.app/Contents/Frameworks)\n        ', content)

# 4. Double check CV_shared
content = content.replace('set(CVECTOR_LIBRARY CV_static CACHE STRING "" FORCE)', 'set(CVECTOR_LIBRARY CV_shared CACHE STRING "" FORCE)')

with open('CMakeLists.txt', 'w') as f:
    f.write(content)
print("Success")
