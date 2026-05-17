import sys

file_path = 'gui/tcltk/rasmol_ui.tcl'
with open(file_path, 'r') as f:
    content = f.read()

# Fix the extra closing braces introduced by the previous script
# Each bind block now ends with two '}' instead of one because of the logic error in the python script.
# Actually, looking at the sed output:
# bind ... {
#     ...
# }
# }
content = content.replace("}\n}\nbind", "}\nbind")
content = content.replace("}\n}\nbind", "}\nbind") # twice for safety
content = content.replace("}\n}\nbind", "}\nbind")
content = content.replace("}\n}\nbind", "}\nbind")

# Specifically for the last bind block before "bind . <KeyPress>"
content = content.replace("}\n}\nbind . <KeyPress>", "}\nbind . <KeyPress>")

with open(file_path, 'w') as f:
    f.write(content)
