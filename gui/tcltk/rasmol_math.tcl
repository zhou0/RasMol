# 3D Math for Pure Tcl RasMol

proc mat_mult {m1 m2} {
    set res {0 0 0 0 0 0 0 0 0}
    for {set i 0} {$i < 3} {incr i} {
        for {set j 0} {$j < 3} {incr j} {
            set sum 0
            for {set k 0} {$k < 3} {incr k} {
                set sum [expr {$sum + [lindex $m1 [expr {$i*3+$k}]] * [lindex $m2 [expr {$k*3+$j}]]}]
            }
            lset res [expr {$i*3+$j}] $sum
        }
    }
    return $res
}

proc get_rot_matrix {ax ay az} {
    set d2r [expr {acos(-1) / 180.0}]
    set ax [expr {$ax * $d2r}]
    set ay [expr {$ay * $d2r}]
    set az [expr {$az * $d2r}]

    set cx [expr {cos($ax)}]
    set sx [expr {sin($ax)}]
    set cy [expr {cos($ay)}]
    set sy [expr {sin($ay)}]
    set cz [expr {cos($az)}]
    set sz [expr {sin($az)}]

    # Rotation around X
    set rx [list 1 0 0 0 $cx [expr {-$sx}] 0 $sx $cx]
    # Rotation around Y
    set ry [list $cy 0 $sy 0 1 0 [expr {-$sy}] 0 $cy]
    # Rotation around Z
    set rz [list $cz [expr {-$sz}] 0 $sz $cz 0 0 0 1]

    return [mat_mult $rz [mat_mult $ry $rx]]
}

proc transform_point {p m offset scale} {
    set x [lindex $p 0]
    set y [lindex $p 1]
    set z [lindex $p 2]

    set ox [lindex $offset 0]
    set oy [lindex $offset 1]
    set oz [lindex $offset 2]

    set tx [expr {$x - $ox}]
    set ty [expr {$y - $oy}]
    set tz [expr {$z - $oz}]

    set nx [expr {[lindex $m 0]*$tx + [lindex $m 1]*$ty + [lindex $m 2]*$tz}]
    set ny [expr {[lindex $m 3]*$tx + [lindex $m 4]*$ty + [lindex $m 5]*$tz}]
    set nz [expr {[lindex $m 6]*$tx + [lindex $m 7]*$ty + [lindex $m 8]*$tz}]

    return [list [expr {$nx * $scale}] [expr {$ny * $scale}] [expr {$nz * $scale}]]
}
