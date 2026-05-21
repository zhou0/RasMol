import re

with open('src/render.h', 'r') as f:
    content = f.read()

# 1. Comment out MAXTABLE
content = content.replace('#define MAXTABLE  32641', '/* #define MAXTABLE  32641 */')

# 2. Comment out LookUp and Array in RENDER block
render_block_search = r'''#if defined\(IBMPC\) \|\| defined\(APPLEMAC\)
void __far \* __far \*HashTable;
Byte __far \* __far \*LookUp;
Byte __far \*Array;

#else /\* UNIX or VMS \*/
void \*HashTable\[VOXSIZE\];
Byte \*LookUp\[MAXRAD\];
Byte Array\[MAXTABLE\];
#endif'''

render_block_replace = r'''#if defined(IBMPC) || defined(APPLEMAC)
void __far * __far *HashTable;
/* Byte __far * __far *LookUp; */
/* Byte __far *Array; */

#else /* UNIX or VMS */
void *HashTable[VOXSIZE];
/* Byte *LookUp[MAXRAD]; */
/* Byte Array[MAXTABLE]; */
#endif'''

content = re.sub(render_block_search, render_block_replace, content)

# 3. Comment out LookUp and Array in extern block
extern_block_search = r'''extern Card __far \*ColConst;
#if defined\(IBMPC\) \|\| defined\(APPLEMAC\)
extern void __far \* __far \*HashTable;
extern Byte __far \* __far \*LookUp;
extern Byte __far \*Array;

#else /\* UNIX or VMS \*/
extern void \*HashTable\[VOXSIZE\];
extern Byte \*LookUp\[MAXRAD\];
extern Byte Array\[MAXTABLE\];
#endif'''

extern_block_replace = r'''extern Card __far *ColConst;
#if defined(IBMPC) || defined(APPLEMAC)
extern void __far * __far *HashTable;
/* extern Byte __far * __far *LookUp; */
/* extern Byte __far *Array; */

#else /* UNIX or VMS */
extern void *HashTable[VOXSIZE];
/* extern Byte *LookUp[MAXRAD]; */
/* extern Byte Array[MAXTABLE]; */
#endif'''

content = re.sub(extern_block_search, extern_block_replace, content)

# 4. Update pythag and apythag macros, commenting out old version
pythag_search = r'''#define pythag\(h,x\) \\
           \(\(h\)<MAXRAD\? \\
             \(int\)LookUp\[\(h\)\]\[\(x\)\]: \\
             \(int\)\(.5\+\(sqrt\(\(double\)\(\(h\)\*\(h\)-\(x\)\*\(x\)\)\)\)\)\)'''

pythag_replace = r'''/* #define pythag(h,x) \
           ((h)<MAXRAD? \
             (int)LookUp[(h)][(x)]: \
             (int)(.5+(sqrt((double)((h)*(h)-(x)*(x)))))) */
#define pythag(h,x) ((int)(.5+(sqrt((double)((h)*(h)-(x)*(x))))))'''

content = re.sub(pythag_search, pythag_replace, content)

apythag_search = r'''#define apythag\(h,x\) \\
           \(\(h\)<MAXRAD/2\? \\
             \(int\)LookUp\[\(h\)\]\[\(x\)\]: \\
             \(int\)\(.5\+\(sqrt\(\(double\)\(\(h\)\*\(h\)-\(x\)\*\(x\)\)\)\)\)\)'''

apythag_replace = r'''/* #define apythag(h,x) \
           ((h)<MAXRAD/2? \
             (int)LookUp[(h)][(x)]: \
             (int)(.5+(sqrt((double)((h)*(h)-(x)*(x)))))) */
#define apythag(h,x) ((int)(.5+(sqrt((double)((h)*(h)-(x)*(x))))))'''

content = re.sub(apythag_search, apythag_replace, content)

with open('src/render.h', 'w') as f:
    f.write(content)
