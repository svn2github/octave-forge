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

# tk_message(text [, time])
#
# Opens a new window and displays the "text" message during "time" seconds.
# if "time" is not specified, the default is five seconds.
#
# After "time" is elapsed, if a tk interpreter was launched,
# it will be terminated.
#
# If you want to cancel a message before "time" expires, call tk_message
# with only one (possibly empty) argument.
#
# If a further tk_message is issued before "time" of the previous one has
# expired, the new message will be displayed, and the timer rearmed with the
# new value.
#
# Octave can continue processing meanwhile.

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * support pthreads-based tk_octave
## * handle time=0 by putting up an Ok dialog box.

function tk_message(text, time)

eval("tk_interp", "");

if (nargin == 0)
	tk_cmd( "destroy .msg_message" );
	return
endif

if (nargin == 1)
	time = 0;
endif

if (time <= 0)
     tk_dialog("Message", text, "info", 0, "Ok");
else
     tk_cmd(sprintf(
	"catch {toplevel .msg_message}; catch {message .msg_message.msg};\
	.msg_message.msg configure -text {%s};\
	pack .msg_message.msg;\
	wm title .msg_message Message;\
	foreach  i [after info] {after cancel $i};\
	after %d {catch {destroy .msg_message} }",
	            text, time*1000));
endif

endfunction
