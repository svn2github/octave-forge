## Copyright (C) 2008  David Bateman
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
## @deftypefn {Function File} {} gtext (@var{s})
## @deftypefnx {Function File} {} gtext (@dots{}, @var{prop}, @var{val})
## Places text on the current figure. The text can be defined by the
## string @var{s}. If @var{s} is a cell array, each element of the cell
## array is written to a separate line.
##
## Additional arguments are passed to the underlying text object as
## properties.
## @seealso{ginput}
## @end deftypefn

function gtext (s, varargin)

  if (nargin < 1)
    print_usage ();
  endif

  if (iscell (s))
    s = s(:);
    if (all (cellfun (@ischar, s)))
      tmp(1:2:2*length(s)) = s;
      tmp(2:2:2*length(s)) = "\n";
      s = strcat (tmp{:});
    else
      error ("gtext: expecting a string or cell array of strings");
    endif 
  elseif (!ischar (s))
    error ("gtext: expecting a string or cell array of strings");
  endif

  [x, y] = ginput (1);
  text (x, y, s, varargin{:});
endfunction

