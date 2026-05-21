import re

with open('src/render.c', 'r') as f:
    content = f.read()

# Fix the nested comments in the commented out block
block_search = r'/\*\nstatic void InitialiseTables\( void \)\s+\{.*?\n\}\n\*/'
match = re.search(block_search, content, re.DOTALL)
if match:
    block = match.group(0)
    # Replace internal /* with / * and */ with * /
    # Skip the very first and last /* and */
    inner = block[3:-3]
    inner = inner.replace('/*', '/ *').replace('*/', '* /')
    new_block = '/*' + inner + '*/'
    content = content.replace(block, new_block)

with open('src/render.c', 'w') as f:
    f.write(content)
