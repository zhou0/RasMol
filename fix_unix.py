import re
import os

def fix_rasmol_h(path):
    with open(path, 'r', encoding='latin-1') as f:
        content = f.read()

    # Replace the mess I made or the original
    # Looking for:
    # #ifndef UNIX
    # #define UNIX
    # #endif
    # Or my messed up:
    # #ifndef _WIN32
    # #ifndef UNIX
    # #define UNIX
    # #endif
    # #endif
    # #endif

    pattern = re.compile(r'#ifndef _WIN32\s+#ifndef UNIX\s+#define UNIX\s+#endif\s+#endif\s+#endif', re.DOTALL)
    content = pattern.sub('#ifndef _WIN32\n#ifndef UNIX\n#define UNIX\n#endif\n#endif', content)

    # If it was the original:
    pattern2 = re.compile(r'#ifndef UNIX\s+#define UNIX\s+#endif', re.DOTALL)
    # Only if not already wrapped in _WIN32
    if '#ifndef _WIN32\n#ifndef UNIX' not in content:
        content = pattern2.sub('#ifndef _WIN32\n#ifndef UNIX\n#define UNIX\n#endif\n#endif', content)

    with open(path, 'w', encoding='latin-1') as f:
        f.write(content)

fix_rasmol_h('src/rasmol.h')
fix_rasmol_h('src/txt/rasmol.h')
