import os
import re

def fix_file_all(path, old, new):
    with open(path, 'r', encoding='latin-1') as f:
        content = f.read()
    if old in content:
        content = content.replace(old, new)
        with open(path, 'w', encoding='latin-1') as f:
            f.write(content)

# Fix unistd.h
fix_file_all('src/cif.c', '#include <unistd.h>', '#ifndef _WIN32\n#include <unistd.h>\n#endif')
fix_file_all('src/rastxt.c', '#include <unistd.h>', '#ifndef _WIN32\n#include <unistd.h>\n#endif')
fix_file_all('src/rastxt.c', '#include <sysv/unistd.h>', '#ifndef _WIN32\n#include <sysv/unistd.h>\n#endif')
fix_file_all('src/rasmol.c', '#include <unistd.h>', '#ifndef _WIN32\n#include <unistd.h>\n#endif')
fix_file_all('src/rasmol.c', '#include <sysv/unistd.h>', '#ifndef _WIN32\n#include <sysv/unistd.h>\n#endif')
