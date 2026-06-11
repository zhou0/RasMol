# Pure Tcl Canvas Renderer for RasMol

proc rasmol_cpu_redraw {} {
    set c .pw.right.f.c
    if {![winfo exists $c]} return
    set w [winfo width $c]; set h [winfo height $c]
    if {$w <= 10} {set w 800}; if {$h <= 10} {set h 600}
    $c delete all
    if {![info exists ::g_Atoms(numAtoms)] || $::g_Atoms(numAtoms) == 0} return
    set m [get_rot_matrix $::g_Gui(rotX) $::g_Gui(rotY) $::g_Gui(rotZ)]
    set scale $::g_Gui(zoom)
    set offset [list $::g_Gui(rotCenX) $::g_Gui(rotCenY) $::g_Gui(rotCenZ)]
    array set t_coords {}
    set transformed_list {}
    foreach key [array names ::g_Atoms "*,x"] {
        set s [lindex [split $key ","] 0]
        set p [list $::g_Atoms($s,x) $::g_Atoms($s,y) $::g_Atoms($s,z)]
        set tp [transform_point $p $m $offset $scale]
        set sx [expr {[lindex $tp 0] + $w/2.0}]
        set sy [expr {$h/2.0 - [lindex $tp 1]}]
        set sz [lindex $tp 2]
        set t_coords($s) [list $sx $sy $sz]
        lappend transformed_list [list $sz $sx $sy $s]
    }
    set sorted_list [lsort -real -decreasing -index 0 $transformed_list]
    if {$::display_mode != 4} {
        foreach s1 [array names ::g_Cons] {
            if {![info exists t_coords($s1)]} continue
            foreach s2 $::g_Cons($s1) {
                if {![info exists t_coords($s2)]} continue
                $c create line [lindex $t_coords($s1) 0] [lindex $t_coords($s1) 1] \
                               [lindex $t_coords($s2) 0] [lindex $t_coords($s2) 1] -fill white
            }
        }
    }
    foreach atom $sorted_list {
        set sx [lindex $atom 1]; set sy [lindex $atom 2]; set s [lindex $atom 3]
        set r [expr {$::g_Atoms($s,radius) * $scale * 0.4}]
        if {$r < 1} {set r 1}
        set cl $::g_Atoms($s,color)
        set color [format "#%02x%02x%02x" [expr {int([lindex $cl 0]*255)}] [expr {int([lindex $cl 1]*255)}] [expr {int([lindex $cl 2]*255)}]]
        if {$::display_mode == 4 || $::display_mode == 5} {
            $c create oval [expr {$sx-$r}] [expr {$sy-$r}] [expr {$sx+$r}] [expr {$sy+$r}] -fill $color -outline black
        } else {
            $c create oval [expr {$sx-1}] [expr {$sy-1}] [expr {$sx+1}] [expr {$sy+1}] -fill $color -outline $color
        }
    }
    puts "CPU Draw: [llength $sorted_list] atoms."
}
