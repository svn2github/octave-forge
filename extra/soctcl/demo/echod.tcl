#!/bin/sh
# usage: echod.tcl
#
# Simple echo daemon on port 6789.
# Every line it receives is echoed straight back.
#
# \
exec tclsh "$0" "$@"

proc recv { file } {
    if { [eof $file] } {
	close $file
	puts "Client closed the connection"
    } else {
	puts $file [gets $file]
    }
}

proc accept {socket address port} {
    puts "receiving connection from $address:$port on $socket"
    fileevent $socket readable "recv $socket"
    fconfigure $socket -buffering line
}
set fd [socket -server accept 6789]

vwait forever
