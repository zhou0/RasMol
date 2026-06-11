import sys

path = 'gui/tcltk/molecules.tcl'
with open(path, 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if 'proc tclReshapeFunc' in line:
        new_lines.append('proc tclReshapeFunc { toglwin {w ""} {h ""} } {\n')
        new_lines.append('    if {$w eq "" || $h eq ""} {\n')
        new_lines.append('        set w [winfo width $toglwin]\n')
        new_lines.append('        set h [winfo height $toglwin]\n')
        new_lines.append('    }\n')
        new_lines.append('    if {$w <= 1} { set w 400 }\n')
        new_lines.append('    if {$h <= 1} { set h 400 }\n')
    elif 'if { eq "" ||  eq ""}' in line or 'set w [winfo width ]' in line or 'if { <= 1} { set w 400 }' in line:
        continue
    else:
        new_lines.append(line)

with open(path, 'w') as f:
    f.writelines(new_lines)
