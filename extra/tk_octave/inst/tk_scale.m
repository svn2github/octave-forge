
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

# tk_scale (title, scale_1, ...)
#
#	scale = legend, initial_value, min, max , resolution
#
# display N vertical scales, each one labeled with legend; each scale is
# initially set to initial_value, and its value can span from  min to
# max in resolution increments.
#
# E.g.: [eta lamb mu] = tk_scale("Scale Demo", "eta", 3, 1, 10, 0.1,
#	"lambda", 4, 2, 20, 1, "mu", 0.01, 0.001, 0.1, 0.01)

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * converted to work with pthreads-based tk_octave

function [varargout] = tk_scale (title, varargin)

tk_init

if (nargin < 5)
	help tk_scale
	return
endif

tk_cmd( sprintf("toplevel .master") );

if (! isempty (title))
    tk_cmd( sprintf("wm title .master \"%s\"", title) );
    tk_cmd( sprintf("label .master.ltitle -text \"%s\"; \
		pack .master.ltitle -side top", title) );
endif

tk_cmd( "button .master.quit -text Done -command {destroy .master}" );
tk_cmd( "pack .master.quit -side bottom" );
	
nopt = (nargin - 1)/5;
cmd_ok = cmd_res = "";

va_arg_cnt = 1;

for i=1:nopt
    desc = varargin{va_arg_cnt++};
    val = varargin{va_arg_cnt++};
    min_val = varargin{va_arg_cnt++};
    max_val = varargin{va_arg_cnt++};
    inc_val = varargin{va_arg_cnt++};
	
    tk_cmd( sprintf("set val_%d %f", i, val) );
    tk_cmd( sprintf("scale .master.s%d -from %f -to %f \
		-resolution %f 	-label {%s} -variable val_%d \
		-showvalue 1", ...
		     i, min_val, max_val, inc_val, desc, i) );
    tk_cmd( sprintf("pack .master.s%d -side left", i) );

endfor

tk_cmd( "tkwait window .master" );
	
for i=1:nopt
    varargout{i} = eval([tk_cmd(sprintf("set val_%d",i)), ";"]);
endfor

endfunction

