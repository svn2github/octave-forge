#!/bin/sh
# required line \
exec wish "$0" "$@"

# For this tutorial I'm going to construct an application which displays
# a matrix as an image, and shows the x-y slices for the point under the
# mouse.  Before you can use this, you must have a recent version of
# octave and octave-forge installed.
#
#	demo$ octave
#	> listen(3132)
#
# This starts an octave listening daemon.  To remove it you will have
# to use kill directly after using ps aux | grep octave to find its pid.
#
# To start the demo, do the following:
#
#	demo$ ./matrix.tcl
#
# Slide the mouse over the matrix to see cross-sectional slices.  
# Click and drag the mouse to see and example of a slowww callback (up
# to 1s between refreshes).


# Load the required modules. Tcl has no native support for vectors or 
# for graphs, so octave.tcl requires BLT.

package require BLT
namespace import blt::graph blt::vector
package require octave

# Before using octave you need to open a connection to the octave compute 
# server. This does whatever is necessary to start the octave process and
# open a communication channel.  Depending on the underlying communication
# mechanism, this command may do nothing.

octave connect [lindex $argv 0]

# Construct an image to display.

octave eval {
    # Modified from sombrero.m, GPL Copyright (C) 1996 1997 John W. Eaton
    x = linspace (-6, 8, 100);
    y = linspace (-2, 8, 50);
    [xx, yy] = meshgrid (x, y);
    z = sinc (sqrt (xx .^ 2 + yy .^ 2));
    z = z + randn(size(z))*0.05;
}

# Compute the limits on the graph axes.
# Assume values are computed at the centers of the pixels,
# so fluff the x/y range by half a grid step.

octave recv minx { x(1) - (x(2)-x(1))/2 }
octave recv maxx { x(length(x)) + (x(2)-x(1))/2 }
octave recv miny { y(1) - (y(2)-y(1))/2 }
octave recv maxy { y(length(y)) + (y(2)-y(1))/2 }
octave recv minz min(z(:))
octave recv maxz max(z(:))

# Define tcl variable to hold the image and slices.

image create photo sombrero
vector create ::x ::xv ::y ::yv

# Grab the matrix from octave variable z and store it in the sombrero image.
# The image must be indexed to the length of the current colormap.  Also
# grab the unchanging x,y vectors.  Leave the xv,yv vectors for draw_slices
# to grab when they are needed.

octave eval { colormap(ocean) }
octave recv sombrero imagesc(z)
octave recv x
octave recv y

# Define layout for the graphs.

graph .matrix
# Blt_Crosshairs .matrix
graph .xslice -height 200
graph .yslice -width 200
.xslice legend conf -hide 1
.yslice legend conf -hide 1
grid .matrix .yslice -sticky news
grid .xslice x -sticky news
grid rowconf . 0 -weight 1
grid columnconf . 0 -weight 1


# Use x2-y for the image, x2-y2 for the Y slice and x-y for the X slice
# Fix margin sizes so that scales are commensurate between the graphs

.matrix xaxis configure -hide yes
.matrix x2axis configure -hide no
.yslice yaxis configure -hide yes
.yslice y2axis configure -hide no
.yslice xaxis configure -hide yes
.yslice x2axis configure -hide no
.matrix conf -lm 50 -tm 50 -rm 0 -bm 0
.yslice conf -rm 50 -tm 50 -lm 0 -bm 0
.xslice conf -lm 50 -bm 50 -rm 0 -tm 0

# Add data lines for the x-y slices.  Remember that the y slice is displayed
# sideways using the opposite axes.

.xslice element create slice -xdata x -ydata xv -pixel 2
.yslice element create slice -xdata yv -ydata y -mapx x2 -mapy y2 -pixel 2

# Add graph limits and image to graphs.  Since the limits are computed in
# octave, we must be sure that the values are defined.  The octave sync
# command makes sure that all pending octave commands have been completed
# and all results have been received by tcl.  Because it is an expensive
# operation, we arrange our statements so that it is done as little as
# possible which in our case is once.  We do not need the octave sync in
# the draw_slices routine since BLT handles redisplaying the slices when
# the values are received.

octave sync
foreach { g a v } { .matrix x2 x .xslice x  x 
                    .matrix y  y .yslice y  y
                    .xslice y  z .yslice x2 z } {
    $g axis conf $a -min [set min$v] -max [set max$v]
}
.matrix marker create image -coords "$minx $miny $maxx $maxy" -mapx x2 \
	-image sombrero


# simple mouse motion draws the slices under the mouse cursor; 'slow' makes
# sure that only one instance of the callback is active at a time.
bind .matrix <Motion> { octave sync draw_slices %x %y }

# button 3 uses applies a median filter to each slice before drawing it 
bind .matrix <B3-Motion> { octave sync draw_slices %x %y -median }
bind .matrix <ButtonPress-3> { octave sync draw_slices %x %y -median }
bind .matrix <ButtonRelease-3> { octave sync draw_slices %x %y }

# button 1 draws the slices under the mouse cursor, but queues the
# requests as they are coming in.  Unless your machine and network stack
# are very fast, the updates will lag the cursor position and continue
# well after you stop moving the mouse.
bind .matrix <B1-Motion> { draw_slices %x %y }


# Draw slices.
# We have two different variations: a simple slice and one which does a 
# median filter on the slice using an octave loop to show how to handle
# slow callbacks cleanly.

proc draw_slices { x y { opt {} } } {
    octave eval ptx=[.matrix axis invtransform x2 $x]
    octave eval pty=[.matrix axis invtransform y $y]
    octave eval {
	xidx = interp1(x,[1:length(x)],ptx,'nearest','extrap');
	yidx = interp1(y,[1:length(y)],pty,'nearest','extrap');
    }
    switch -- $opt {
	-median {
	    octave recv xv slow_medfilt1(z(yidx,:),5)
	    octave recv yv slow_medfilt1(z(:,xidx),5)
	} default {
	    octave recv xv z(yidx,:)
	    octave recv yv z(:,xidx)
	}
    }
}

# Median filtering on the drawn slices.  In practice, you should be using
# medfilt1 since it is very much faster, but that wouldn't make a very
# good example of a slow operation.
octave eval {
    function t = slow_medfilt1(x,n)
        t = zeros(size(x));
        shift = floor(n/2);
        x = [ zeros(shift,1); x(:); zeros(n-shift,1) ];
        for i=1:length(t)
            t(i) = median(x(i:i+n-1));
        endfor
    endfunction
}



# Allow for a really long timeout for a very slow callback.  Note that
# having a timeout on individual sync calls does not make sense, since
# one slow call is going to delay all subsequent calls.
octave timeout 20000
