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

## usage: [r1, r2, ...] = tk_entry (title, name, value, name, value, ...)
##
## Dialog to input several variables at once.

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * convert for pthreads-based tk_octave

function [varargout] = tk_entry (t, varargin)

tk_init

if (nargin < 2)
    usage ("tk_entry (title, legend_1, value_1 | variable_1, ...)");
endif

tk_cmd( sprintf( "proc isnum {x} {regexp {^[0-9.eE+-]*$} $x}") );
    
tk_cmd( sprintf( "proc varcheck {name element op} {\n\
upvar $name x ${name}_ x_\n\
if {([isnum $x] && ![isnum $x_]) || (![isnum $x] && [isnum $x_])} {\n\
	set erro [format \"Value entered, `%%s' has not same type as previous one, `%%s'\" $x $x_]\n\
	set x $x_\n tkerror $erro \n}\n}\n") );

tk_cmd( sprintf("wm deiconify .;frame .master") );

if (! isempty (t))
    tk_cmd( sprintf("wm title . \"%s\"", t) );
	tk_cmd( sprintf("label .master.ltitle -pady 5 -relief groove -borderwidth 2 -text \"%s\";\
		pack .master.ltitle -fill x -side top", t) );
endif

    nopt = (nargin - 1)/2;
    cmd_ok = cmd_res = "";
	va_arg_cnt = 1;

    
for i=1:nopt
	desc = nth (varargin, va_arg_cnt++);
	val = nth (varargin, va_arg_cnt++);

	tk_cmd( sprintf( "unset val_%d val_%d_\n", i, i) );	# unset previous invocation values

	if (isstr(val))									# string
		tk_cmd( sprintf( "set val_%d \"%s\"", i, val) );	# work value
		tk_cmd( sprintf( "set val_%d_ \"%s\"", i, val) );	# original value
		cmd_ok = strcat( cmd_ok, sprintf("val_%d = \\\"$val_%d\\\";", i, i));
	elseif (floor(val) == val)						# integer
		tk_cmd( sprintf( "set val_%d %d", i, val));
		tk_cmd( sprintf( "set val_%d_ %d", i, val));
		cmd_ok = strcat( cmd_ok, sprintf("val_%d = $val_%d;", i, i));
	else											# float
		tk_cmd( sprintf( "set val_%d %f", i, val));
		tk_cmd( sprintf( "set val_%d_ %f", i, val));
		cmd_ok = strcat( cmd_ok, sprintf("val_%d = $val_%d;", i, i));
	endif
	
	tk_cmd( sprintf( "trace variable val_%d w varcheck", i));

	tk_cmd( sprintf( "frame .master.f%d", i));
	tk_cmd( sprintf( "entry .master.f%d.e%d -textvariable val_%d", i, i, i));
	tk_cmd( sprintf( "pack .master.f%d -fill x", i));
        if (desc != "")
	  tk_cmd( sprintf( "label .master.f%d.l%d -font 8x13bold -text \"%s\"", i, i, desc));
	  tk_cmd( sprintf( "pack .master.f%d.l%d -side left", i, i));
	endif
	tk_cmd( sprintf( "pack .master.f%d.e%d -side right", i, i));
	tk_cmd( sprintf( "bind .master.f%d.e%d <Return> {set val_%d $val_%d}", i, i, i, i));
	tk_cmd( sprintf( "bind .master.f%d.e%d <Tab> {set val_%d $val_%d}", i, i, i, i));
	cmd_res = strcat( cmd_res, sprintf("set val_%d $val_%d_;", i, i));
endfor

tk_cmd( sprintf( "frame .master.f%d -relief groove -borderwidth 2", nargin) );
	
tk_cmd( sprintf( "button .master.f%d.b1 -text OK -command { destroy .master}", nargin) );
tk_cmd( sprintf( "bind .master.f%d.b1 <Return> {destroy .master }", nargin) );
tk_cmd( sprintf( "button .master.f%d.b2 -text Restore -command {%s}", nargin, cmd_res) );
tk_cmd( sprintf( "bind .master.f%d.b2 <Return> {%s}", nargin, cmd_res) );
tk_cmd( sprintf( "pack .master.f%d -side bottom -fill x", nargin) );
tk_cmd( sprintf( "pack .master.f%d.b1 .master.f%d.b2 -side left", nargin, nargin) );

tk_cmd( sprintf("pack .master -fill both -expand 1") );

tk_cmd( "tkwait window .master" );
eval(tk_cmd(sprintf("set result \"%s\" ", cmd_ok )));

@@ -98,6 +98,7 @@
 
vr_val_cnt = 1;
 for i=1:nopt
        varargout{vr_val_cnt++} = eval(sprintf("val_%d;",i));
        tk_cmd( sprintf( "trace vdelete val_%d w varcheck", i) );
 endfor
 	
endfunction
