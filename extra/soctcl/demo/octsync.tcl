#!/bin/sh

# usage: octsync.tcl ?port
#
# This is a lowlevel test of the octave server synchronization
# response time.  It uses the octave listen() protocol directly
# rather than going through the octcl package.  Any delays seen
# are directly due to tcl and to octave's implementation of sockets
# and not any special handling I'm doing in octave.tcl.
#
# The command bounce $n sends a message to octave telling it to
# send the command bounce $n-1 to tcl.  At the beginning of
# every bounce, it reports the cumulative time.  By contrast,
# start echod.tcl in this directory and try echosync.tcl.
# I find echosync to be somewhat more responsive than octsync,
# but I cannot explain why.

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
	set head [read $file 8]
	while { [string length $head] == 0 } { 
	    if { [eof $file] } { close $file; puts "yucky exit"; exit }
	    set head [read $file 8]
	}
puts "length of head=[string length $head]"
        binary scan $head a4I cmd len
puts "$cmd<$len>"
        switch -- $cmd {
	    !!!x {
		set body [read $file $len]
		puts "cmd=<$body>"
	        if [catch { uplevel #0 $body } msg ] {
		    puts "octave tcl failed for <$body>\n$msg"
		}
 	    }
	    default { puts huh? }
	}
    }
}

set fd [socket localhost [lindex $argv 0]]
fconfigure $fd -blocking true -buffering none -translation binary
fileevent $fd readable [list recv $fd]

proc octave_send { f cmd } {
   puts -nonewline $f "!!!x[binary format I [string length $cmd]]$cmd"
}

proc bounce { f n } {
    puts "bounce $n at time [toc]ms"
    if { $n } { 
        octave_send $f "send('bounce $f [expr $n-1]')" 
    } else {
    	set ::forever 1
    }
}

tic; bounce $fd 5

vwait forever
close $fd
