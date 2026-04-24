import os

with open('src/command.c', 'r') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines):
    if '#include <pwd.h>' in line:
        new_lines.append('#ifndef _WIN32\n')
        new_lines.append('#include <pwd.h>\n')
        new_lines.append('#endif\n')
    elif 'if( (entry=getpwnam(username)) )' in line:
        new_lines.append('#ifndef _WIN32\n')
        new_lines.append('            if( (entry=getpwnam(username)) )\n')
        new_lines.append('#else\n')
        new_lines.append('            if( 0 )\n')
        new_lines.append('#endif\n')
    elif 'endpwent();' in line:
        new_lines.append('#ifndef _WIN32\n')
        new_lines.append('                endpwent();\n')
        new_lines.append('#endif\n')
    elif 'struct passwd *entry;' in line:
        new_lines.append('#ifndef _WIN32\n')
        new_lines.append('    struct passwd *entry;\n')
        new_lines.append('#endif\n')
    else:
        new_lines.append(line)

with open('src/command.c', 'w') as f:
    f.writelines(new_lines)
