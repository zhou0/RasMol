#!/usr/bin/wish
# RasMol Pure Tcl & Tcl3D Implementation

set script_dir [file dirname [info script]]

# Define UTF-8 sourcing for cross-platform consistency (especially Windows)
proc source_utf8 {file} {
    if {[catch {uplevel 1 [list source -encoding utf-8 $file]} err]} {
        set f [open $file r]
        fconfigure $f -encoding utf-8
        set data [read $f]
        close $f
        uplevel 1 $data
    }
}

# Globals initialization
set rendering_mode "CPU"

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
        "1 1" { rasmol_command "wireframe" }
        "1 2" { rasmol_command "backbone" }
        "1 3" { rasmol_command "sticks" }
        "1 4" { rasmol_command "spacefill" }
        "1 5" { rasmol_command "ball" }
        "6 2" { puts "Manual not available in pure Tcl version." }
    }
}

# Alias for compatibility with rasmol_ui.tcl
proc send_rasmol {cmd} { rasmol_command $cmd }
proc send_rasmol_menu {menu item {state ""}} { rasmol_handle_menu $menu $item $state }

set mouse_last_x 0
set mouse_last_y 0

proc rasmol_mouse_down {x y mask} {
    global mouse_last_x mouse_last_y
    set mouse_last_x $x
    set mouse_last_y $y
}

proc rasmol_mouse_move {x y mask} {
    global mouse_last_x mouse_last_y g_Gui rendering_mode
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
    rasmol_redraw
}

proc rasmol_info {type} {
    global g_Atoms g_Cons
    if {$type eq "molecules"} { return 1 }
    if {$type eq "atoms"} { return [expr {[info exists g_Atoms(numAtoms)] ? $g_Atoms(numAtoms) : 0}] }
    return 0
}

# Redraw dispatcher
proc rasmol_redraw {} {
    global rendering_mode
    if {$rendering_mode eq "GPU"} {
        if {[winfo exists .pw.right.f.togl]} {
            .pw.right.f.togl postredisplay
        }
    } else {
        if {[info commands rasmol_cpu_redraw] ne ""} {
            rasmol_cpu_redraw
        }
    }
}

proc set_rendering_mode {mode} {
    global rendering_mode

    set f .pw.right.f
    if {$mode eq "GPU"} {
        if {[catch {package require tcl3d}]} {
            tk_messageBox -message "Tcl3D not found. GPU mode unavailable."
            set rendering_mode "CPU"
            return
        }
        set rendering_mode "GPU"
        # Hide canvas, show Togl
        grid forget $f.c
        if {![winfo exists $f.togl]} {
            togl $f.togl -width 400 -height 400 \
                -double true -depth true \
                -displayproc rasmol_gpu_draw \
                -reshapeproc rasmol_gpu_reshape \
                -createproc  rasmol_gpu_init

            # Bind mouse events to Togl too
            bind $f.togl <ButtonPress> {rasmol_mouse_down %x %y [get_rasmol_mask %s %b]}
            bind $f.togl <B1-Motion> {rasmol_mouse_move %x %y [get_rasmol_mask %s 1]}
        }
        grid $f.togl -row 0 -column 0 -sticky nsew
    } else {
        set rendering_mode "CPU"
        # Hide Togl, show canvas
        if {[winfo exists $f.togl]} { grid forget $f.togl }
        grid $f.c -row 0 -column 0 -sticky nsew
    }
    rasmol_redraw
}

# Source modules with UTF-8 encoding
source_utf8 [file join $script_dir logo.tcl]
source_utf8 [file join $script_dir rasmol_loc.tcl]
source_utf8 [file join $script_dir rasmol_math.tcl]
source_utf8 [file join $script_dir pdb_parser.tcl]

# Source CPU Renderer and rename its redraw function
source_utf8 [file join $script_dir rasmol_render.tcl]
if {[info commands rasmol_cpu_redraw] eq ""} {
    rename rasmol_redraw rasmol_cpu_redraw
}

# Source GPU module
catch {
    source_utf8 [file join $script_dir rasmol_gpu.tcl]
}

# Source UI
source_utf8 [file join $script_dir rasmol_ui.tcl]

# Add "Rendering Mode" submenu under "Settings"
.menubar.settings add separator
menu .menubar.settings.display -tearoff 0
.menubar.settings add cascade -label "Rendering Mode" -menu .menubar.settings.display
.menubar.settings.display add radiobutton -label "CPU Mode" -variable rendering_mode -value "CPU" -command {set_rendering_mode "CPU"}
.menubar.settings.display add radiobutton -label "GPU Mode" -variable rendering_mode -value "GPU" -command {set_rendering_mode "GPU"}

# Add Language menu under Settings
menu .menubar.settings.lang -tearoff 0
.menubar.settings add cascade -label "Language" -menu .menubar.settings.lang
.menubar.settings.lang add radiobutton -label "English" -variable current_ui_lang -value "English" -command {set_language "English"}
.menubar.settings.lang add radiobutton -label "French" -variable current_ui_lang -value "French" -command {set_language "French"}
.menubar.settings.lang add radiobutton -label "Simplified Chinese" -variable current_ui_lang -value "Simplified Chinese" -command {set_language "Simplified Chinese"}

# Override/Initialize Globals after UI setup
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
set g_WinWidth 400
set g_WinHeight 400
set GL_COLOR_BUFFER_BIT 0x00004000
set GL_DEPTH_BUFFER_BIT 0x00000100

# Override UI's load_molecule to use rasmol_redraw
proc load_molecule {} {
    set types {
        {"PDB Files" {.pdb}}
        {"All Files" *}
    }
    set file [tk_getOpenFile -filetypes $types]
    if {$file ne ""} {
        puts "Opening file: $file"
        rasmol_command "load pdb \"$file\""
        update_status
    }
}

# Localize
localize_ui

# Show window
wm title . "RasMol"

# Initial layout adjustment
update
grid rowconfigure .pw.right.f 0 -weight 1
grid columnconfigure .pw.right.f 0 -weight 1
