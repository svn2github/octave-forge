## Copyright (C) 1998, 1999, 2000 Joao Cardoso.
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2 of the License, or (at your
## option) any later version.
## 
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## This file is part of tk_octave.

## st = tk_progress_cancel(intp [, val [, text])
##
## similar to tk_progress but with a stop button.
## when called returns 1 if the stop button has been pressed.
##
## see also tk_progress

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * converted for use with pthreads-based tk_octave
## * allow test of cancel without setting a new value

function st = tk_progress_cancel(val, text)

        st = 0;

        tk_init

	if (nargin == 0 && nargout == 0)
		tk_cmd( "destroy .top_progress" );
		return
	endif

	if (tk_cmd( "winfo exists .top_progress") == "0")
		tk_cmd( "toplevel .top_progress" );
		tk_cmd( "wm title .top_progress Progress" );
		tk_cmd( "label .top_progress.lab1 -relief ridge \
-text \"Wait please\" -padx 10 -pady 5 -textvariable tk_progress_message" ); 
		tk_cmd( "scale .top_progress.sca1 -orient horiz \
-showvalue 1 -sliderlength 10 -state disabled -variable tk_progress_value" );

		tk_cmd( "button .top_progress.b1 -text Stop -command {set stop 1}" );
		tk_cmd( "set stop 0" );
		tk_cmd( "pack .top_progress.lab1 -anchor center -expand 1 \
-fill both -padx 20 -pady 10 -side top" ); 
		tk_cmd( "pack .top_progress.sca1 -anchor center -expand 1 \
-fill x -padx 20 -pady 10 -side top" );
		tk_cmd( "pack .top_progress.b1" );
	endif

	if (nargin >= 1)
		tk_cmd( sprintf("set tk_progress_value %d", val) );
		st = str2num(tk_cmd("set stop"));
	endif
	if (nargin == 2)
		tk_cmd( sprintf( "set tk_progress_message \"%s\"", text) );
		tk_cmd( sprintf( "wm title .top_progress {%s}", text) );
	endif

endfunction
