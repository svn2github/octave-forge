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

## value = tk_dialog(title, text, bitmap, default, ...)
##
## open a dialog window named 'title' with 'text' printed and N buttons
## named as the optional arguments, with button numbered 'default' being
## the default action. The return value is the number of the clicked button.
## First button is number 0.
##
## eg: ret = tk_dialog("Warning", "You are about to erase the whole disk. Are 
##       you sure?", "questhead", 0, "No","Yes", "Have I asked you something?")
## will return 0 if the first button (No) is clicked, etc.
##
## there are 6 meaningfull bitmap names: error, hourglass, info, questhead,
##	question and warning. All arguments must be strings, except 'default'.

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * spelling corrections
## * modified to work with pthreads version of tk_interp 


function value = tk_dialog(title, text, bitmap, default, varargin)

eval("tk_interp","");

if (nargin < 5 )
  help tk_dialog
  return
endif

if (! (ischar(title) & ischar(text) & ischar(bitmap) & is_scalar(default)))
	error("'title', 'text' and 'bitmap' must be strings, and 'default' must be scalar.\n");
	return
endif

if (!(strcmp(bitmap, "error") || strcmp(bitmap, "hourglass") || ...
	strcmp(bitmap, "info") || strcmp(bitmap, "questhead") || ...
	strcmp(bitmap, "question") || strcmp(bitmap, "warning")))
	error("'bitmap' must be one of 'error', 'hourglass', 'info', \
'questhead', 'question', 'warning'");
	return	
endif

if (default > nargin-5)
	error("'default' must be less then or equal to the number of buttons -1\n");
	return
endif

cmd = sprintf("tk_dialog .top_tk_dialog \"%s\" \"%s\" \"%s\" %d", title, text, bitmap, default);

## use the following for 2.1.38 and below
#varargin = list(varargin, all_va_args);

for argnum=1:length(varargin)
	arg = varargin{argnum};
	if (! ischar(arg))
		error("The arguments must be strings.\n");
		return
	endif
	cmd = [cmd, " ", '"', arg, '"'];
endfor

value = str2num(tk_cmd( cmd ));

endfunction
