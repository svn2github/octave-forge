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

## example('name', n)
##
##    Display the code for example n associated with the function 'name',
##    but do not run it.  If n is not given, all examples are displayed.
##
## [x, idx] = example(...)
##    Return the examples as a string, with idx indicating the ending
##    position of the various examples.
##
## See demo for a complete explanation.
##
## See also: demo, test

## PKG_ADD: mark_as_command example

function [code_r, idx_r] = example(name, n)

  if (nargin < 1 || nargin > 2)
    usage("example('name')  or example('name', n)");
  endif
  if (nargin < 2)
    n = 0;
  endif

  [code, idx] = test (name, 'grabdemo');
  if (nargout > 0)
    if (n > 0)
      if (n <= length(idx))
      	code_r = code(idx(n) : idx(n+1)-1);
      	idx_r = [1, length(code_r)+1];
      else
	code_r = "";
	idx_r = [];
      endif
    else
      code_r = code;
      idx_r = idx;
    endif
  else
    if (n > 0)
      doidx = n;
    else
      doidx = [ 1:length(idx)-1 ];
    endif
    if (length(idx) == 0)
      warning(["example not available for ", name]);
    elseif (n >= length(idx))
      warning(sprintf("only %d examples available for %s", length(idx)-1, name));
      doidx = [];
    endif

    for i=1:length(doidx)
      block = code( idx(doidx(i)) : idx(doidx(i)+1) -1 );
      printf("%s example %d:%s\n\n", name, doidx(i), block);
    endfor
  endif

endfunction

%!## warning: don't modify the demos without modifying the tests!
%!demo
%! example('example');
%!demo
%! t=0:0.01:2*pi; x=sin(t);
%! plot(t,x)

%!assert (example('example',1), "\n example('example');");
%!test
%! [code, idx] = example('example');
%! assert (code, ... 
%!	   "\n example('example');\n t=0:0.01:2*pi; x=sin(t);\n plot(t,x)")
%! assert (idx, [1, 22, 59]);

%!error example;
%!error example('example',3,5)
