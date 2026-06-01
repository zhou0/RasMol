#!/usr/bin/wish
# RasMol Pure Tcl Implementation

set script_dir [file dirname [info script]]

# Globals initialization
set g_Gui(rotX) 0.0
set g_Gui(rotY) 0.0
set g_Gui(rotZ) 0.0
set g_Gui(rotCenX) 0.0
set g_Gui(rotCenY) 0.0
set g_Gui(rotCenZ) 0.0
set g_Gui(zoom) 20.0
set g_Gui(distX) 0.0
set g_Gui(distY) 0.0
set g_Gui(distZ) 0.0
set g_Gui(camDist) 5.0

set display_mode 4
set current_ui_lang "English"
set rasmol_canvas_width 400
set rasmol_canvas_height 400

# Stub/Redefine C bridge functions
proc rasmol_register_photo {name} {}

proc rasmol_command {cmd} {
    global g_Gui display_mode
    set args [split $cmd]
    set c [lindex $args 0]
    switch -exact -- $c {
        "load" {
            set file [string trim [lindex $args 3] "\""]
            if {$file eq ""} { set file [lindex $args 2] }
            if {[file exists $file]} {
                ReadPDB $file
                CalcBBox
                SetViewPoint
                rasmol_redraw
            }
        }
        "rotate" {
            set axis [lindex $args 1]
            set val [lindex $args 2]
            if {$axis eq "x"} { set g_Gui(rotX) [expr {$g_Gui(rotX) + $val}] }
            if {$axis eq "y"} { set g_Gui(rotY) [expr {$g_Gui(rotY) + $val}] }
            if {$axis eq "z"} { set g_Gui(rotZ) [expr {$g_Gui(rotZ) + $val}] }
            rasmol_redraw
        }
        "cpk" - "spacefill" {
            set display_mode 4
            rasmol_redraw
        }
        "wireframe" {
            set display_mode 1
            rasmol_redraw
        }
        "backbone" {
            set display_mode 2
            rasmol_redraw
        }
        "sticks" {
            set display_mode 3
            rasmol_redraw
        }
        "ball" {
            set display_mode 5
            rasmol_redraw
        }
        "reset" {
            SetViewPoint
            rasmol_redraw
        }
    }
}

proc rasmol_handle_menu {menu item {state ""}} {
    switch -exact -- "$menu $item" {
        "1 0" { rasmol_command "wireframe" }
        "1 1" { rasmol_command "backbone" }
        "1 2" { rasmol_command "sticks" }
        "1 3" { rasmol_command "spacefill" }
        "1 4" { rasmol_command "ball" }
        "6 2" { puts "Manual not available in pure Tcl version." }
    }
}

set mouse_last_x 0
set mouse_last_y 0

proc rasmol_mouse_down {x y mask} {
    global mouse_last_x mouse_last_y
    set mouse_last_x $x
    set mouse_last_y $y
}

proc rasmol_mouse_move {x y mask} {
    global mouse_last_x mouse_last_y g_Gui
    set dx [expr {$x - $mouse_last_x}]
    set dy [expr {$y - $mouse_last_y}]

    if {$mask & 0x01} {
        set g_Gui(rotY) [expr {$g_Gui(rotY) + $dx}]
        set g_Gui(rotX) [expr {$g_Gui(rotX) + $dy}]
        rasmol_redraw
    }

    set mouse_last_x $x
    set mouse_last_y $y
}

proc rasmol_mouse_up {x y mask} {}
proc rasmol_key_press {key} {}
proc rasmol_resize {w h} {
    global rasmol_canvas_width rasmol_canvas_height
    set rasmol_canvas_width $w
    set rasmol_canvas_height $h
    rasmol_redraw
}

proc rasmol_info {type} {
    global g_Atoms g_Cons
    if {$type eq "molecules"} { return 1 }
    if {$type eq "atoms"} { return [expr {[info exists g_Atoms(numAtoms)] ? $g_Atoms(numAtoms) : 0}] }
    return 0
}

# Source modules
source [file join $script_dir logo.tcl]
source [file join $script_dir rasmol_loc.tcl]
source [file join $script_dir rasmol_math.tcl]
source [file join $script_dir pdb_parser.tcl]
source [file join $script_dir rasmol_render.tcl]

# Source UI
source [file join $script_dir rasmol_ui.tcl]

# Override UI's load_molecule to use rasmol_redraw
proc load_molecule {} {
    set types {
        {"PDB Files" {.pdb}}
        {"All Files" *}
    }
    set file [tk_getOpenFile -filetypes $types]
    if {$file ne ""} {
        .status.lbl configure -text "Loading $file..."
        update
        rasmol_command "load pdb \"$file\""
        update_status
    }
}

# Localize
localize_ui

# Show window
wm title . "RasMol Pure Tcl"

# Additional RasMol commands
proc background {color} {
    .pw.right.f.c configure -bg $color
}
