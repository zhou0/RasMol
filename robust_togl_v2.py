import sys
import re

def fix_reshape(path):
    with open(path, 'r') as f:
        content = f.read()

    old_proc = 'proc tclReshapeFunc { toglwin w h } {'
    new_proc = """proc tclReshapeFunc { toglwin {w ""} {h ""} } {
    if {$w eq "" || $h eq ""} {
        set w [winfo width $toglwin]
        set h [winfo height $toglwin]
    }
    if {$w <= 1} { set w 400 }
    if {$h <= 1} { set h 400 }"""

    if old_proc in content:
        content = content.replace(old_proc, new_proc)
        with open(path, 'w') as f:
            f.write(content)
        print(f"Updated reshape in {path}")
    else:
        print(f"Could not find reshape in {path}")

def fix_probe(path, togl_widget, callbacks):
    with open(path, 'r') as f:
        content = f.read()

    probe_logic = f'''
# Exhaustive Togl initialization probe
set togl_success 0
set togl_error "Unknown error"
foreach cb_set {{
    {{-displaycommand {callbacks[0]} -reshapecommand {callbacks[1]} -createcommand {callbacks[2]}}}
    {{-displayproc {callbacks[0]} -reshapeproc {callbacks[1]} -createproc {callbacks[2]}}}
}} {{
    foreach vis_set {{
        {{-double 1 -depth 1 -rgba 1}}
        {{-double 1 -depth 1}}
        {{-double 0 -depth 1}}
        {{-double 1 -depth 0}}
        {{-double 0 -depth 0}}
        {{-rgba 1}}
        {{}}
    }} {{
        if {{![catch {{togl {togl_widget} -width 400 -height 400 {{*}}$cb_set {{*}}$vis_set}} togl_msg]}} {{
            set togl_success 1
            break
        }} else {{
            set togl_error $togl_msg
        }}
    }}
    if {{$togl_success}} break
}}

if {{!$togl_success}} {{
    # Final attempt with absolutely minimal options
    if {{[catch {{togl {togl_widget} -width 400 -height 400}} final_msg]}} {{
        error "Fatal Togl Error: $togl_error (Minimal attempt: $final_msg)"
    }}
}}
'''
    # Match the entire togl block in molecules.tcl
    if 'molecules.tcl' in path:
        pattern = re.compile(r'togl\s+\$frTogl\.toglwin.*?pack\s+\$frTogl\.toglwin\s+-side\s+top\s+-expand\s+1\s+-fill\s+both', re.DOTALL)
    else:
        # Match togl block in rasmol.tcl
        pattern = re.compile(r'togl\s+\$f\.togl\s+-width\s+400\s+-height\s+400\s+-double\s+true\s+-depth\s+true\s+.*?init', re.DOTALL)

    if pattern.search(content):
        if 'molecules.tcl' in path:
            new_content = pattern.sub(probe_logic.strip() + "\npack $frTogl.toglwin -side top -expand 1 -fill both", content)
        else:
            new_content = pattern.sub(probe_logic.strip(), content)
        with open(path, 'w') as f:
            f.write(new_content)
        print(f"Updated probe in {path}")
    else:
        print(f"Could not find togl block in {path}")

fix_reshape('gui/tcltk/molecules.tcl')
fix_probe('gui/tcltk/molecules.tcl', '$frTogl.toglwin', ['tclDisplayFunc', 'tclReshapeFunc', 'tclCreateFunc'])
fix_probe('gui/tcltk/rasmol.tcl', '$f.togl', ['rasmol_gpu_draw', 'rasmol_gpu_reshape', 'rasmol_gpu_init'])
