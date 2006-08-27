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

## st = tk_busy_cancel (text)
##
## tk_busy_cancel(text) sets up an hourglass box with the text message
## inside and a cancel button. While in your processing loop you should 
## periodically test whether the cancel button has been pressed by calling
## without arguments.  After your loop, you should call tk_busy_cancel
## without arguments and without a return value.  You may update the
## message within the loop by calling tk_busy_cancel with a new text
## string.
##
## Example
##    tk_busy_cancel("Counting...");
##    for i=1:100000
##       if (tk_busy_cancel) break; end
##       if (mod(i,100)==0)
##          tk_busy_cancel(sprintf("Counting... %d",i));
##       end
##    end
##    tk_busy_cancel;
##    printf("Counted to %d\n", i);

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * use pthread version of tk_octave
## * handle query mode without a new text string
## * update documentation and provide an example

function st = tk_busy_cancel (text)

eval("tk_interp","");
st = 0;

if (nargin == 0 && nargout == 0)
	tk_cmd( "\
foreach i [after info] {after cancel $i}\n\
destroy .top_tk_busy\n\
proc busy_rep {} {}\n");
	return
endif

if (tk_cmd( "winfo exists .top_tk_busy" ) == "1")
     if (nargin == 1)
	tk_cmd( sprintf("set tk_busy_message \"%s\"", text ));
	tk_cmd( sprintf( "wm title .top_tk_busy {%s}", text ));
     endif
     st = tk_cmd("set stop" ) == "1";
     return
endif

tk_cmd( "toplevel .top_tk_busy -borderwidth 2 -relief groove" );
tk_cmd( sprintf( "wm title .top_tk_busy {%s}", text) );
#tk_cmd( "wm withdraw .top_tk_busy" );
tk_cmd( "label .top_tk_busy.l1 -textvar tk_busy_message -relief ridge -padx 10 -pady 5" );
tk_cmd( sprintf("set tk_busy_message \"%s\"", text) ); 
tk_cmd( "button .top_tk_busy.b1 -bitmap hourglass" );
tk_cmd( "button .top_tk_busy.b2 -text Stop -command {set stop 1}" );
tk_cmd( "set stop 0" );

#tk_cmd( "wm overrideredirect .top_tk_busy 1" );

tk_cmd( "pack .top_tk_busy.l1 .top_tk_busy.b1 .top_tk_busy.b2 -ipadx 2 -ipady 2 " );

#tk_cmd( "wm deiconify .top_tk_busy" );

tk_cmd( "proc busy_rep {a b} { .top_tk_busy.b1 configure \
-foreground $a -background $b; after 1000 busy_rep $b $a}" );
tk_cmd( "busy_rep salmon green4" );

endfunction
