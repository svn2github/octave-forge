## Copyright (C) 1998, 2000, 2004, 2005, 2006, 2007
##               Auburn University. All rights reserved.
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} strappend (@var{strlist}, @var{suffix})
## Append string @var{suffix} to each string in the list @var{strlist}.
## @end deftypefn

function retval = strappend (strlist, suffix);

  if (nargin != 2)
    print_usage ();
  elseif (! is_signal_list (strlist))
    error ("strlist must be a list of strings (see is_signal_list)");
  elseif (! (ischar (suffix) && rows (suffix) == 1))
    error ("suffix must be a single string");
  endif

  retval = {};

  for ii = 1:length (strlist)
    retval{ii} = sprintf ("%s%s", strlist{ii}, suffix);
  endfor

endfunction
