# Pure Tcl Canvas Renderer for RasMol

proc rasmol_redraw {} {
    global g_Atoms g_Cons g_Gui rasmol_canvas_width rasmol_canvas_height display_mode

    set c .pw.right.f.c
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

        set sx [expr {[lindex $tp 0] + $rasmol_canvas_width/2.0}]
        set sy [expr {[lindex $tp 1] + $rasmol_canvas_height/2.0}]
        set sz [lindex $tp 2]

        set t_coords($s) [list $sx $sy $sz]
        lappend transformed_list [list $sz $sx $sy $s]
    }

    # Z-sorting
    set sorted_list [lsort -real -index 0 $transformed_list]

    # Draw bonds (simplistic approach: draw before atoms)
    if {$display_mode == 1 || $display_mode == 3 || $display_mode == 5} {
        foreach s [array names g_Cons "*,list"] {
            set s1 [lindex [split $s ","] 0]
            if {![info exists t_coords($s1)]} continue
            foreach s2 $g_Cons($s) {
                if {![info exists t_coords($s2)]} continue
                set p1 $t_coords($s1)
                set p2 $t_coords($s2)
                $c create line [lindex $p1 0] [lindex $p1 1] [lindex $p2 0] [lindex $p2 1] \
                    -fill white -width 1
            }
        }
    }

    # Draw atoms
    foreach atom $sorted_list {
        set sx [lindex $atom 1]
        set sy [lindex $atom 2]
        set s [lindex $atom 3]

        set r [expr {$g_Atoms($s,radius) * $scale / 10.0}]
        if {$r < 1} {set r 1}

        set color_list $g_Atoms($s,color)
        set color [format "#%02x%02x%02x" \
            [expr {int([lindex $color_list 0] * 255)}] \
            [expr {int([lindex $color_list 1] * 255)}] \
            [expr {int([lindex $color_list 2] * 255)}]]

        if {$display_mode == 4 || $display_mode == 5} { # Spacefill or Ball & Stick
            $c create oval [expr {$sx-$r}] [expr {$sy-$r}] [expr {$sx+$r}] [expr {$sy+$r}] \
                -fill $color -outline black
        }
    }
}
