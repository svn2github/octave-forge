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

## out = tk_input (prompt, opt)
##
## Prompt user for input.
## If the second argument is present, return the user entry as a string,
## else return the result of evaluating the user entry.

## 2001-09-14 Paul Kienzle <pkienzle@users.sf.net>
## * adapt for pthreads-based tk_octave

function out = tk_input (prompt, opt)

if (nargin < 1 | nargin > 2)
    help tk_input
    return
endif

out = tk_entry(prompt,""," ");
if (nargin == 1)
	out = eval([out, ";"]);
endif

endfunction
