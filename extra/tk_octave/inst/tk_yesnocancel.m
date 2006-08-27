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

# ret = tk_yesnocancel(text [, default])
#
# Open a window with 'text' printed and asking for YES, NO or CANCEL the
# default being 'default'. The return value is 0 for YES, 1 for NO and
# 2 for CANCEL (the default if 'default' is not specified)
#
# see also: tk_dialog

function ret = tk_yesnocancel(text, default)

if (nargin == 1)
	default = 2;
endif

ret = tk_dialog("",text, "question", default, "Yes", "No", "Cancel");

endfunction

