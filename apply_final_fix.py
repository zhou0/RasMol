import sys

path = 'gui/tcltk/molecules.tcl'
with open(path, 'r') as f:
    lines = f.readlines()

out = []
skip = 0
for line in lines:
    if skip > 0:
        skip -= 1
        continue
    if 'proc tclReshapeFunc { toglwin w h } {' in line:
        out.append('proc tclReshapeFunc { toglwin {w ""} {h ""} } {\n')
        out.append('    if {$w eq "" || $h eq ""} {\n')
        out.append('        set w [winfo width $toglwin]\n')
        out.append('        set h [winfo height $toglwin]\n')
        out.append('    }\n')
        out.append('    if {$w <= 1} { set w 400 }\n')
        out.append('    if {$h <= 1} { set h 400 }\n')
    else:
        out.append(line)

with open(path, 'w') as f:
    f.writelines(out)
