package require Tk
package require Ttk

puts "Starting RasMol ..."

# Main Window setup
wm title . "RasMol"
wm geometry . 1024x768

# Theme selection (Tile/Ttk)
ttk::style theme use clam

# Menu Bar
menu .menubar
. configure -menu .menubar

# File Menu
menu .menubar.file -tearoff 0
.menubar add cascade -label "File" -menu .menubar.file
.menubar.file add command -label "Open..." -command {load_molecule}
.menubar.file add command -label "Save As..." -command {send_rasmol_menu 0 2}
.menubar.file add command -label "Close" -command {send_rasmol_menu 0 3}
.menubar.file add separator
.menubar.file add command -label "Exit" -command {exit}

# Display Menu
menu .menubar.display -tearoff 0
.menubar add cascade -label "Display" -menu .menubar.display
.menubar.display add radiobutton -label "Wireframe" -variable display_mode -value 1 -command {send_rasmol_menu 1 1}
.menubar.display add radiobutton -label "Backbone" -variable display_mode -value 2 -command {send_rasmol_menu 1 2}
.menubar.display add radiobutton -label "Sticks" -variable display_mode -value 3 -command {send_rasmol_menu 1 3}
.menubar.display add radiobutton -label "Spacefill" -variable display_mode -value 4 -command {send_rasmol_menu 1 4}
.menubar.display add radiobutton -label "Ball & Stick" -variable display_mode -value 5 -command {send_rasmol_menu 1 5}
.menubar.display add radiobutton -label "Ribbons" -variable display_mode -value 6 -command {send_rasmol_menu 1 6}
.menubar.display add radiobutton -label "Strands" -variable display_mode -value 7 -command {send_rasmol_menu 1 7}
.menubar.display add radiobutton -label "Cartoons" -variable display_mode -value 8 -command {send_rasmol_menu 1 8}
.menubar.display add radiobutton -label "Molecular Surface" -variable display_mode -value 9 -command {send_rasmol_menu 1 9}

# Colours Menu
menu .menubar.colours -tearoff 0
.menubar add cascade -label "Colours" -menu .menubar.colours
.menubar.colours add radiobutton -label "Monochrome" -variable colour_mode -value 1 -command {send_rasmol_menu 2 1}
.menubar.colours add radiobutton -label "CPK" -variable colour_mode -value 2 -command {send_rasmol_menu 2 2}
.menubar.colours add radiobutton -label "Shapely" -variable colour_mode -value 3 -command {send_rasmol_menu 2 3}
.menubar.colours add radiobutton -label "Group" -variable colour_mode -value 4 -command {send_rasmol_menu 2 4}
.menubar.colours add radiobutton -label "Chain" -variable colour_mode -value 5 -command {send_rasmol_menu 2 5}
.menubar.colours add radiobutton -label "Temperature" -variable colour_mode -value 6 -command {send_rasmol_menu 2 6}
.menubar.colours add radiobutton -label "Structure" -variable colour_mode -value 7 -command {send_rasmol_menu 2 7}
.menubar.colours add radiobutton -label "User" -variable colour_mode -value 8 -command {send_rasmol_menu 2 8}
.menubar.colours add radiobutton -label "Model" -variable colour_mode -value 9 -command {send_rasmol_menu 2 9}
.menubar.colours add radiobutton -label "Alt" -variable colour_mode -value 10 -command {send_rasmol_menu 2 10}

# Export Menu
menu .menubar.export -tearoff 0
.menubar add cascade -label "Export" -menu .menubar.export
.menubar.export add command -label "BMP..." -command {send_rasmol_menu 5 1}
.menubar.export add command -label "GIF..." -command {send_rasmol_menu 5 2}
.menubar.export add command -label "IRIS..." -command {send_rasmol_menu 5 3}
.menubar.export add command -label "PPM..." -command {send_rasmol_menu 5 4}
.menubar.export add command -label "Sun Raster..." -command {send_rasmol_menu 5 5}
.menubar.export add command -label "PostScript..." -command {send_rasmol_menu 5 6}
.menubar.export add command -label "PICT..." -command {send_rasmol_menu 5 7}
.menubar.export add command -label "Vector PS..." -command {send_rasmol_menu 5 8}
.menubar.export add command -label "MolScript..." -command {send_rasmol_menu 5 9}
.menubar.export add command -label "Kinemage..." -command {send_rasmol_menu 5 10}
.menubar.export add command -label "POVRay 3..." -command {send_rasmol_menu 5 11}
.menubar.export add command -label "VRML..." -command {send_rasmol_menu 5 12}
.menubar.export add command -label "Ramachandran..." -command {send_rasmol_menu 5 13}
.menubar.export add command -label "Render3D..." -command {send_rasmol_menu 5 14}
.menubar.export add command -label "Script..." -command {send_rasmol_menu 5 15}

# Options Menu
menu .menubar.options -tearoff 0
.menubar add cascade -label "Options" -menu .menubar.options

if {[info commands rasmol_info] ne ""} {
    set has_vtk [rasmol_info vtk]
} else {
    set has_vtk 0
}

if {$has_vtk} {
    menu .menubar.options.rendering -tearoff 0
    .menubar.options add cascade -label "Rendering" -menu .menubar.options.rendering
    .menubar.options.rendering add radiobutton -label "OpenGL Mode" -variable opengl_mode -value 1 -command {toggle_opengl}
    .menubar.options add radiobutton -label "Raster Mode" -variable opengl_mode -value 0 -command {toggle_opengl}
    .menubar.options add separator
}

.menubar.options add checkbutton -label "Slab Mode" -variable use_slab -command {global use_slab; send_rasmol_menu 3 1 $use_slab}
.menubar.options add checkbutton -label "Hydrogens" -variable show_h -command {global show_h; send_rasmol_menu 3 2 $show_h}
.menubar.options add checkbutton -label "Hetero Atoms" -variable show_het -command {global show_het; send_rasmol_menu 3 3 $show_het}
.menubar.options add checkbutton -label "Specular" -variable use_spec -command {global use_spec; send_rasmol_menu 3 4 $use_spec}
.menubar.options add checkbutton -label "Shadows" -variable use_shadow -command {global use_shadow; send_rasmol_menu 3 5 $use_shadow}
.menubar.options add checkbutton -label "Stereo" -variable use_stereo -command {global use_stereo; send_rasmol_menu 3 6 $use_stereo}
.menubar.options add checkbutton -label "Labels" -variable show_labels -command {global show_labels; send_rasmol_menu 3 7 $show_labels}

# Settings Menu
menu .menubar.settings -tearoff 0
.menubar add cascade -label "Settings" -menu .menubar.settings
.menubar.settings add radiobutton -label "Pick Off" -variable pick_mode -value 1 -command {send_rasmol_menu 4 1}
.menubar.settings add radiobutton -label "Pick Ident" -variable pick_mode -value 2 -command {send_rasmol_menu 4 2}
.menubar.settings add radiobutton -label "Pick Distance" -variable pick_mode -value 3 -command {send_rasmol_menu 4 3}
.menubar.settings add radiobutton -label "Pick Monitor" -variable pick_mode -value 4 -command {send_rasmol_menu 4 4}
.menubar.settings add radiobutton -label "Pick Angle" -variable pick_mode -value 5 -command {send_rasmol_menu 4 5}
.menubar.settings add radiobutton -label "Pick Torsion" -variable pick_mode -value 6 -command {send_rasmol_menu 4 6}
.menubar.settings add radiobutton -label "Pick Label" -variable pick_mode -value 7 -command {send_rasmol_menu 4 7}
.menubar.settings add radiobutton -label "Pick Centre" -variable pick_mode -value 8 -command {send_rasmol_menu 4 8}
.menubar.settings add radiobutton -label "Pick Coord" -variable pick_mode -value 9 -command {send_rasmol_menu 4 9}
.menubar.settings add radiobutton -label "Pick Bond" -variable pick_mode -value 10 -command {send_rasmol_menu 4 10}
.menubar.settings add separator
.menubar.settings add radiobutton -label "Rotate Bond" -variable rot_mode -value 11 -command {send_rasmol_menu 4 11}
.menubar.settings add radiobutton -label "Rotate Molecule" -variable rot_mode -value 12 -command {send_rasmol_menu 4 12}
.menubar.settings add radiobutton -label "Rotate All" -variable rot_mode -value 13 -command {send_rasmol_menu 4 13}

.menubar.settings add separator
menu .menubar.settings.mouse -tearoff 0
.menubar.settings add cascade -label "Mouse Mode" -menu .menubar.settings.mouse
.menubar.settings.mouse add radiobutton -label "RasMol" -variable mouse_mode -value rasmol -command {send_rasmol "set mouse rasmol"}
.menubar.settings.mouse add radiobutton -label "Insight" -variable mouse_mode -value insight -command {send_rasmol "set mouse insight"}
.menubar.settings.mouse add radiobutton -label "Quanta" -variable mouse_mode -value quanta -command {send_rasmol "set mouse quanta"}

# Help Menu
menu .menubar.help -tearoff 0
.menubar add cascade -label "Help" -menu .menubar.help
.menubar.help add command -label "About RasMol" -command {show_about}
.menubar.help add command -label "User Manual" -command {send_rasmol_menu 6 2}

# Main layout using ttk::panedwindow
ttk::panedwindow .pw -orient horizontal
pack .pw -fill both -expand yes

# Left control panel
ttk::frame .pw.left -padding 5 -width 200
.pw add .pw.left

ttk::labelframe .pw.left.opts -text "Quick Controls" -padding 5
pack .pw.left.opts -fill x -side top

ttk::button .pw.left.opts.reset -text "Reset View" -command {send_rasmol "reset"}
pack .pw.left.opts.reset -pady 2 -fill x

ttk::button .pw.left.opts.default -text "Default View" -command {
    send_rasmol "backbone"
    send_rasmol "colour chain"
}
pack .pw.left.opts.default -pady 2 -fill x

# Right side: Visualization and Command entry
ttk::frame .pw.right
.pw add .pw.right

# RasMol Canvas Area with Rotation Scrollbars
set rasmol_img [image create photo rasmol_view]
ttk::frame .pw.right.f -relief sunken -borderwidth 2
pack .pw.right.f -fill both -expand yes -padx 5 -pady 5

canvas .pw.right.f.c -highlightthickness 0 -bg black -cursor crosshair
ttk::scrollbar .pw.right.f.vsb -orient vertical -command {rotate_molecule v}
ttk::scrollbar .pw.right.f.hsb -orient horizontal -command {rotate_molecule h}

grid .pw.right.f.c -row 0 -column 0 -sticky nsew
grid .pw.right.f.vsb -row 0 -column 1 -sticky ns
grid .pw.right.f.hsb -row 1 -column 0 -sticky ew

grid rowconfigure .pw.right.f 0 -weight 1
grid columnconfigure .pw.right.f 0 -weight 1

.pw.right.f.c create image 0 0 -image $rasmol_img -anchor nw -tags rasmol_image

# Set initial thumb position to center (0.5)
.pw.right.f.vsb set 0.45 0.55
.pw.right.f.hsb set 0.45 0.55

# Register the photo image with the C bridge
if {[info commands rasmol_register_photo] ne ""} {
    rasmol_register_photo rasmol_view
}

# Mouse and Keyboard Interaction
proc get_rasmol_mask {s {b 0}} {
    set m 0
    if {$b == 1 || ($s & 0x100)} { set m [expr {$m | 0x01}] }
    if {$b == 2 || ($s & 0x200)} { set m [expr {$m | 0x02}] }
    if {$b == 3 || ($s & 0x400)} { set m [expr {$m | 0x04}] }
    if {$s & 0x01} { set m [expr {$m | 0x08}] }
    if {$s & 0x04} { set m [expr {$m | 0x10}] }
    return $m
}

bind .pw.right.f.c <ButtonPress> {
    if {[info commands rasmol_mouse_down] ne ""} {
        rasmol_mouse_down %x %y [get_rasmol_mask %s %b]
    }
}
bind .pw.right.f.c <B1-Motion> {
    if {[info commands rasmol_mouse_move] ne ""} {
        rasmol_mouse_move %x %y [get_rasmol_mask %s 1]
    }
}
bind .pw.right.f.c <B2-Motion> {
    if {[info commands rasmol_mouse_move] ne ""} {
        rasmol_mouse_move %x %y [get_rasmol_mask %s 2]
    }
}
bind .pw.right.f.c <B3-Motion> {
    if {[info commands rasmol_mouse_move] ne ""} {
        rasmol_mouse_move %x %y [get_rasmol_mask %s 3]
    }
}
bind .pw.right.f.c <ButtonRelease> {
    if {[info commands rasmol_mouse_up] ne ""} {
        rasmol_mouse_up %x %y [get_rasmol_mask %s %b]
    }
}
bind . <KeyPress> {
    if {[info commands rasmol_key_press] ne ""} {
        rasmol_key_press %N
    }
}

# Command Entry
ttk::frame .pw.right.cmd -padding 5
pack .pw.right.cmd -fill x -side bottom

ttk::label .pw.right.cmd.lbl -text "Command:"
pack .pw.right.cmd.lbl -side left
ttk::entry .pw.right.cmd.entry
pack .pw.right.cmd.entry -side left -fill x -expand yes
bind .pw.right.cmd.entry <Return> {
    set cmd [.pw.right.cmd.entry get]
    send_rasmol $cmd
    .pw.right.cmd.entry delete 0 end
    update_status
}

# Status Bar
ttk::frame .status -relief sunken
pack .status -side bottom -fill x
ttk::label .status.lbl -text "Ready"
pack .status.lbl -side left -padx 5

# Functions
proc send_rasmol {cmd} {
    if {[info commands rasmol_command] ne ""} {
        rasmol_command $cmd
    } else {
        puts "RasMol Command: $cmd"
    }
}

proc send_rasmol_menu {menu item {state ""}} {
    if {[info commands rasmol_handle_menu] ne ""} {
        if {$state ne ""} {
            rasmol_handle_menu $menu $item $state
        } else {
            rasmol_handle_menu $menu $item
        }
    } else {
        puts "RasMol Menu: $menu $item"
    }
    update_status
}

set last_sb_v 0.5
set last_sb_h 0.5

proc rotate_molecule {axis args} {
    global last_sb_v last_sb_h rot_mode
    set sb .pw.right.f.${axis}sb

    set type [lindex $args 0]
    if {$type eq "moveto"} {
        set fraction [lindex $args 1]
    } else {
        set amount [lindex $args 1]
        set units [lindex $args 2]
        set cur [$sb get]
        set center [expr {([lindex $cur 0] + [lindex $cur 1]) / 2.0}]
        if {$units eq "units"} {
            set fraction [expr {$center + $amount * 0.02}]
        } else {
            set fraction [expr {$center + $amount * 0.05}]
        }
    }

    if {$fraction < 0} {set fraction 0}
    if {$fraction > 1} {set fraction 1}

    if {$axis eq "v"} {
        set delta [expr {($fraction - $last_sb_v) * 360.0}]
        send_rasmol "rotate x $delta"
        set last_sb_v $fraction
    } else {
        set delta [expr {($fraction - $last_sb_h) * 360.0}]
        if {$rot_mode == 11} {
            send_rasmol "rotate bond $delta"
        } else {
            send_rasmol "rotate y $delta"
        }
        set last_sb_h $fraction
    }

    $sb set [expr {$fraction - 0.05}] [expr {$fraction + 0.05}]
}

proc update_status {} {
    if {[info commands rasmol_info] ne ""} {
        set moles [rasmol_info molecules]
        set atoms [rasmol_info atoms]
        .status.lbl configure -text "Molecules: $moles, Atoms: $atoms"
    }
}

proc toggle_opengl {} {
    global opengl_mode
    if {[info commands rasmol_opengl_mode] ne ""} {
        if {$opengl_mode} {
            .status.lbl configure -text "Switching to OpenGL mode..."
        } else {
            .status.lbl configure -text "Switching to Raster mode..."
        }
        update
        rasmol_opengl_mode $opengl_mode
        update_status
    }
}

proc load_molecule {} {
    set types {
        {"PDB Files" {.pdb}}
        {"All Files" *}
    }
    set file [tk_getOpenFile -filetypes $types]
    if {$file ne ""} {
        .status.lbl configure -text "Loading $file..."
        update
        send_rasmol "load pdb \"$file\""
        update_status
    }
}

bind .pw.right.f.c <Configure> {
    set w [winfo width %W]
    set h [winfo height %W]
    if {[info commands rasmol_resize] ne ""} {
        rasmol_resize $w $h
    }
}

set display_mode 1
set colour_mode 2
set show_h 0
set show_het 1
set use_spec 0
set use_shadow 0
set use_stereo 0
set show_labels 0
set pick_mode 1
set rot_mode 13
set use_slab 0
set opengl_mode 0
set mouse_mode rasmol

puts "UI initialized."

proc show_about {} {
    set w .about
    if {[winfo exists $w]} {
        raise $w
        return
    }
    toplevel $w
    wm title $w "About RasMol"
    wm resizable $w 0 0

    # Main frame
    ttk::frame $w.f -padding 10
    pack $w.f -fill both -expand yes

    # Logo
    set img_path "html_graphics/rasmollogo_22Jun99.jpg"
    if {[file exists $img_path]} {
        if {[catch {image create photo about_logo -file $img_path} err]} {
             label $w.f.logo -text "RasMol" -font {Helvetica 24 bold}
        } else {
             label $w.f.logo -image about_logo
        }
    } else {
        label $w.f.logo -text "RasMol" -font {Helvetica 24 bold}
    }
    pack $w.f.logo -pady 10

    # Version
    label $w.f.version -text "RasMol Version 2.8.0" -font {Helvetica 12 bold}
    pack $w.f.version -pady 2

    # Author Information
    set current_author "Current Maintainer:\nLi ZHOU (zhouesq@hotmail.com)"
    label $w.f.current -text $current_author -justify center -font {Helvetica 10 bold}
    pack $w.f.current -pady 5

    set historical_authors "Original Author:\nRoger Sayle (1992-1999)\n\nMajor Contributors:\nHerbert J. Bernstein (1998-2011)\nArne Mueller (1998)\nGary Grossman & Marco Molinaro (1995-1996)\nPhilippe Valadon (2000)\nTeemu Ikonen (2009)"
    label $w.f.hist -text $historical_authors -justify center -font {Helvetica 9}
    pack $w.f.hist -pady 5

    # License
    set license_info "Licensed under the GNU General Public License (GPL)\nor the RASMOL License."
    label $w.f.license -text $license_info -justify center -font {Helvetica 9 italic}
    pack $w.f.license -pady 10

    # Close button
    ttk::button $w.f.close -text "Close" -command [list destroy $w]
    pack $w.f.close -pady 5
}
