# Copyright:    2009 Paul Obermeier (obermeier@tcl3d.org)
#
#               See the file "Tcl3D_License.txt" for information on 
#               usage and redistribution of this file, and for a
#               DISCLAIMER OF ALL WARRANTIES.
#
# Module:       Tcl3D -> tcl3dOgl
# Filename:     molecules.tcl
#
# Author:       Paul Obermeier
#
# Description:  Tcl3D demo displaying molecules as colored spheres.
#
#               The molecule description is read from a Protein Data Base file.
#               See http://www.pdb.org for more information about PDB files. 
#               This site is also a resource for downloading PDB files.
#
#               Currently supported keywords are ATOM, HETATM and CONECT.
#               Feel free to extend and optimize the PDB parser.
#
#               Atom color coding and atom radius are taken from the OpenSource 
#               molecule viewer QuteMol: http://qutemol.sourceforge.net/

package require Tk
package require tcl3d 0.4.0

# Define virtual events for OS independent mouse handling.
tcl3dAddEvents

# Font to be used in the Tk listbox.
set g_ListFont {-family {Courier} -size 10}

# Determine the directory of this script.
set g_ScriptDir [file dirname [info script]]
set g_LastDir   $g_ScriptDir

# Frame counter for displaying fps.
set g_FrameCount 0

# Create a stop watch for time measurement.
set g_Stopwatch [tcl3dNewSwatch]

# Implementation of a simple PDB (Protein Data Base) parser.

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
        return [list [expr [lindex $g_Name2ColorList [expr $ind+1]] / 255.0] \
                     [expr [lindex $g_Name2ColorList [expr $ind+2]] / 255.0] \
                     [expr [lindex $g_Name2ColorList [expr $ind+3]] / 255.0]]
    } else {
        puts "MapName2Color: Unknown atom name $name. Using default color 0 0 1.0"
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
        return [lindex $g_Name2RadiusList [expr $ind+1]]
    } else {
        puts "MapName2Radius: Unknown atom name $name. Using default radius 1.5"
        return 1.5
    }
}

proc ReadPDB { fileName } {
    global g_Atoms g_Cons

    set inFp [open $fileName "r"]

    set g_Atoms(numAtoms) 0
    set g_Cons(numCons)   0

    set lc 0
    while { [gets $inFp line] >= 0 } {
        incr lc
        if { $lc % 500 == 0 } {
            puts "Line $lc ..."
        }
        if { [string first "ATOM" $line] == 0 || \
             [string first "HETATM" $line] == 0 } {

            set serial [string trim [string range $line 6 10]]
            set name   [string trim [string range $line 12 15]]
            if { [string first "ATOM" $line] == 0 } {
                set g_Atoms($serial,hetatom) 0
            } else {
                set g_Atoms($serial,hetatom) 1
            }

            set g_Atoms($serial,name)       $name
            set g_Atoms($serial,altLoc)     [string trim [string range $line 16 16]]
            set g_Atoms($serial,resName)    [string trim [string range $line 17 19]]
            set g_Atoms($serial,chainID)    [string trim [string range $line 21 21]]
            set g_Atoms($serial,resSeq)     [string trim [string range $line 22 25]]
            set g_Atoms($serial,iCode)      [string trim [string range $line 26 26]]
            set g_Atoms($serial,x)          [string trim [string range $line 30 37]]
            set g_Atoms($serial,y)          [string trim [string range $line 38 45]]
            set g_Atoms($serial,z)          [string trim [string range $line 46 53]]
            set g_Atoms($serial,occupancy)  [string trim [string range $line 54 59]]
            set g_Atoms($serial,tempFactor) [string trim [string range $line 60 65]]
            set g_Atoms($serial,element)    [string trim [string range $line 76 77]]
            set g_Atoms($serial,charge)     [string trim [string range $line 78 79]]

            set g_Atoms($serial,color)      [MapName2Color  $name]
            set g_Atoms($serial,radius)     [MapName2Radius $name]

            incr g_Atoms(numAtoms)
            if { ! [info exists g_Atoms(count,$name)] } {
                set g_Atoms(count,$name) 1
            } else {
                incr g_Atoms(count,$name)
            }
        } elseif { [string first "CONECT" $line] == 0 } {
            set serial  [string trim [string range $line 6 10]]
            set con1    [string trim [string range $line 11 15]]
            set con2    [string trim [string range $line 16 20]]
            set con3    [string trim [string range $line 21 25]]
            set con4    [string trim [string range $line 26 30]]
            lappend g_Cons($serial,list) $con1
            if { $con2 ne "" && $con2 != 0  } {
                lappend g_Cons($serial,list) $con2
                if { $con3 ne "" && $con3 != 0 } {
                    lappend g_Cons($serial,list) $con3
                    if { $con4 ne "" && $con4 != 0 } {
                        lappend g_Cons($serial,list) $con4
                    }
                }
            }
            incr g_Cons(numCons)
        }
    }
    close $inFp
}

# End of implementation of a simple PDB (Protein Data Base) parser.

proc bgerror { msg } {
    tk_messageBox -icon error -type ok -message "Error: $msg\n\n$::errorInfo"
    exit
}

proc RotX { w angle } {
    global g_Gui

    set g_Gui(rotX) [expr {$g_Gui(rotX) + $angle}]
    $w postredisplay
}

proc RotY { w angle } {
    global g_Gui

    set g_Gui(rotY) [expr {$g_Gui(rotY) + $angle}]
    $w postredisplay
}

proc RotZ { w angle } {
    global g_Gui

    set g_Gui(rotZ) [expr {$g_Gui(rotZ) + $angle}]
    $w postredisplay
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
        if { $x > $g_Atoms(bbox,xmax) } {
            set g_Atoms(bbox,xmax) $x
        }
        if { $x < $g_Atoms(bbox,xmin) } {
            set g_Atoms(bbox,xmin) $x
        }
        if { $y > $g_Atoms(bbox,ymax) } {
            set g_Atoms(bbox,ymax) $y
        }
        if { $y < $g_Atoms(bbox,ymin) } {
            set g_Atoms(bbox,ymin) $y
        }
        if { $z > $g_Atoms(bbox,zmax) } {
            set g_Atoms(bbox,zmax) $z
        }
        if { $z < $g_Atoms(bbox,zmin) } {
            set g_Atoms(bbox,zmin) $z
        }
    }
}

proc Max { a b } {
    if { $a > $b } {
        return $a
    } else {
        return $b
    }
}

proc SetViewPoint {} {
    global g_Gui g_Atoms

    set xsize [expr {$g_Atoms(bbox,xmax) - $g_Atoms(bbox,xmin)}]
    set ysize [expr {$g_Atoms(bbox,ymax) - $g_Atoms(bbox,ymin)}]
    set zsize [expr {$g_Atoms(bbox,zmax) - $g_Atoms(bbox,zmin)}]

    set maxSize 0.0
    set maxSize [Max $maxSize $xsize]
    set maxSize [Max $maxSize $ysize]
    set maxSize [Max $maxSize $zsize]
    set g_Gui(camDist) [expr {0.5 * $maxSize / \
                         tan (3.1415926 / 180.0 * (0.5 * 60.0))}]
    set g_Gui(rotCenX) [expr {-1.0 * ($g_Atoms(bbox,xmin) + $xsize * 0.5)}]
    set g_Gui(rotCenY) [expr {-1.0 * ($g_Atoms(bbox,ymin) + $ysize * 0.5)}]
    set g_Gui(rotCenZ) [expr {-1.0 * ($g_Atoms(bbox,zmin) + $zsize * 0.5)}]
}

proc DrawConnects {} {
    global g_Atoms g_Cons

    glDisable GL_LIGHTING
    glLineWidth $::g_LineWidth
    glBegin GL_LINES
    glColor3f 1.0 1.0 0.0
    foreach key [array name g_Cons "*,list"] {
        set atom [lindex [split $key ","] 0]
        if { ! [info exists g_Atoms($atom,x)] } {
            puts "Missing atom $atom"
            continue
        }
        foreach con $g_Cons($key) {
            if { ! [info exists g_Atoms($con,x)] } {
                puts "Missing con $atom"
                continue
            }
            glVertex3f $g_Atoms($atom,x) $g_Atoms($atom,y) $g_Atoms($atom,z)
            glVertex3f $g_Atoms($con,x)  $g_Atoms($con,y)  $g_Atoms($con,z)
        }
    }
    glEnd
    glEnable GL_LIGHTING
}

proc DrawSpheres {} {
    global g_Atoms

    set no_mat { 0.0 0.0 0.0 1.0 }
    set mat_specular { 1.0 1.0 1.0 1.0 }
    set high_shininess { 100.0 }

    glEnable GL_LIGHTING
    glLineWidth 1.0
    set quadObj [gluNewQuadric]
    foreach key [array names g_Atoms "*,name"] {
        set atom [lindex [split $key ","] 0]
        set color $g_Atoms($atom,color)
        lappend color 1.0
        glMaterialfv GL_FRONT GL_SPECULAR  $mat_specular
        glMaterialfv GL_FRONT GL_SHININESS $high_shininess
        glMaterialfv GL_FRONT GL_EMISSION  $no_mat
        glMaterialfv GL_FRONT GL_AMBIENT   $color
        glMaterialfv GL_FRONT GL_DIFFUSE   $color
        glPushMatrix
        glTranslatef $g_Atoms($atom,x) $g_Atoms($atom,y) $g_Atoms($atom,z)
        if { $::g_LineMode } {
            gluQuadricDrawStyle $quadObj GLU_LINE
        } else {
            gluQuadricDrawStyle $quadObj GLU_FILL
            gluQuadricNormals $quadObj GLU_SMOOTH
        }
        gluSphere $quadObj [expr {0.5 * $::g_AtomScale * $g_Atoms($atom,radius)}] \
                           $::g_NumSlices $::g_NumStacks
        glPopMatrix
    }
    gluDeleteQuadric $quadObj
}

proc ToggleDisplayList {} {
    if { $::g_UseDisplayList } {
        if { ! [info exists ::g_SphereList] } {
            CreateDisplayList
        }
    } else {
        if { [info exists ::g_SphereList] } {
            glDeleteLists $::g_SphereList 1
            unset ::g_SphereList
        }
    }
}

proc CreateDisplayList {} {
    if { $::g_UseDisplayList } {
        if { [info exists ::g_SphereList] } {
            glDeleteLists $::g_SphereList 1
        }
        set ::g_SphereList [glGenLists 1]
        glNewList $::g_SphereList GL_COMPILE
        if { $::g_ShowAtoms } {
            DrawSpheres
        }
        if { $::g_ShowConnects } {
            DrawConnects
        }
        glEndList
    }
}

proc GetFPS { { elapsedFrames 1 } } {
    set currentTime [tcl3dLookupSwatch $::g_Stopwatch]
    set fps [expr $elapsedFrames / ($currentTime - $::g_LastTime)]
    set ::g_LastTime $currentTime
    return $fps
}

proc DisplayFPS {} {
    global g_FrameCount

    incr g_FrameCount
    if { $g_FrameCount == 100 } {
        set msg [format "Animate (%.0f fps)" [GetFPS $g_FrameCount]]
        $::g_AnimateBtn configure -text $msg
        set g_FrameCount 0
    }
}

proc ShowAnimation { w } {
    global g_Gui

    if { $::g_AnimStarted == 0 } {
        return
    }
    set g_Gui(rotY) [expr {$g_Gui(rotY) + 1.0}]
    set g_Gui(rotZ) [expr {$g_Gui(rotZ) + 1.0}]
    $w postredisplay
    set ::g_AnimId [after idle ShowAnimation $w]
}

proc StartAnimation {} {
    ShowAnimation $::frTogl.toglwin
}

proc StopAnimation {} {
    if { [info exists ::g_AnimId] } {
        after cancel $::g_AnimId 
        set ::g_AnimStarted 0
    }
}

proc tclCreateFunc { w } {
    set ambient        { 0.0 0.0 0.0 1.0 }
    set diffuse        { 1.0 1.0 1.0 1.0 }
    set specular       { 1.0 1.0 1.0 1.0 }
    set position       { 0.0 3.0 2.0 0.0 }
    set lmodel_ambient { 0.4 0.4 0.4 1.0 }
    set local_view     { 0.0 }

    glClearColor 0.0 0.1 0.1 0
    glEnable GL_DEPTH_TEST

    glLightfv GL_LIGHT0 GL_AMBIENT $ambient
    glLightfv GL_LIGHT0 GL_DIFFUSE $diffuse
    glLightfv GL_LIGHT0 GL_POSITION $position
    glLightModelfv GL_LIGHT_MODEL_AMBIENT $lmodel_ambient
    glLightModelfv GL_LIGHT_MODEL_LOCAL_VIEWER $local_view
 
    glEnable GL_LIGHTING
    glEnable GL_LIGHT0

    CreateDisplayList

    tcl3dStartSwatch $::g_Stopwatch
    set startTime [tcl3dLookupSwatch $::g_Stopwatch]
    set ::g_LastTime $startTime
}

proc tclReshapeFunc { toglwin {w ""} {h ""} } {
    if {$w eq "" || $h eq ""} {
        set w [winfo width $toglwin]
        set h [winfo height $toglwin]
    }
    if {$w <= 1} { set w 400 }
    if {$h <= 1} { set h 400 }
    global g_Gui

    set ::g_WinWidth  $w
    set ::g_WinHeight $h

    glViewport 0 0 $w $h
    glMatrixMode GL_PROJECTION
    glLoadIdentity
    gluPerspective 60.0 [expr double($w)/double($h)] 1.0 2000.0
    glMatrixMode GL_MODELVIEW
    glLoadIdentity
    gluLookAt 0.0 0.0 $g_Gui(camDist) 0.0 0.0 0.0 0.0 1.0 0.0
}

proc tclDisplayFunc { w } {
    global g_Gui

    glClear [expr $::GL_COLOR_BUFFER_BIT | $::GL_DEPTH_BUFFER_BIT]

    # Viewport command is not really needed, but has been inserted for
    # Mac OSX. Presentation framework (Tk) does not send a reshape event,
    # when switching from one demo to another.
    glViewport 0 0 $::g_WinWidth $::g_WinHeight

    glMatrixMode GL_MODELVIEW
    glLoadIdentity

    gluLookAt 0.0 0.0 $g_Gui(camDist) 0.0 0.0 0.0 0.0 1.0 0.0

    glShadeModel GL_SMOOTH
    glPushMatrix
    glTranslatef $g_Gui(distX) $g_Gui(distY) [expr {-1.0 * $g_Gui(distZ)}]
    glRotatef $g_Gui(rotX) 1.0 0.0 0.0
    glRotatef $g_Gui(rotY) 0.0 1.0 0.0
    glRotatef $g_Gui(rotZ) 0.0 0.0 1.0
    glTranslatef $g_Gui(rotCenX) $g_Gui(rotCenY) $g_Gui(rotCenZ)

    if { $::g_UseDisplayList } {
        if { ! [info exists ::g_SphereList] } {
            CreateDisplayList
        }
        glCallList $::g_SphereList
    } else {
        if { $::g_ShowAtoms } {
            DrawSpheres 
        }
        if { $::g_ShowConnects } {
            DrawConnects 
        }
    }
    glPopMatrix

    if { $::g_AnimStarted } {
        DisplayFPS
    }

    $w swapbuffers
}

proc UpdateNumSpheres { name1 name2 op } {
    set numPgons [expr $::g_NumAtoms * $::g_NumStacks * $::g_NumSlices]
    $::g_InfoAtomLabel configure -text "$::g_NumAtoms ($numPgons quads)"
    set ::g_FrameCount 0
}

proc HandleRot {x y win} {
    global g_Mouse

    RotY $win [expr {180.0 * (double($x - $g_Mouse(x)) / [winfo width $win])}]
    RotX $win [expr {180.0 * (double($y - $g_Mouse(y)) / [winfo height $win])}]

    set g_Mouse(x) $x
    set g_Mouse(y) $y
}

proc HandleTrans {axis x y win} {
    global g_Mouse g_Gui

    if { $axis ne "Z" } {
        set g_Gui(distX) [expr {$g_Gui(distX) + 0.1 * double($x - $g_Mouse(x))}]
        set g_Gui(distY) [expr {$g_Gui(distY) - 0.1 * double($y - $g_Mouse(y))}]
    } else {
        set g_Gui(distZ) [expr {$g_Gui(distZ) + 0.1 * (double($g_Mouse(y) - $y))}]
    }

    set g_Mouse(x) $x
    set g_Mouse(y) $y

    $win postredisplay
}

proc Cleanup {} {
    $::g_Stopwatch delete
    foreach var [info globals g_*] {
        uplevel #0 unset $var
    }
}

proc ExitProg {} {
    exit
}

proc UpdateTitle { pdbFileName } {
    set appName "Tcl3D demo: Molecule viewer ([file tail $pdbFileName])"
    wm title . $appName
}

proc ReadMolecule { fileName } {
    global g_Atoms g_Cons

    catch { unset g_Atoms }
    ReadPDB $fileName
    CalcBBox
    SetViewPoint
    set ::g_NumAtoms $g_Atoms(numAtoms)
    set ::g_NumCons  $g_Cons(numCons)
    UpdateTitle $fileName
    $::g_InfoConLabel configure -text "$::g_NumCons ($::g_NumCons lines)"
    $::g_AtomCountLb configure -exportselection false
    $::g_AtomCountLb delete 0 end
    foreach key [lsort [array names g_Atoms "count,*"]] {
        set name [lindex [split $key ","] 1]
        set msgStr [format "%-4s: %4d" $name $g_Atoms(count,$name)]
        $::g_AtomCountLb insert end $msgStr
        foreach { r g b } [MapName2Color $name] { break }
        set color [tcl3dRgbf2Name $r $g $b]
        $::g_AtomCountLb itemconfigure end -background $color
    }
}

proc ResetTfm {} {
    global g_Gui

    set g_Gui(distX)   0.0
    set g_Gui(distY)   0.0
    set g_Gui(distZ)   5.0
    set g_Gui(rotX)    0.0
    set g_Gui(rotY)    0.0
    set g_Gui(rotZ)    0.0
    set g_Gui(rotCenX) 0.0 
    set g_Gui(rotCenY) 0.0
    set g_Gui(rotCenZ) 0.0
    set g_Gui(camDist) 5.0
}

proc AskOpen {} {
    set fileTypes {
        { "PDB files" "*.pdb" }
        { "All files" * }
    }
    if { $::tcl_platform(os) eq "Darwin" && [info exists ::starkit::topdir] } {
        set fileName [::tk::dialog::file:: open -filetypes $fileTypes \
                                                -initialdir $::g_LastDir]
    } else {
        set fileName [tk_getOpenFile -filetypes $fileTypes \
                                     -initialdir $::g_LastDir]
    }
    if { $fileName ne "" } {
        set ::g_LastDir [file dirname $fileName]
        ResetTfm
        ReadMolecule $fileName
        CreateDisplayList
    }
}

ResetTfm

set ::g_ShowAtoms      1
set ::g_ShowConnects   1
set ::g_LineMode       0
set ::g_UseDisplayList 0
set ::g_AnimStarted    0
 
UpdateTitle "None"

set frMast [frame .fr]
set frTogl [frame .fr.togl]
set frMole [frame .fr.mole]
set frCmds [frame .fr.cmds]
set frInfo [frame .fr.info]
pack $frMast -expand 1 -fill both

grid $frTogl -row 0 -column 0 -sticky news
grid $frMole -row 0 -column 1 -sticky news
grid $frCmds -row 1 -column 0 -columnspan 2 -sticky news
grid $frInfo -row 2 -column 0 -columnspan 2 -sticky news
grid rowconfigure .fr 0 -weight 1
grid columnconfigure .fr 0 -weight 1

# Exhaustive Togl initialization probe
set togl_success 0
set togl_error "Unknown error"
foreach cb_set {
    {-displaycommand tclDisplayFunc -reshapecommand tclReshapeFunc -createcommand tclCreateFunc}
    {-displayproc tclDisplayFunc -reshapeproc tclReshapeFunc -createproc tclCreateFunc}
} {
    foreach vis_set {
        {-double 1 -depth 1 -rgba 1}
        {-double 1 -depth 1}
        {-double 0 -depth 1}
        {-double 1 -depth 0}
        {-double 0 -depth 0}
        {-rgba 1}
        {}
    } {
        if {![catch {togl $frTogl.toglwin -width 400 -height 400 {*}$cb_set {*}$vis_set} togl_msg]} {
            set togl_success 1
            break
        } else {
            set togl_error $togl_msg
        }
    }
    if {$togl_success} break
}

if {!$togl_success} {
    # Final attempt with absolutely minimal options
    if {[catch {togl $frTogl.toglwin -width 400 -height 400} final_msg]} {
        error "Fatal Togl Error: $togl_error (Minimal attempt: $final_msg)"
    }
}
pack $frTogl.toglwin -side top -expand 1 -fill both

set frSett [frame $frCmds.sett]
set frBttn [frame $frCmds.btns]
pack $frSett $frBttn -side left -expand 1 -fill both

set modOptFr $frSett.labelfr
labelframe $modOptFr -text "Modelling options"
pack $modOptFr -expand 1 -fill both

label $modOptFr.l1 -text "Number of slices per sphere:"
spinbox $modOptFr.s1 -from 4 -to 30 \
                       -textvariable ::g_NumSlices -width 4 \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay }

label $modOptFr.l2 -text "Number of stacks per sphere:"
spinbox $modOptFr.s2 -from 4 -to 30 \
                       -textvariable ::g_NumStacks -width 4 \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay }

label $modOptFr.l3 -text "Atom radius scale:"
set scaleRange [list 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
spinbox $modOptFr.s3 -values $scaleRange \
                       -textvariable ::g_AtomScale -width 4 \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay }

label $modOptFr.l4 -text "Line width of connects:"
spinbox $modOptFr.s4 -from 1 -to 10 \
                        -textvariable ::g_LineWidth -width 4 \
                        -command { CreateDisplayList ; $frTogl.toglwin postredisplay }

label $modOptFr.l5 -text "Number of atoms:"
label $modOptFr.i5 -text ""
set ::g_InfoAtomLabel $modOptFr.i5

label $modOptFr.l6 -text "Number of connects:"
label $modOptFr.i6 -text ""
set ::g_InfoConLabel $modOptFr.i6

grid $modOptFr.l1 -row 0 -column 0 -sticky w
grid $modOptFr.l2 -row 1 -column 0 -sticky w
grid $modOptFr.l3 -row 2 -column 0 -sticky w
grid $modOptFr.l4 -row 3 -column 0 -sticky w
grid $modOptFr.l5 -row 4 -column 0 -sticky w
grid $modOptFr.l6 -row 5 -column 0 -sticky w
grid $modOptFr.s1 -row 0 -column 1 -sticky e
grid $modOptFr.s2 -row 1 -column 1 -sticky e
grid $modOptFr.s3 -row 2 -column 1 -sticky e
grid $modOptFr.s4 -row 3 -column 1 -sticky e
grid $modOptFr.i5 -row 4 -column 1 -sticky ew
grid $modOptFr.i6 -row 5 -column 1 -sticky ew

set dispOptFr $frBttn.labelfr
labelframe $dispOptFr -text "Display options"
pack $dispOptFr -expand 1 -fill both -anchor w

checkbutton $dispOptFr.b1 -text "Use display list" -indicatoron 1 \
                       -variable ::g_UseDisplayList \
                       -command ToggleDisplayList
checkbutton $dispOptFr.b2 -text "Use line mode" -indicatoron 1 \
                       -variable ::g_LineMode \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay } 
checkbutton $dispOptFr.b3 -text "Show atoms" -indicatoron 1 \
                       -variable ::g_ShowAtoms \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay }
checkbutton $dispOptFr.b4 -text "Show connects" -indicatoron 1 \
                       -variable ::g_ShowConnects \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay }

# Finally pack all children of the modelling options labelframe.
eval pack [winfo children $dispOptFr] -side top -anchor w

frame $frMole.fr
pack $frMole.fr -side top -expand 1 -fill both -padx 1
set g_AtomCountLb [tcl3dCreateScrolledListbox $frMole.fr "Atom List" \
                 -font $::g_ListFont -selectmode single]

button $frMole.sel -command "AskOpen" -text "Open PDB ..."
pack $frMole.sel -side top -padx 1 -fill x

checkbutton $frMole.anim -text "Animate" -indicatoron [tcl3dShowIndicator] \
                         -variable ::g_AnimStarted \
                         -command { ShowAnimation $frTogl.toglwin }
set ::g_AnimateBtn $frMole.anim
pack $frMole.anim -side top -padx 1 -fill x

set glInfo [format "Running on %s with a %s (OpenGL %s, Tcl %s)" \
           $tcl_platform(os) [glGetString GL_RENDERER] \
           [glGetString GL_VERSION] [info patchlevel]]
label $frInfo.l1 -text $glInfo
eval pack [winfo children $frInfo] -pady 2 -side top -expand 1 -fill x

trace add variable ::g_NumStacks write UpdateNumSpheres
trace add variable ::g_NumSlices write UpdateNumSpheres
trace add variable ::g_NumAtoms  write UpdateNumSpheres

set ::g_NumCons    0
set ::g_NumAtoms   0
set ::g_NumSlices 15
set ::g_NumStacks 10
set ::g_LineWidth  2
set ::g_AtomScale  "0.80"

bind $frTogl.toglwin <<LeftMousePress>>   {set ::g_Mouse(x) %x; set ::g_Mouse(y) %y}
bind $frTogl.toglwin <<MiddleMousePress>> {set ::g_Mouse(x) %x; set ::g_Mouse(y) %y}
bind $frTogl.toglwin <<RightMousePress>>  {set ::g_Mouse(x) %x; set ::g_Mouse(y) %y}

bind $frTogl.toglwin <<LeftMouseMotion>>   {HandleRot %x %y %W}
bind $frTogl.toglwin <<MiddleMouseMotion>> {HandleTrans X %x %y %W}
bind $frTogl.toglwin <<RightMouseMotion>>  {HandleTrans Z %x %y %W}

# Watch For ESC Key And Quit Messages
wm protocol . WM_DELETE_WINDOW "ExitProg"
bind . <Key-Escape> "ExitProg"

if { [file tail [info script]] eq [file tail $::argv0] } {
    # If started directly from tclsh or wish, then check for commandline parameters.
    if { $argc >= 1 } {
        ReadMolecule [lindex $argv 0]
    }
} else {
    ReadMolecule [file join $g_ScriptDir "Caffeine.pdb"]
}
