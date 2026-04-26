package require Tk
package require Ttk

# Main Window setup
wm title . "RasMol Themed UI"
wm geometry . 800x600

# Theme selection (Tile/Ttk)
ttk::style theme use clam

# Menu Bar
menu .menubar
. configure -menu .menubar

menu .menubar.file -tearoff 0
.menubar add cascade -label "File" -menu .menubar.file
.menubar.file add command -label "Open..." -command {load_molecule}
.menubar.file add separator
.menubar.file add command -label "Exit" -command {exit}

menu .menubar.display -tearoff 0
.menubar add cascade -label "Display" -menu .menubar.display
.menubar.display add radiobutton -label "Wireframe" -variable display_mode -value "wireframe" -command {send_rasmol "wireframe"}
.menubar.display add radiobutton -label "Backbone" -variable display_mode -value "backbone" -command {send_rasmol "backbone"}
.menubar.display add radiobutton -label "Sticks" -variable display_mode -value "sticks" -command {send_rasmol "sticks"}
.menubar.display add radiobutton -label "Spacefill" -variable display_mode -value "spacefill" -command {send_rasmol "spacefill"}

# Main layout using ttk::panedwindow
ttk::panedwindow .pw -orient horizontal
pack .pw -fill both -expand yes

# Left control panel
ttk::frame .pw.left -padding 5
.pw add .pw.left

ttk::labelframe .pw.left.opts -text "Controls" -padding 5
pack .pw.left.opts -fill x -side top

ttk::button .pw.left.opts.btn1 -text "Reset View" -command {send_rasmol "reset"}
pack .pw.left.opts.btn1 -pady 2 -fill x

ttk::checkbutton .pw.left.opts.hydrogens -text "Show Hydrogens" -variable show_h -command {
    if {$show_h} {
        send_rasmol "set hydrogens on"
    } else {
        send_rasmol "set hydrogens off"
    }
}
pack .pw.left.opts.hydrogens -pady 2 -fill x

# Right side: Visualization and Command entry
ttk::frame .pw.right
.pw add .pw.right

# Placeholder for RasMol Canvas
ttk::frame .pw.right.canvas -relief sunken -borderwidth 2
pack .pw.right.canvas -fill both -expand yes -padx 5 -pady 5
ttk::label .pw.right.canvas.lbl -text "RasMol Visualization Area"
pack .pw.right.canvas.lbl -expand yes

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
}

# Functions
proc send_rasmol {cmd} {
    puts "Sending to RasMol: $cmd"
    if {[info commands rasmol_command] ne ""} {
        rasmol_command $cmd
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
    }
}

set display_mode "wireframe"
set show_h 1
