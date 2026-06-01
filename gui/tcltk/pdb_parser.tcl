# Pure Tcl PDB Parser for RasMol

set g_Name2ColorList {
"H"  255 255 255
"HE" 217 255 255
"LI" 204 128 255
"BE" 194 255   0
"B"  255 181 181
"C"  144 144 144
"N"   48  80 248
"O"  255  13  13
"F"  144 224  80
"NE" 179 227 245
"NA" 171  92 242
"MG" 138 255   0
"AL" 191 166 166
"SI" 240 200 160
"P"  255 128   0
"S"  255 255  48
"CL"  31 240  31
"AR" 128 209 227
"K"  143  64 212
"CA"  61 255   0
"SC" 230 230 230
"TI" 191 194 199
"V"  166 166 171
"CR" 138 153 199
"MN" 156 122 199
"FE" 224 102  51
"CO" 240 144 160
"NI"  80 208  80
"CU" 200 128  51
"ZN" 125 128 176
"GA" 194 143 143
"GE" 102 143 143
"AS" 189 128 227
"SE" 255 161   0
"BR" 166  41  41
"KR"  92 184 209
"RB" 112  46 176
"SR"   0 255   0
"Y"  148 255 255
"ZR" 148 224 224
"NB" 115 194 201
"MO"  84 181 181
"TC"  59 158 158
"RU"  36 143 143
"RH"  10 125 140
"PD"   0 105 133
"AG" 192 192 192
"CD" 255 217 143
"IN" 166 117 115
"SN" 102 128 128
"SB" 158  99 181
"TE" 212 122   0
"I"  148   0 148
"XE"  66 158 176
"CS"  87  23 143
"BA"   0 201   0
"LA" 112 212 255
"CE" 255 255 199
"PR" 217 255 199
"ND" 199 255 199
"PM" 163 255 199
"SM" 143 255 199
"EU"  97 255 199
"GD"  69 255 199
"TB"  48 255 199
"DY"  31 255 199
"HO"   0 255 156
"ER"   0 230 117
"TM"   0 212  82
"YB"   0 191  56
"LU"   0 171  36
"HF"  77 194 255
"TA"  77 166 255
"W"   33 148 214
"RE"  38 125 171
"OS"  38 102 150
"IR"  23  84 135
"PT" 208 208 224
"AU" 255 209  35
"HG" 184 184 208
"TL" 166  84  77
"PB"  87  89  97
"BI" 158  79 181
"PO" 171  92   0
"AT" 117  79  69
"RN"  66 130 150
"FR"  66   0 102
"RA"   0 125   0
"AC" 112 171 250
"TH"   0 186 255
"PA"   0 161 255
"U"    0 143 255
"NP"   0 128 255
"PU"   0 107 255
"AM"  84  92 242
"CM" 120  92 227
"BK" 138  79 227
"CF" 161  54 212
"ES" 179  31 212
"FM" 179  31 186
"MD" 179  13 166
"NO" 189  13 135
"LR" 199   0 102
"RF" 204   0  89
"DB" 209   0  79
"SG" 217   0  69
"BH" 224   0  56
"HS" 230   0  46
"MT" 235   0  38
}

set g_Name2RadiusList {
"F"  1.470
"CL" 1.890
"H"  1.100
"C"  1.548
"N"  1.400
"O"  1.348
"P"  1.880
"S"  1.808
"CA" 1.948
"FE" 1.948
"ZN" 1.148
"I"  1.748
}

proc MapName2Color { name } {
    global g_Name2ColorList

    set ind [lsearch -exact $g_Name2ColorList $name]
    if { $ind < 0 } {
        set ind [lsearch -exact $g_Name2ColorList [string range $name 0 1]]
        if { $ind < 0 } {
            set ind [lsearch -exact $g_Name2ColorList [string index $name 0]]
        }
    }
    if { $ind >= 0 } {
        return [list [expr {[lindex $g_Name2ColorList [expr {$ind+1}]] / 255.0}] \
                     [expr {[lindex $g_Name2ColorList [expr {$ind+2}]] / 255.0}] \
                     [expr {[lindex $g_Name2ColorList [expr {$ind+3}]] / 255.0}]]
    } else {
        return [list 0.0 0.0 1.0]
    }
}

proc MapName2Radius { name } {
    global g_Name2RadiusList

    set ind [lsearch -exact $g_Name2RadiusList $name]
    if { $ind < 0 } {
        set ind [lsearch -exact $g_Name2RadiusList [string range $name 0 1]]
        if { $ind < 0 } {
            set ind [lsearch -exact $g_Name2RadiusList [string index $name 0]]
        }
    }
    if { $ind >= 0 } {
        return [lindex $g_Name2RadiusList [expr {$ind+1}]]
    } else {
        return 1.5
    }
}

proc ReadPDB { fileName } {
    global g_Atoms g_Cons

    set inFp [open $fileName "r"]

    set g_Atoms(numAtoms) 0
    set g_Cons(numCons)   0

    while { [gets $inFp line] >= 0 } {
        if { [string first "ATOM" $line] == 0 || \
             [string first "HETATM" $line] == 0 } {

            set serial [string trim [string range $line 6 10]]
            set name   [string trim [string range $line 12 15]]

            set g_Atoms($serial,name)       $name
            set g_Atoms($serial,x)          [string trim [string range $line 30 37]]
            set g_Atoms($serial,y)          [string trim [string range $line 38 45]]
            set g_Atoms($serial,z)          [string trim [string range $line 46 53]]

            set g_Atoms($serial,color)      [MapName2Color  $name]
            set g_Atoms($serial,radius)     [MapName2Radius $name]

            incr g_Atoms(numAtoms)
        } elseif { [string first "CONECT" $line] == 0 } {
            set serial  [string trim [string range $line 6 10]]
            set con1    [string trim [string range $line 11 15]]
            set con2    [string trim [string range $line 16 20]]
            set con3    [string trim [string range $line 21 25]]
            set con4    [string trim [string range $line 26 30]]
            if {$con1 ne "" && $con1 != 0} { lappend g_Cons($serial) $con1 }
            if {$con2 ne "" && $con2 != 0} { lappend g_Cons($serial) $con2 }
            if {$con3 ne "" && $con3 != 0} { lappend g_Cons($serial) $con3 }
            if {$con4 ne "" && $con4 != 0} { lappend g_Cons($serial) $con4 }
            incr g_Cons(numCons)
        }
    }
    close $inFp
}

proc CalcBBox {} {
    global g_Atoms

    set g_Atoms(bbox,xmin)  1.0E10
    set g_Atoms(bbox,ymin)  1.0E10
    set g_Atoms(bbox,zmin)  1.0E10
    set g_Atoms(bbox,xmax) -1.0E10
    set g_Atoms(bbox,ymax) -1.0E10
    set g_Atoms(bbox,zmax) -1.0E10
    foreach key [array names g_Atoms "*,name"] {
        set atom [lindex [split $key ","] 0]
        set x $g_Atoms($atom,x)
        set y $g_Atoms($atom,y)
        set z $g_Atoms($atom,z)
        if { $x > $g_Atoms(bbox,xmax) } { set g_Atoms(bbox,xmax) $x }
        if { $x < $g_Atoms(bbox,xmin) } { set g_Atoms(bbox,xmin) $x }
        if { $y > $g_Atoms(bbox,ymax) } { set g_Atoms(bbox,ymax) $y }
        if { $y < $g_Atoms(bbox,ymin) } { set g_Atoms(bbox,ymin) $y }
        if { $z > $g_Atoms(bbox,zmax) } { set g_Atoms(bbox,zmax) $z }
        if { $z < $g_Atoms(bbox,zmin) } { set g_Atoms(bbox,zmin) $z }
    }
}

proc SetViewPoint {} {
    global g_Gui g_Atoms

    set xsize [expr {$g_Atoms(bbox,xmax) - $g_Atoms(bbox,xmin)}]
    set ysize [expr {$g_Atoms(bbox,ymax) - $g_Atoms(bbox,ymin)}]
    set zsize [expr {$g_Atoms(bbox,zmax) - $g_Atoms(bbox,zmin)}]

    set maxSize $xsize
    if {$ysize > $maxSize} {set maxSize $ysize}
    if {$zsize > $maxSize} {set maxSize $zsize}

    set g_Gui(rotCenX) [expr {($g_Atoms(bbox,xmin) + $g_Atoms(bbox,xmax)) / 2.0}]
    set g_Gui(rotCenY) [expr {($g_Atoms(bbox,ymin) + $g_Atoms(bbox,ymax)) / 2.0}]
    set g_Gui(rotCenZ) [expr {($g_Atoms(bbox,zmin) + $g_Atoms(bbox,zmax)) / 2.0}]

    set g_Gui(zoom) [expr {200.0 / ($maxSize + 1.0)}]
}
