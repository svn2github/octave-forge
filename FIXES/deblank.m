## Copyright (C) 1996 Kurt Hornik
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} deblank (@var{s})
## Removes the trailing blanks and nulls from the string @var{s}.
## If @var{s} is a matrix, @var{deblank} trims each row to the 
## length of longest string.
## @end deftypefn

## Author: Kurt Hornik <Kurt.Hornik@ci.tuwien.ac.at>
## Adapted-By: jwe
## Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##    vectorize for speed

function t = deblank (s)

  if (nargin != 1)
    usage ("deblank (s)");
  endif

  if (isstr (s))

    [nr, nc] = size (s);

    if (nc == 0)
      t = s;
    else
      ## Need to compare s against space and null.  Since "\0" is not
      ## defined, need to use setstr.  Since setstr(0) is [], for 2.1.31
      ## at least, need to store setstr([0, 1]) to variable t and use
      ## t(1) as the null character.
      t = setstr([0, 1]);
      k = find (s != " " & s != t (1));
      if isempty (k)
	t = "";
      else
	t = s (:, 1 : ceil (max (k) / nr));
      endif
    endif

  else
    error ("deblank: expecting string argument");
  endif

endfunction

%!assert (deblank(""), "");
%!assert (deblank(" "), "");
%!assert (deblank([" ", " "]), "")
%!assert (isempty(deblank([" ", " "])));
%!assert (deblank(" f o o "), " f o o");
%!assert (deblank(["f "; "o "; "o "]), [ "f"; "o"; "o" ]);
%!test
%! ## Test strings containing \0 as well.  Need to work a bit to
%! ## construct them, though.
%! in = ["fr "; "o0 "; "o 0"]; 
%! in(2,2:3) = setstr([0 32]);
%! in(3,2:3) = setstr([32 0]);
%! out = [ "fr"; "o0"; "o " ];
%! out(2,:) = setstr([toascii("o") 0]);
%! assert(deblank(in), out);
