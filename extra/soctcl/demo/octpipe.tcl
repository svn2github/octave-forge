#!/bin/sh

# usage: octsync.tcl ?port
#
# This is a lowlevel test of the octave server synchronization
# response time.  It uses the octave pipes instead of sockets.
# It does not use the octcl package.
#
# The command bounce $n sends a message to octave telling it to
# send the command bounce $n-1 to tcl.  At the beginning of
# every bounce, it reports the cumulative time.  By contrast,
# start echod.tcl in this directory and try echosync.tcl.
# I find echosync to be somewhat more responsive than octsync,
# but I cannot explain why.

# \
exec tclsh "$0" "$@"

package require BLT

proc tic {} { set ::time [clock clicks -millisecond] }
proc toc {} { return [expr {[clock clicks -millisecond] - $::time}] }
proc recv { file } {
    if { [eof $file] } {
	close $file
	puts "Server closed the connection"
	exit
    } else {
	set line [gets $file]
	switch -glob -- $line {
	    !!!x* { 
		set body [string range $line 4 end]
		# puts "cmd=<$body>"
	        if [catch { uplevel #0 $body } msg ] {
		    puts "octave tcl failed for <$body>\n$msg"
		}
 	    }
	    !!!m* {
	    	foreach {cmd r c name} [split $line] break;
		blt::vector create ::$name
		::$name delete :
		::$name binread $file [expr {$r*$c}]
	    }
	    default { puts "Skipping <$line>" }
	}
    }
}

set fd [open "|octave -q" r+]
fconfigure $fd -blocking true -buffering none -translation binary
fileevent $fd readable [list recv $fd]

proc octave_send { f cmd } {
   puts $f $cmd ; flush $f
}

proc bounce { f n } {
    puts "bounce $n at time [toc]ms"
    if { $n } { 
        octave_send $f "printf('!!!xbounce $f [expr $n-1]\\n');" 
    } else {
    	set ::forever 1
    }
}

tic; octave_send $fd { printf('!!!xputs "toc=[toc]"\n'); }
tic; octave_send $fd {
    x=[1:100000];
    printf("!!!m %d %d %s\n",rows(x),columns(x),'x');
    fwrite(stdout,x,'double');
    fflush(stdout);
    printf('!!!xputs "vector 100000 time=[toc]"\n');
}

tic; bounce $fd 5

vwait forever
close $fd
