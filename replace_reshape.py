import sys
import re

path = 'gui/tcltk/molecules.tcl'
with open(path, 'r') as f:
    content = f.read()

# Match the entire proc from its signature to the end of the newly added block
pattern = re.compile(r'proc tclReshapeFunc \{ toglwin \{w ""\} \{h ""\} \}.*?if \{\$h <= 1\} \{ set h 400 \}', re.DOTALL)

new_proc = """proc tclReshapeFunc { toglwin {w ""} {h ""} } {
    if {$w eq "" || $h eq ""} {
        set w [winfo width $toglwin]
        set h [winfo height $toglwin]
    }
    if {$w <= 1} { set w 400 }
    if {$h <= 1} { set h 400 }"""

if pattern.search(content):
    content = pattern.sub(new_proc, content)
    with open(path, 'w') as f:
        f.write(content)
    print("Cleanup successful")
else:
    print("Pattern not found")
