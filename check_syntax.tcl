foreach f {gui/tcltk/molecules.tcl gui/tcltk/rasmol.tcl} {
  puts "Checking $f..."
  set fd [open $f r]
  set data [read $fd]
  close $fd
  if {![info complete $data]} {
    puts "Error: Incomplete Tcl script in $f (possible unbalanced braces)"
  } else {
    puts "$f is syntactically complete."
  }
}
