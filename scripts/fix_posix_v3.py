import os
import re

def fix_file_all(path, old, new):
    with open(path, 'r', encoding='latin-1') as f:
        content = f.read()
    if old in content:
        content = content.replace(old, new)
        with open(path, 'w', encoding='latin-1') as f:
            f.write(content)

# Fix termios.h
fix_file_all('src/gtkwin.c', '#include <termios.h>', '#ifndef _WIN32\n#include <termios.h>\n#endif')
fix_file_all('src/rastxt.c', '#include <termios.h>', '#ifndef _WIN32\n#include <termios.h>\n#endif')
fix_file_all('src/rasmol.c', '#include <termios.h>', '#ifndef _WIN32\n#include <termios.h>\n#endif')
