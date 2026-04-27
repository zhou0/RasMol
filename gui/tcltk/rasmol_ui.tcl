package require Tk
package require Ttk

puts "Starting RasMol Themed UI..."

# Main Window setup
wm title . "RasMol Themed UI"
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

# Options Menu
menu .menubar.options -tearoff 0
.menubar add cascade -label "Options" -menu .menubar.options

set has_vtk [rasmol_info vtk]
if {$has_vtk} {
    .menubar.options add checkbutton -label "OpenGL mode" -variable opengl_mode -command {toggle_opengl}
    .menubar.options add separator
}

.menubar.options add checkbutton -label "Slab Mode" -variable use_slab -command {send_rasmol_menu 3 1}
.menubar.options add checkbutton -label "Hydrogens" -variable show_h -command {send_rasmol_menu 3 2}
.menubar.options add checkbutton -label "Hetero Atoms" -variable show_het -command {send_rasmol_menu 3 3}
.menubar.options add checkbutton -label "Specular" -variable use_spec -command {send_rasmol_menu 3 4}
.menubar.options add checkbutton -label "Shadows" -variable use_shadow -command {send_rasmol_menu 3 5}
.menubar.options add checkbutton -label "Stereo" -variable use_stereo -command {send_rasmol_menu 3 6}
.menubar.options add checkbutton -label "Labels" -variable show_labels -command {send_rasmol_menu 3 7}

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

# Help Menu
menu .menubar.help -tearoff 0
.menubar add cascade -label "Help" -menu .menubar.help
.menubar.help add command -label "About RasMol" -command {send_rasmol_menu 6 1}
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

# RasMol Canvas Area
set rasmol_img [image create photo rasmol_view -width 576 -height 576]
ttk::frame .pw.right.f -relief sunken -borderwidth 2
pack .pw.right.f -fill both -expand yes -padx 5 -pady 5

canvas .pw.right.f.c -width 576 -height 576 -highlightthickness 0 -bg black
pack .pw.right.f.c -fill both -expand yes
.pw.right.f.c create image 0 0 -image $rasmol_img -anchor nw -tags rasmol_image

# Register the photo image with the C bridge
if {[info commands rasmol_register_photo] ne ""} {
    rasmol_register_photo rasmol_view
}

# Mouse and Keyboard Interaction
bind .pw.right.f.c <ButtonPress> {
    if {[info commands rasmol_mouse_down] ne ""} {
        rasmol_mouse_down %x %y %s
    }
}
bind .pw.right.f.c <B1-Motion> {
    if {[info commands rasmol_mouse_move] ne ""} {
        rasmol_mouse_move %x %y %s
    }
}
bind .pw.right.f.c <B2-Motion> {
    if {[info commands rasmol_mouse_move] ne ""} {
        rasmol_mouse_move %x %y %s
    }
}
bind .pw.right.f.c <B3-Motion> {
    if {[info commands rasmol_mouse_move] ne ""} {
        rasmol_mouse_move %x %y %s
    }
}
bind .pw.right.f.c <ButtonRelease> {
    if {[info commands rasmol_mouse_up] ne ""} {
        rasmol_mouse_up %x %y %s
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

proc send_rasmol_menu {menu item} {
    if {[info commands rasmol_handle_menu] ne ""} {
        rasmol_handle_menu $menu $item
    } else {
        puts "RasMol Menu: $menu $item"
    }
    update_status
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
        rasmol_opengl_mode $opengl_mode
    }
}

proc load_molecule {} {
    set types {
        {"PDB Files" {.pdb}}
        {"All Files" *}
    }
    set file [tk_getOpenFile -filetypes $types]
    if {$file ne ""} {
        send_rasmol "load pdb $file"
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

puts "UI initialized."
