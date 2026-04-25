import os
import re

def fix_file(path, old, new):
    with open(path, 'r', encoding='latin-1') as f:
        content = f.read()
    if old in content and new not in content:
        content = content.replace(old, new)
        with open(path, 'w', encoding='latin-1') as f:
            f.write(content)

# Fix sys/time.h in rasmol.c
fix_file('src/rasmol.c', '#include <sys/time.h>', '#ifndef _WIN32\n#include <sys/time.h>\n#endif')

# Fix pwd.h and getpwnam in vector.c, multiple.c (command.c was already fixed partially, let's check)
fix_file('src/vector.c', '#include <pwd.h>', '#ifndef _WIN32\n#include <pwd.h>\n#endif')
fix_file('src/multiple.c', '#include <pwd.h>', '#ifndef _WIN32\n#include <pwd.h>\n#endif')
