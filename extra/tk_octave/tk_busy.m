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

## tk_busy (text)
##
## Opens a new window with 'text' printed end with a flashing hourglass.
##
## If called with no arguments, close the window.
## If the window already exists, 'text' is updated
## Only one tk_busy window is allowed at one time.
##
## Octave can continue processing while the hourglass is flashing.

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * convert to pthreads version of octave
## * fix grammar in documentation

function tk_busy (text)

eval("tk_interp","");

if (nargin == 0)
	tk_cmd( "foreach i [after info] {after cancel $i}" );
	tk_cmd( sprintf("proc rep {} {}") );
	tk_cmd( "destroy .top_tk_busy" );
elseif (tk_cmd( "winfo exists .top_tk_busy" ) == "1")
	tk_cmd ( sprintf("set tk_busy_message \"%s\"", text) );
	tk_cmd(  sprintf( "wm title .top_tk_busy {%s}", text) );
else
        tk_cmd( "toplevel .top_tk_busy -borderwidth 2 -relief groove" );
        tk_cmd( sprintf( "wm title .top_tk_busy {%s}", text) );
        #tk_cmd( "wm withdraw .top_tk_busy" );
        tk_cmd( "label .top_tk_busy.l1 -textvar tk_busy_message -relief ridge -padx 10 -pady 5");
        tk_cmd (sprintf("set tk_busy_message \"%s\"", text)); 
        tk_cmd ("button .top_tk_busy.b1 -bitmap hourglass");

        #tk_cmd("wm overrideredirect .top_tk_busy 1");

        tk_cmd("pack .top_tk_busy.l1 .top_tk_busy.b1 \
 -ipadx 2 -ipady 2 -padx 10 -pady 10");

        #tk_cmd("wm deiconify .top_tk_busy");

        tk_cmd("proc rep {a b} { .top_tk_busy.b1 configure \
-foreground $a -background $b; after 1000 rep $b $a}");
        tk_cmd("rep salmon green4");
endif

endfunction
