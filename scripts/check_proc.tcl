namespace eval ttk {
    proc style {args} { return "" }
    proc panedwindow {args} { return "" }
    proc frame {args} { return "" }
    proc labelframe {args} { return "" }
    proc button {args} { return "" }
    proc label {args} { return "" }
    proc entry {args} { return "" }
    proc scrollbar {args} { return "" }
}

proc package {args} { return "" }
proc wm {args} { return "" }
proc menu {args} { return "" }
proc pack {args} { return "" }
proc image {args} { return "" }
proc canvas {args} { return "" }
proc grid {args} { return "" }
proc bind {args} { return "" }
proc update_status {args} { return "" }
proc rasmol_info {args} { return 0 }

source gui/tcltk/rasmol_ui.tcl

if {[info procs load_molecule] eq "load_molecule"} {
    puts "SUCCESS: load_molecule is defined."
} else {
    puts "FAILURE: load_molecule is NOT defined."
}
