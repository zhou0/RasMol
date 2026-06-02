# GPU Rendering for RasMol using Tcl3D

proc rasmol_gpu_init {w} {
    glEnable GL_DEPTH_TEST
    glEnable GL_LIGHT0
    glEnable GL_LIGHTING
    glEnable GL_COLOR_MATERIAL

    set light_pos {1.0 1.0 1.0 0.0}
    glLightfv GL_LIGHT0 GL_POSITION $light_pos

    glClearColor 0.0 0.0 0.0 1.0
}

proc rasmol_gpu_reshape {toglwin {w ""} {h ""}} {
    if {$w eq "" || $h eq ""} {
        set w [winfo width $toglwin]
        set h [winfo height $toglwin]
    }
    if {$w <= 1} { set w 400 }
    if {$h <= 1} { set h 400 }

    set ::g_WinWidth $w
    set ::g_WinHeight $h
    glViewport 0 0 $w $h
    glMatrixMode GL_PROJECTION
    glLoadIdentity
    gluPerspective 45.0 [expr {double($w)/$h}] 0.1 1000.0
    glMatrixMode GL_MODELVIEW
}

proc rasmol_gpu_draw {w} {
    global g_Atoms g_Cons g_Gui display_mode

    glClear [expr {$::GL_COLOR_BUFFER_BIT | $::GL_DEPTH_BUFFER_BIT}]
    glLoadIdentity

    # Simple camera positioning
    set zoom $g_Gui(zoom)
    if {$zoom <= 0} {set zoom 10.0}
    set dist [expr {400.0 / $zoom}]
    gluLookAt 0.0 0.0 $dist 0.0 0.0 0.0 0.0 1.0 0.0

    glPushMatrix
    # Apply transformations
    glRotatef $g_Gui(rotX) 1.0 0.0 0.0
    glRotatef $g_Gui(rotY) 0.0 1.0 0.0
    glRotatef $g_Gui(rotZ) 0.0 0.0 1.0

    # Center the molecule (translate back by rotCen)
    glTranslatef [expr {-$g_Gui(rotCenX)}] [expr {-$g_Gui(rotCenY)}] [expr {-$g_Gui(rotCenZ)}]

    # Draw Bonds
    if {$display_mode != 4} {
        glDisable GL_LIGHTING
        glColor3f 1.0 1.0 1.0
        glBegin GL_LINES
        foreach s1 [array names g_Cons] {
            if {![info exists g_Atoms($s1,x)]} continue
            foreach s2 $g_Cons($s1) {
                if {![info exists g_Atoms($s2,x)]} continue
                glVertex3f $g_Atoms($s1,x) $g_Atoms($s1,y) $g_Atoms($s1,z)
                glVertex3f $g_Atoms($s2,x) $g_Atoms($s2,y) $g_Atoms($s2,z)
            }
        }
        glEnd
        glEnable GL_LIGHTING
    }

    # Draw Atoms
    if {$display_mode == 4 || $display_mode == 5} {
        set quadObj [gluNewQuadric]
        foreach key [array names g_Atoms "*,name"] {
            set s [lindex [split $key ","] 0]
            glPushMatrix
            glTranslatef $g_Atoms($s,x) $g_Atoms($s,y) $g_Atoms($s,z)

            set color $g_Atoms($s,color)
            glColor3f [lindex $color 0] [lindex $color 1] [lindex $color 2]

            set r [expr {$g_Atoms($s,radius) * 0.4}]
            gluSphere $quadObj $r 12 12
            glPopMatrix
        }
        gluDeleteQuadric $quadObj
    } else {
        glPointSize 3.0
        glBegin GL_POINTS
        foreach key [array names g_Atoms "*,name"] {
            set s [lindex [split $key ","] 0]
            set color $g_Atoms($s,color)
            glColor3f [lindex $color 0] [lindex $color 1] [lindex $color 2]
            glVertex3f $g_Atoms($s,x) $g_Atoms($s,y) $g_Atoms($s,z)
        }
        glEnd
    }

    glPopMatrix
    $w swapbuffers
}
