## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## isequal(x1, x2, ...)
##    true if all parts of x1, x2, ... are equal

##TODO: list comparison
function t = isequal(x,y,...)
  if is_struct(x)
    if (!is_struct (y))
      t = 0;
    else
      xel = struct_elements (x);
      yel = struct_elements (y);
      if (any (any (xel != yel)))
	t = 0;
      else
	for i=1:length (xel)
      	  t = eval (["isequal(x.", xel(i), ", y.", yel(i), ");"]);
	  if t == 0, break; endif
	endfor
      endif
    endif
  elseif any (size (x) != size (y))
    t = 0;
  else
    t = all(all(x==y));
  endif
  if nargin > 2 && t == 1
     t = isequal(x, all_va_args);
  endif
endfunction
