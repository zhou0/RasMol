import re

with open('src/x11win.c', 'r', encoding='latin-1') as f:
    content = f.read()

# Look for the definition:
# static int digittoint(int c) {
#     ...
# }

pattern = re.compile(r'(static int digittoint\(int c\) \{.*?^\})', re.DOTALL | re.MULTILINE)
replacement = r'#ifndef __APPLE__\n\1\n#endif'

content = pattern.sub(replacement, content)

with open('src/x11win.c', 'w', encoding='latin-1') as f:
    f.write(content)
