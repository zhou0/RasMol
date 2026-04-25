import os
import re

files_to_fix = [
    'src/cif_ctonum.c',
    'src/abstree.c',
    'src/infile.c',
    'src/cif.c',
    'src/command.c',
    'src/molecule.c'
]

def fix_strings_include(path):
    with open(path, 'r', encoding='latin-1') as f:
        content = f.read()

    # Replace #include <strings.h> with a guarded version if it's not already guarded
    # The existing guard looks like:
    # #if defined(IBMPC) || defined(VMS) || defined(APPLEMAC)
    # #include "string_case.h"
    # #else
    # #include <strings.h>
    # #endif

    pattern = re.compile(r'#if defined\(IBMPC\) \|\| defined\(VMS\) \|\| defined\(APPLEMAC\)\s+#include "string_case.h"\s+#else\s+#include <strings.h>\s+#endif', re.DOTALL)
    replacement = '#if defined(IBMPC) || defined(VMS) || defined(APPLEMAC) || defined(_WIN32)\n#include "string_case.h"\n#else\n#include <strings.h>\n#endif'

    if pattern.search(content):
        content = pattern.sub(replacement, content)
    else:
        # Simple case
        content = content.replace('#include <strings.h>', '#ifndef _WIN32\n#include <strings.h>\n#endif')

    with open(path, 'w', encoding='latin-1') as f:
        f.write(content)

for f in files_to_fix:
    fix_strings_include(f)
