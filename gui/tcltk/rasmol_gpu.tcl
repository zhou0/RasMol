# GPU Rendering for RasMol using Tcl3D

proc rasmol_gpu_init {w} {
    glEnable GL_DEPTH_TEST; glEnable GL_LIGHT0; glEnable GL_LIGHTING; glEnable GL_COLOR_MATERIAL
    glLightfv GL_LIGHT0 GL_POSITION {100.0 100.0 100.0 1.0}
    glClearColor 0.0 0.0 0.0 1.0
}

proc rasmol_gpu_reshape {toglwin {w ""} {h ""}} {
    if {$w eq "" || $h eq ""} { set w [winfo width $toglwin]; set h [winfo height $toglwin] }
    if {$w <= 1} { set w 400 }; if {$h <= 1} { set h 400 }
    set ::g_WinWidth $w; set ::g_WinHeight $h
    glViewport 0 0 $w $h
    glMatrixMode GL_PROJECTION; glLoadIdentity; gluPerspective 45.0 [expr {double($w)/$h}] 1.0 10000.0
    glMatrixMode GL_MODELVIEW
}

proc rasmol_gpu_draw {w} {
    glClear [expr {$::GL_COLOR_BUFFER_BIT | $::GL_DEPTH_BUFFER_BIT}]
    glLoadIdentity
    if {![info exists ::g_Atoms(numAtoms)] || $::g_Atoms(numAtoms) == 0} { $w swapbuffers; return }
    set dist [expr {800.0 / ($::g_Gui(zoom) + 1.0)}]
    if {$dist < 50} {set dist 50}
    gluLookAt 0.0 0.0 $dist 0.0 0.0 0.0 0.0 1.0 0.0
    glPushMatrix
    glRotatef $::g_Gui(rotX) 1.0 0.0 0.0; glRotatef $::g_Gui(rotY) 0.0 1.0 0.0; glRotatef $::g_Gui(rotZ) 0.0 0.0 1.0
    glTranslatef [expr {-$::g_Gui(rotCenX)}] [expr {-$::g_Gui(rotCenY)}] [expr {-$::g_Gui(rotCenZ)}]
    if {$::display_mode != 4} {
        glDisable GL_LIGHTING; glColor3f 1.0 1.0 1.0; glBegin GL_LINES
        foreach s1 [array names ::g_Cons] {
            foreach s2 $::g_Cons($s1) {
                if {![info exists ::g_Atoms($s1,x)] || ![info exists ::g_Atoms($s2,x)]} continue
                glVertex3f $::g_Atoms($s1,x) $::g_Atoms($s1,y) $::g_Atoms($s1,z)
                glVertex3f $::g_Atoms($s2,x) $::g_Atoms($s2,y) $::g_Atoms($s2,z)
            }
        }
        glEnd; glEnable GL_LIGHTING
    }
    if {$::display_mode == 4 || $::display_mode == 5} {
        set q [gluNewQuadric]
        foreach k [array names ::g_Atoms "*,x"] {
            set s [lindex [split $k ","] 0]
            glPushMatrix; glTranslatef $::g_Atoms($s,x) $::g_Atoms($s,y) $::g_Atoms($s,z)
            set cl $::g_Atoms($s,color); glColor3f [lindex $cl 0] [lindex $cl 1] [lindex $cl 2]
            gluSphere $q [expr {$::g_Atoms($s,radius)*0.4}] 12 12
            glPopMatrix
        }
        gluDeleteQuadric $q
    } else {
        glPointSize 4.0; glBegin GL_POINTS
        foreach k [array names ::g_Atoms "*,x"] {
            set s [lindex [split $k ","] 0]; set cl $::g_Atoms($s,color)
            glColor3f [lindex $cl 0] [lindex $cl 1] [lindex $cl 2]; glVertex3f $::g_Atoms($s,x) $::g_Atoms($s,y) $::g_Atoms($s,z)
        }
        glEnd
    }
    glPopMatrix; $w swapbuffers
}
