import sys

file_path = 'gui/tcltk/rasmol_ui.tcl'
with open(file_path, 'r') as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    if "proc send_rasmol_menu" in line:
        new_lines.append(line)
        # Insert get_rasmol_mask after send_rasmol_menu
        new_lines.append("\n")
        new_lines.append("proc get_rasmol_mask {s {b 0}} {\n")
        new_lines.append("    set m 0\n")
        new_lines.append("    if {$b == 1 || ($s & 0x100)} { set m [expr {$m | 0x01}] }\n")
        new_lines.append("    if {$b == 2 || ($s & 0x200)} { set m [expr {$m | 0x02}] }\n")
        new_lines.append("    if {$b == 3 || ($s & 0x400)} { set m [expr {$m | 0x04}] }\n")
        new_lines.append("    if {$s & 0x01} { set m [expr {$m | 0x08}] }\n")
        new_lines.append("    if {$s & 0x04} { set m [expr {$m | 0x10}] }\n")
        new_lines.append("    return $m\n")
        new_lines.append("}\n")
        continue

    if "bind .pw.right.f.c <ButtonPress>" in line:
        new_lines.append(line)
        new_lines.append('    if {[info commands rasmol_mouse_down] ne ""} {\n')
        new_lines.append('        rasmol_mouse_down %x %y [get_rasmol_mask %s %b]\n')
        new_lines.append('    }\n')
        new_lines.append('}\n')
        skip = True
        continue
    if "bind .pw.right.f.c <B1-Motion>" in line:
        new_lines.append(line)
        new_lines.append('    if {[info commands rasmol_mouse_move] ne ""} {\n')
        new_lines.append('        rasmol_mouse_move %x %y [get_rasmol_mask %s 1]\n')
        new_lines.append('    }\n')
        new_lines.append('}\n')
        skip = True
        continue
    if "bind .pw.right.f.c <B2-Motion>" in line:
        new_lines.append(line)
        new_lines.append('    if {[info commands rasmol_mouse_move] ne ""} {\n')
        new_lines.append('        rasmol_mouse_move %x %y [get_rasmol_mask %s 2]\n')
        new_lines.append('    }\n')
        new_lines.append('}\n')
        skip = True
        continue
    if "bind .pw.right.f.c <B3-Motion>" in line:
        new_lines.append(line)
        new_lines.append('    if {[info commands rasmol_mouse_move] ne ""} {\n')
        new_lines.append('        rasmol_mouse_move %x %y [get_rasmol_mask %s 3]\n')
        new_lines.append('    }\n')
        new_lines.append('}\n')
        skip = True
        continue
    if "bind .pw.right.f.c <ButtonRelease>" in line:
        new_lines.append(line)
        new_lines.append('    if {[info commands rasmol_mouse_up] ne ""} {\n')
        new_lines.append('        rasmol_mouse_up %x %y [get_rasmol_mask %s %b]\n')
        new_lines.append('    }\n')
        new_lines.append('}\n')
        skip = True
        continue

    if skip:
        if line.strip() == "}":
            skip = False
        continue

    new_lines.append(line)

with open(file_path, 'w') as f:
    f.writelines(new_lines)
