import re

with open('src/pixutils.c', 'r') as f:
    content = f.read()

# Comment out oUpdateLine macro
content = content.replace(
    '#define oUpdateLine  \\\n        dx = -wide;                   \\\n        dptr = dold-wide;             \\\n        tptr = LookUp[wide]+wide;     \\\n        while( dx<0 ) { UpdateAcross(*tptr); tptr--; }       \\\n        do { UpdateAcross(*tptr); tptr++; } while(dx<=wide); \\\n        dold += View.yskip;  fold += View.yskip;             \\\n        dy++;',
    '/* #define oUpdateLine  \\\n        dx = -wide;                   \\\n        dptr = dold-wide;             \\\n        tptr = LookUp[wide]+wide;     \\\n        while( dx<0 ) { UpdateAcross(*tptr); tptr--; }       \\\n        do { UpdateAcross(*tptr); tptr++; } while(dx<=wide); \\\n        dold += View.yskip;  fold += View.yskip;             \\\n        dy++; */'
)

with open('src/pixutils.c', 'w') as f:
    f.write(content)
