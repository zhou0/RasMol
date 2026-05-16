proc check_braces {filename} {
    set f [open $filename r]
    set content [read $f]
    close $f
    set balance 0
    set line 1
    foreach char [split $content ""] {
        if {$char eq "{"} {
            incr balance
        } elseif {$char eq "}"} {
            set balance [expr {$balance - 1}]
        } elseif {$char eq "\n"} {
            incr line
        }
        if {$balance < 0} {
            puts "Error: Unmatched closing brace at line $line"
            return 1
        }
    }
    if {$balance != 0} {
        puts "Error: Unbalanced braces, balance is $balance"
        return 1
    }
    puts "Success: Braces are balanced."
    return 0
}
check_braces gui/tcltk/rasmol_ui.tcl
