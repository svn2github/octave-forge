#!/bin/sh
# Round trip time for an echo message.  First start echod.tcl then
# run this command.  Client and server are both pure tcl so we
# can't expect to do better than this in our Octave server.  See 
# comments at the start of octsync.tcl for an explanation.
# \
exec tclsh "$0" "$@"

proc tic {} { set ::time [clock clicks -millisecond] }
proc toc {} { return [expr {[clock clicks -millisecond] - $::time}] }
proc recv { file } {
    if { [eof $file] } {
	close $file
	puts "Server closed the connection"
	exit
    } else {
	uplevel "\#0" [gets $file]
    }
}

set fd [socket localhost 6789]
fconfigure $fd -blocking true -buffering none -translation binary
fileevent $fd readable [list recv $fd]

proc bounce { f n } {
    puts "bounce $n at time [toc]ms"
    if { $n } { 
        puts $f "bounce $f [expr $n-1]" 
    } else {
    	set ::forever 1
    }
}

tic; bounce $fd 5

vwait forever
close $fd
