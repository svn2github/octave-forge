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

# usage: tk_menu (title, opt1, ...)

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * convert for pthreads-based tk_octave

function num = tk_menu (t, varargin)

tk_init

if (nargin < 2)
	usage ("tk_menu (title, opt1, ...)");
endif

tk_cmd( "proc quit {} { destroy .master; wm withdraw . }" );
tk_cmd( "wm deiconify .;frame .master" );

if (! isempty (t))
	tk_cmd( sprintf("wm title . \"%s\"", t) );
	tk_cmd( sprintf("label .master.ltitle -text \"%s\";\
 		pack .master.ltitle -side top", t) );
endif

nopt = nargin - 1;

va_arg_cnt = 1;

for i = 1:nopt
	tk_cmd( sprintf ("button .master.b%d -text \"%s\" -command { set menuChoice %d; quit}", i, nth (varargin, va_arg_cnt++), i) );
	tk_cmd( sprintf ("pack .master.b%d -fill x", i) );
endfor

tk_cmd( "pack .master" );
tk_cmd( "tkwait window .master" );
num = sscanf(tk_cmd( "set menuChoice" ), "%d");

endfunction

