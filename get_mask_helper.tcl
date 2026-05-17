proc get_rasmol_mask {tk_s {button 0}} {
    set s 0
    if {$button == 1 || ($tk_s & 0x100)} { set s [expr {$s | 1}] }
    if {$button == 2 || ($tk_s & 0x200)} { set s [expr {$s | 2}] }
    if {$button == 3 || ($tk_s & 0x400)} { set s [expr {$s | 4}] }
    if {$tk_s & 1} { set s [expr {$s | 8}] }
    if {$tk_s & 4} { set s [expr {$s | 16}] }
    return $s
}
