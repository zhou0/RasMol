#!/usr/bin/wish
# RasMol Pure Tcl & Tcl3D Implementation

set script_dir [file dirname [info script]]

proc source_utf8 {file} {
    if {[catch {uplevel 1 [list source -encoding utf-8 $file]} err]} {
        set f [open $file r]; fconfigure $f -encoding utf-8; set d [read $f]; close $f; uplevel 1 $d
    }
}

set ::rendering_mode "CPU"
set ::display_mode 4

proc rasmol_command {cmd} {
    set args [split $cmd]; set c [lindex $args 0]
    switch -exact -- $c {
        "load" {
            set file [string trim [lindex $args 3] "\""]
            if {$file eq ""} { set file [string trim [lindex $args 2] "\""] }
            if {$file eq ""} { set file [string trim [lindex $args 1] "\""] }
            if {[file exists $file]} { ReadPDB $file; CalcBBox; SetViewPoint; rasmol_redraw }
        }
        "rotate" {
            set axis [lindex $args 1]; set val [lindex $args 2]
            if {$axis eq "x"} { set ::g_Gui(rotX) [expr {$::g_Gui(rotX) + $val}] }
            if {$axis eq "y"} { set ::g_Gui(rotY) [expr {$::g_Gui(rotY) + $val}] }
            if {$axis eq "z"} { set ::g_Gui(rotZ) [expr {$::g_Gui(rotZ) + $val}] }
            rasmol_redraw
        }
        "cpk" - "spacefill" { set ::display_mode 4; rasmol_redraw }
        "wireframe" { set ::display_mode 1; rasmol_redraw }
        "backbone" { set ::display_mode 2; rasmol_redraw }
        "sticks" { set ::display_mode 3; rasmol_redraw }
        "ball" { set ::display_mode 5; rasmol_redraw }
        "reset" { SetViewPoint; rasmol_redraw }
    }
}

proc rasmol_handle_menu {menu item {state ""}} {
    switch -exact -- "$menu $item" {
        "1 1" { rasmol_command "wireframe" }
        "1 2" { rasmol_command "backbone" }
        "1 3" { rasmol_command "sticks" }
        "1 4" { rasmol_command "spacefill" }
        "1 5" { rasmol_command "ball" }
        "6 2" { puts "Manual not available." }
    }
}

proc send_rasmol {cmd} { rasmol_command $cmd }
proc send_rasmol_menu {menu item {state ""}} { rasmol_handle_menu $menu $item $state }

set ::mouse_last_x 0; set ::mouse_last_y 0
proc rasmol_mouse_down {x y mask} { set ::mouse_last_x $x; set ::mouse_last_y $y }
proc rasmol_mouse_move {x y mask} {
    set dx [expr {$x - $::mouse_last_x}]; set dy [expr {$y - $::mouse_last_y}]
    if {$mask & 0x01} {
        set ::g_Gui(rotY) [expr {$::g_Gui(rotY) + $dx}]; set ::g_Gui(rotX) [expr {$::g_Gui(rotX) + $dy}]; rasmol_redraw
    }
    set ::mouse_last_x $x; set ::mouse_last_y $y
}
proc rasmol_mouse_up {x y mask} {}
proc rasmol_resize {w h} { rasmol_redraw }
proc rasmol_info {type} {
    if {$type eq "molecules"} { return 1 }
    if {$type eq "atoms"} { return [expr {[info exists ::g_Atoms(numAtoms)] ? $::g_Atoms(numAtoms) : 0}] }
    return 0
}

proc rasmol_redraw {} {
    if {$::rendering_mode eq "GPU" && [winfo exists .pw.right.f.togl]} { .pw.right.f.togl postredisplay } else { rasmol_cpu_redraw }
}

proc set_rendering_mode {mode} {
    set f .pw.right.f
    if {$mode eq "GPU"} {
        if {[catch {package require tcl3d}]} { tk_messageBox -message "Tcl3D not found."; return }
        set ::rendering_mode "GPU"; grid forget $f.c
        if {![winfo exists $f.togl]} {
            set togl_ver 1
            if {![catch {package require Togl}]} {
                set togl_ver [lindex [split [package require Togl] "."] 0]
            }
            if {$togl_ver >= 2} {
                set togl_opts [list -displaycommand rasmol_gpu_draw -reshapecommand rasmol_gpu_reshape -createcommand rasmol_gpu_init]
            } else {
                set togl_opts [list -displayproc rasmol_gpu_draw -reshapeproc rasmol_gpu_reshape -createproc rasmol_gpu_init]
            }
            set togl_success 0
            foreach {dbl dep} {1 1 0 1 1 0 0 0} {
                if {![catch {togl $f.togl -width 400 -height 400 \
                                  -double $dbl -depth $dep {*}$togl_opts} msg]} {
                    set togl_success 1
                    break
                }
            }
            if {!$togl_success} {
                error "Couldn't configure togl widget: $msg"
            }
            bind $f.togl <ButtonPress> {rasmol_mouse_down %x %y [get_rasmol_mask %s %b]}
            bind $f.togl <B1-Motion> {rasmol_mouse_move %x %y [get_rasmol_mask %s 1]}
        }
        grid $f.togl -row 0 -column 0 -sticky nsew
    } else {
        set ::rendering_mode "CPU"; if {[winfo exists $f.togl]} { grid forget $f.togl }
        grid $f.c -row 0 -column 0 -sticky nsew
    }
    rasmol_redraw
}

source_utf8 [file join $script_dir logo.tcl]
source_utf8 [file join $script_dir rasmol_loc.tcl]
source_utf8 [file join $script_dir rasmol_math.tcl]
source_utf8 [file join $script_dir pdb_parser.tcl]
source_utf8 [file join $script_dir rasmol_render.tcl]
if {[info commands rasmol_cpu_redraw] eq ""} { rename rasmol_redraw rasmol_cpu_redraw }
catch { source_utf8 [file join $script_dir rasmol_gpu.tcl] }
source_utf8 [file join $script_dir rasmol_ui.tcl]

set ::last_sb_v 0.5; set ::last_sb_h 0.5
.menubar.settings add separator
menu .menubar.settings.display -tearoff 0
.menubar.settings add cascade -label [tr "RenderingMode"] -menu .menubar.settings.display
.menubar.settings.display add radiobutton -label "CPU Mode" -variable ::rendering_mode -value "CPU" -command {set_rendering_mode "CPU"}
.menubar.settings.display add radiobutton -label "GPU Mode" -variable ::rendering_mode -value "GPU" -command {set_rendering_mode "GPU"}

menu .menubar.settings.lang -tearoff 0
.menubar.settings add cascade -label [tr "Language"] -menu .menubar.settings.lang
foreach l {"English" "Simplified Chinese"} { .menubar.settings.lang add radiobutton -label $l -variable ::current_ui_lang -value $l -command "set_language {$l}" }

set ::g_Gui(rotX) 0.0; set ::g_Gui(rotY) 0.0; set ::g_Gui(rotZ) 0.0
set ::g_Gui(rotCenX) 0.0; set ::g_Gui(rotCenY) 0.0; set ::g_Gui(rotCenZ) 0.0
set ::g_Gui(zoom) 20.0; set ::g_Gui(distX) 0.0; set ::g_Gui(distY) 0.0; set ::g_Gui(distZ) 0.0; set ::g_Gui(camDist) 5.0
set ::g_WinWidth 400; set ::g_WinHeight 400
set ::GL_COLOR_BUFFER_BIT 0x00004000; set ::GL_DEPTH_BUFFER_BIT 0x00000100

proc load_molecule {} {
    set file [tk_getOpenFile -filetypes {{"PDB Files" {.pdb}} {"All Files" *}}]
    if {$file ne ""} { rasmol_command "load pdb \"$file\""; update_status }
}
localize_ui; wm title . "RasMol"; update
grid rowconfigure .pw.right.f 0 -weight 1; grid columnconfigure .pw.right.f 0 -weight 1
