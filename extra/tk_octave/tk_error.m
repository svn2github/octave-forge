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

## ret = tk_error(text)
##
## Open a window with 'text' printed and asking for acknowledgement.
##
## see also: tk_dialog

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * documentation update

function ret = tk_error(text)

ret = tk_dialog("",text,"error", 0,"OK");

endfunction

