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

## ASSERT produces an error if the condition is not met.
##
## assert(cond)
##   Produce an error if any element of cond is zero.
##
## assert(v, expected_v)
##   Produce an error if v is not the same as expected_v.  Note
##   that v and expected_v can be strings, matrices or structures.
##
## assert(v, expected_v, tol)
##   Produce an error if abs(v-expected_v)>tol for any v.
##   If tol < 0, use abs(v-expected_v)>abs(tol*expected_v).
##
## see also: test

## TODO: Output throttling: don't print out the entire 100x100 matrix,
## TODO: but instead give a summary; don't print out the whole list, just
## TODO: say what the first different element is, etc.  To do this, make
## TODO: the message generation type specific.
function assert(cond, expected, tol)

  if (nargin < 1 || nargin > 3)
    usage("assert (cond) or assert (v, expected_v [,tol])");
  endif

  if (nargin < 3)
    tol = 0;
  endif

  coda = "";
  iserror = 0;
  if (nargin == 1)
    if (!isnumeric(cond) || !all(cond(:)))
      error ("assert failed"); # say which elements failed?
    endif

  elseif (is_list(cond))
    if (!is_list(expected) || length(cond) != length(expected))
      iserror = 1;
    else
      try
	for i=1:length(cond)
	  assert(nth(cond,i),nth(expected,i));
	endfor
      catch
	iserror = 1;
      end
    endif

  elseif (isstr (expected))
    iserror = (!isstr (cond) || !strcmp (cond, expected));

  elseif (is_struct (expected))
    if (!is_struct (cond) || ...
	rows(struct_elements(cond)) != rows(struct_elements(expected)))
      iserror = 1;
    else
      for [v,k] = cond
	if struct_contains(expected,k)
	  eval(["assert(v,expected.",k,", tol);"], "iserror=1;");
	else
	  iserror = 1;
	  break;
	endif
      endfor
    endif

  elseif (isempty (expected))
    iserror = (any (size (cond) != size (expected)));

  else ## numeric
    if (any (size (cond) != size (expected)))
      iserror = 1;
    elseif (tol >= 0)
      iserror = (any (any (abs (cond-expected) > tol )));
      if (iserror)
	coda = sprintf("|| v - v_expected || = %g", norm(cond-expected));
      endif
    else
      comp = abs(cond-expected) > abs(tol*expected);
      iserror = any (comp(:));
      if (iserror)
	coda = sprintf("|| (v - v_expected)./v || = %g", \
		       norm((cond-expected)./expected));
      endif
    endif
  endif

  if (!iserror)
    return;
  endif

  ## pretty print the "expected but got" info,
  ## trimming leading and trailing "\n"
  str = disp (expected);
  idx = find(str!="\n");
  if (!isempty(idx))
    str = str(idx(1):idx(length(idx)));
  endif
  str2 = disp (cond);
  idx = find(str2!="\n");
  if (!isempty(idx))
    str2 = str2(idx(1):idx(length(idx)));
  endif
  msg = ["assert expected\n", str, "\nbut got\n", str2];
  if (!isempty(coda))
    msg = [ msg, "\n", coda ];
  endif
  error(msg);
endfunction

## empty
%!assert([])
%!assert(zeros(3,0),zeros(3,0))
%!error assert(zeros(3,0),zeros(0,2))
%!error assert(zeros(3,0),[])

## conditions
%!assert(isempty([]))
%!assert(1)
%!error assert(0)
%!assert(ones(3,1))
%!assert(ones(1,3))
%!assert(ones(3,4))
%!error assert([1,0,1])
%!error assert([1;1;0])
%!error assert([1,0;1,1])

## vectors
%!assert([1,2,3],[1,2,3]);
%!assert([1;2;3],[1;2;3]);
%!error assert([2;2;3],[1;2;3]);
%!error assert([1,2,3],[1;2;3]);
%!error assert([1,2],[1,2,3]);
%!error assert([1;2;3],[1;2]);
%!assert([1,2;3,4],[1,2;3,4]);
%!error assert([1,4;3,4],[1,2;3,4])
%!error assert([1,3;2,4;3,5],[1,2;3,4])

## scalars
%!error assert(3, [3,3; 3,3])
%!error assert([3,3; 3,3], 3)
%!assert(3, 3);
%!assert(3+eps, 3, eps);
%!assert(3, 3+eps, eps);
%!error assert(3+2*eps, 3, eps);
%!error assert(3, 3+2*eps, eps);
%## must give a little space for floating point errors on relative
%!assert(100+100*eps, 100, -2*eps); 
%!assert(100, 100+100*eps, -2*eps);
%!error assert(100+300*eps, 100, -2*eps); 
%!error assert(100, 100+300*eps, -2*eps);
%!error assert(3, [3,3]);
%!error assert(3,4);

## structures
%!shared x,y
%! x.a = 1; x.b=[2, 2];
%! y.a = 1; y.b=[2, 2];
%!assert (x,y)
%!test y.b=3;
%!error assert (x,y)
%!error assert (3, x);
%!error assert (x, 3);

## check usage statements
%!error assert
%!error assert(1,2,3,4,5)

## strings
%!assert("dog","dog")
%!error assert("dog","cat")
%!error assert("dog",3);
%!error assert(3,"dog");
