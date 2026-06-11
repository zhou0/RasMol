package require Tk
catch {package require tcl3d}
catch {package require Togl}

puts "Togl version: [package provide Togl]"
puts "Togl command: [info commands togl]"

proc try_togl {name opts} {
    puts -nonewline "Trying: togl $name $opts ... "
    if {[catch {eval togl $name $opts} msg]} {
        puts "FAILED: $msg"
        return 0
    } else {
        puts "SUCCESS"
        destroy $name
        return 1
    }
}

try_togl .t1 {-width 100 -height 100 -double 1 -depth 1}
try_togl .t2 {-width 100 -height 100 -double 0 -depth 1}
try_togl .t3 {-width 100 -height 100 -double 1 -depth 0}
try_togl .t4 {-width 100 -height 100 -double 0 -depth 0}

# End script
