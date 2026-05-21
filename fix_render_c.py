import re

with open('src/render.c', 'r') as f:
    content = f.read()

# 1. Comment out InitialiseTables function
initialise_tables_pattern = r'(static void InitialiseTables\( void \)\s+\{.*?\n\})'
content = re.sub(initialise_tables_pattern, r'/*\n\1\n*/', content, flags=re.DOTALL)

# 2. Comment out allocation and checks in InitialiseRenderer
# For Array
content = content.replace(
    'Array = (Byte __far*)_fmalloc(MAXTABLE*sizeof(Byte));',
    '/* Array = (Byte __far*)_fmalloc(MAXTABLE*sizeof(Byte)); */'
)
# For LookUp
content = content.replace(
    'LookUp = (Byte __far* __far*)_fmalloc(MAXRAD*sizeof(Byte __far*));',
    '/* LookUp = (Byte __far* __far*)_fmalloc(MAXRAD*sizeof(Byte __far*)); */'
)
# For the check
content = content.replace(
    'if( !Array || !LookUp || !HashTable || !ColConst )',
    '/* if( !Array || !LookUp || !HashTable || !ColConst ) */\n    if( !HashTable || !ColConst )'
)

# 3. Comment out the call to InitialiseTables()
content = content.replace(
    'InitialiseTables();',
    '/* InitialiseTables(); */'
)

with open('src/render.c', 'w') as f:
    f.write(content)
