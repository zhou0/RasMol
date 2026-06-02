# Pure Tcl Canvas Renderer for RasMol

proc rasmol_cpu_redraw {} {
    global g_Atoms g_Cons g_Gui display_mode

    set c .pw.right.f.c
    if {![winfo exists $c]} return

    set w [winfo width $c]
    set h [winfo height $c]
    if {$w <= 10} { set w 800 }
    if {$h <= 10} { set h 600 }

    $c delete all

    if {![info exists g_Atoms(numAtoms)] || $g_Atoms(numAtoms) == 0} {
        return
    }

    set m [get_rot_matrix $g_Gui(rotX) $g_Gui(rotY) $g_Gui(rotZ)]
    set offset [list $g_Gui(rotCenX) $g_Gui(rotCenY) $g_Gui(rotCenZ)]
    set scale $g_Gui(zoom)

    array set t_coords {}
    set transformed_list {}

    foreach s_key [array names g_Atoms "*,x"] {
        set s [lindex [split $s_key ","] 0]
        set p [list $g_Atoms($s,x) $g_Atoms($s,y) $g_Atoms($s,z)]
        set tp [transform_point $p $m $offset $scale]

        set sx [expr {[lindex $tp 0] + $w/2.0}]
        set sy [expr {[lindex $tp 1] + $h/2.0}]
        set sz [lindex $tp 2]

        set t_coords($s) [list $sx $sy $sz]
        lappend transformed_list [list $sz $sx $sy $s]
    }

    # Painter's algorithm: draw from back to front.
    # We assume camera is at some positive Z looking towards origin.
    # So atoms with SMALLER Z are closer?
    # Or larger Z is further?
    # Let's check rotation matrix.
    # Anyway, we sort by Z.
    set sorted_list [lsort -real -index 0 $transformed_list]

    # Draw bonds first if not spacefill
    if {$display_mode != 4} {
        set bond_color "white"
        set bond_width [expr {$display_mode == 3 || $display_mode == 5 ? 2 : 1}]
        foreach s1 [array names g_Cons] {
            if {![info exists t_coords($s1)]} continue
            foreach s2 $g_Cons($s1) {
                if {![info exists t_coords($s2)]} continue
                set p1 $t_coords($s1)
                set p2 $t_coords($s2)
                $c create line [lindex $p1 0] [lindex $p1 1] [lindex $p2 0] [lindex $p2 1] \
                    -fill $bond_color -width $bond_width
            }
        }
    }

    # Draw atoms
    foreach atom $sorted_list {
        set sx [lindex $atom 1]
        set sy [lindex $atom 2]
        set s [lindex $atom 3]

        set r [expr {$g_Atoms($s,radius) * $scale * 0.4}]
        if {$r < 1.0} {set r 1.0}

        set color_list $g_Atoms($s,color)
        set color [format "#%02x%02x%02x" \
            [expr {int([lindex $color_list 0] * 255)}] \
            [expr {int([lindex $color_list 1] * 255)}] \
            [expr {int([lindex $color_list 2] * 255)}]]

        if {$display_mode == 4 || $display_mode == 5} {
            $c create oval [expr {$sx-$r}] [expr {$sy-$r}] [expr {$sx+$r}] [expr {$sy+$r}] \
                -fill $color -outline black
        } else {
             $c create oval [expr {$sx-1.5}] [expr {$sy-1.5}] [expr {$sx+1.5}] [expr {$sy+1.5}] \
                -fill $color -outline $color
        }
    }
}
