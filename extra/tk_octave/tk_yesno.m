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

## ret = tk_yesno(text [, default])
##
## Open a window with 'text' printed and asking for YES or NO, the
## default being 'default'. The return value is 0 for YES and 1 for NO
## (the default if 'default' is not specified)
##
## see also: tk_dialog

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * returns true for yes and false for no

function ret = tk_yesno(text, default)

if (nargin == 1)
	default = 1;
endif

ret = !tk_dialog("",text,"question", default,"Yes","No");

endfunction
