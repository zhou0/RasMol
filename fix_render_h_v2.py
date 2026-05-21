import re

with open('src/render.h', 'r') as f:
    content = f.read()

# 1. Comment out MAXTABLE
content = content.replace('#define MAXTABLE  32641', '/* #define MAXTABLE  32641 */')

# 2. Comment out LookUp and Array in RENDER block
render_block_pattern = r'(#if defined\(IBMPC\) \|\| defined\(APPLEMAC\)\s+void __far \* __far \*HashTable;\s+)(Byte __far \* __far \*LookUp;\s+)(Byte __far \*Array;\s+)(#else /\* UNIX or VMS \*/\s+void \*HashTable\[VOXSIZE\];\s+)(Byte \*LookUp\[MAXRAD\];\s+)(Byte Array\[MAXTABLE\];\s+)(#endif)'
def replace_render_block(match):
    return (match.group(1) + "/* " + match.group(2).strip() + " */\n" +
            "/* " + match.group(3).strip() + " */\n" +
            match.group(4) + "/* " + match.group(5).strip() + " */\n" +
            "/* " + match.group(6).strip() + " */\n" +
            match.group(7))

content = re.sub(render_block_pattern, replace_render_block, content, flags=re.MULTILINE)

# 3. Comment out LookUp and Array in extern block
extern_block_pattern = r'(extern Card __far \*ColConst;\s+#if defined\(IBMPC\) \|\| defined\(APPLEMAC\)\s+extern void __far \* __far \*HashTable;\s+)(extern Byte __far \* __far \*LookUp;\s+)(extern Byte __far \*Array;\s+)(#else /\* UNIX or VMS \*/\s+extern void \*HashTable\[VOXSIZE\];\s+)(extern Byte \*LookUp\[MAXRAD\];\s+)(extern Byte Array\[MAXTABLE\];\s+)(#endif)'
def replace_extern_block(match):
    return (match.group(1) + "/* " + match.group(2).strip() + " */\n" +
            "/* " + match.group(3).strip() + " */\n" +
            match.group(4) + "/* " + match.group(5).strip() + " */\n" +
            "/* " + match.group(6).strip() + " */\n" +
            match.group(7))

content = re.sub(extern_block_pattern, replace_extern_block, content, flags=re.MULTILINE)

# 4. Update pythag and apythag macros, commenting out old version
content = content.replace(
    '#define pythag(h,x) \\\n           ((h)<MAXRAD? \\\n             (int)LookUp[(h)][(x)]: \\\n             (int)(.5+(sqrt((double)((h)*(h)-(x)*(x))))))',
    '/* #define pythag(h,x) \\\n           ((h)<MAXRAD? \\\n             (int)LookUp[(h)][(x)]: \\\n             (int)(.5+(sqrt((double)((h)*(h)-(x)*(x)))))) */\n#define pythag(h,x) ((int)(.5+(sqrt((double)((h)*(h)-(x)*(x))))))'
)

content = content.replace(
    '#define apythag(h,x) \\\n           ((h)<MAXRAD/2? \\\n             (int)LookUp[(h)][(x)]: \\\n             (int)(.5+(sqrt((double)((h)*(h)-(x)*(x))))))',
    '/* #define apythag(h,x) \\\n           ((h)<MAXRAD/2? \\\n             (int)LookUp[(h)][(x)]: \\\n             (int)(.5+(sqrt((double)((h)*(h)-(x)*(x)))))) */\n#define apythag(h,x) ((int)(.5+(sqrt((double)((h)*(h)-(x)*(x))))))'
)

with open('src/render.h', 'w') as f:
    f.write(content)
