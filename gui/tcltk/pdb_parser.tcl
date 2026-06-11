# Pure Tcl PDB Parser for RasMol

set ::g_Name2ColorList {
"H"  {1.0 1.0 1.0} "C"  {0.5 0.5 0.5} "N"  {0.2 0.3 1.0} "O"  {1.0 0.05 0.05} "P"  {1.0 0.5 0.0} "S"  {1.0 1.0 0.2}
}

proc MapName2Color { name } {
    set name [string toupper [string index [string trim $name] 0]]
    foreach {k v} $::g_Name2ColorList { if {$k eq $name} { return $v } }
    return {0.7 0.7 0.7}
}

proc MapName2Radius { name } { return 1.5 }

proc ReadPDB { fileName } {
    if {![file exists $fileName]} { puts "File not found: $fileName"; return }
    set inFp [open $fileName "r"]
    array unset ::g_Atoms
    array unset ::g_Cons
    set ::g_Atoms(numAtoms) 0
    set ::g_Cons(numCons)   0
    while { [gets $inFp line] >= 0 } {
        set tag [string trim [string range $line 0 5]]
        if { $tag eq "ATOM" || $tag eq "HETATM" } {
            set serial [string trim [string range $line 6 10]]
            set name   [string trim [string range $line 12 15]]
            set x [string trim [string range $line 30 37]]
            set y [string trim [string range $line 38 45]]
            set z [string trim [string range $line 46 53]]
            if {$x eq "" || $y eq "" || $z eq ""} continue
            set ::g_Atoms($serial,x) $x
            set ::g_Atoms($serial,y) $y
            set ::g_Atoms($serial,z) $z
            set ::g_Atoms($serial,color) [MapName2Color $name]
            set ::g_Atoms($serial,radius) [MapName2Radius $name]
            incr ::g_Atoms(numAtoms)
        } elseif { $tag eq "CONECT" } {
            set s1 [string trim [string range $line 6 10]]
            foreach {start end} {11 15 16 20 21 25 26 30} {
                if {[string length $line] < $end} break
                set s2 [string trim [string range $line $start $end]]
                if {$s2 ne "" && $s2 != 0} { lappend ::g_Cons($s1) $s2 }
            }
            incr ::g_Cons(numCons)
        }
    }
    close $inFp
    puts "PDB: Loaded $::g_Atoms(numAtoms) atoms."
}

proc CalcBBox {} {
    if {![info exists ::g_Atoms(numAtoms)] || $::g_Atoms(numAtoms) == 0} return
    set ::g_Atoms(bbox,xmin) 1e10; set ::g_Atoms(bbox,xmax) -1e10
    set ::g_Atoms(bbox,ymin) 1e10; set ::g_Atoms(bbox,ymax) -1e10
    set ::g_Atoms(bbox,zmin) 1e10; set ::g_Atoms(bbox,zmax) -1e10
    foreach key [array names ::g_Atoms "*,x"] {
        set s [lindex [split $key ","] 0]
        foreach ax {x y z} {
            set val $::g_Atoms($s,$ax)
            if {$val < $::g_Atoms(bbox,${ax}min)} { set ::g_Atoms(bbox,${ax}min) $val }
            if {$val > $::g_Atoms(bbox,${ax}max)} { set ::g_Atoms(bbox,${ax}max) $val }
        }
    }
}

proc SetViewPoint {} {
    if {![info exists ::g_Atoms(numAtoms)] || $::g_Atoms(numAtoms) == 0} return
    set dx [expr {$::g_Atoms(bbox,xmax) - $::g_Atoms(bbox,xmin)}]
    set dy [expr {$::g_Atoms(bbox,ymax) - $::g_Atoms(bbox,ymin)}]
    set dz [expr {$::g_Atoms(bbox,zmax) - $::g_Atoms(bbox,zmin)}]
    set maxD [expr {max($dx, max($dy, $dz))}]
    if {$maxD < 1} {set maxD 1}
    set ::g_Gui(rotCenX) [expr {($::g_Atoms(bbox,xmin) + $::g_Atoms(bbox,xmax))/2.0}]
    set ::g_Gui(rotCenY) [expr {($::g_Atoms(bbox,ymin) + $::g_Atoms(bbox,ymax))/2.0}]
    set ::g_Gui(rotCenZ) [expr {($::g_Atoms(bbox,zmin) + $::g_Atoms(bbox,zmax))/2.0}]
    set ::g_Gui(zoom) [expr {300.0 / $maxD}]
    puts "Viewpoint: Center ($::g_Gui(rotCenX) $::g_Gui(rotCenY) $::g_Gui(rotCenZ)), Zoom $::g_Gui(zoom)"
}
