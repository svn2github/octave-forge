## Copyright (C) 1999-2000 Paul Kienzle
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

## usage: r = mod(x,y)
##
## Compute modulo function, handling negative number correctly; i.e., 
## mod(-1,3) is 2, not -1 as rem(-1,3) returns. 
## 
## Note that mod(x,0) returns x.

## Author: Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
## Modified by: Teemu Ikonen <tpikonen@pcu.helsinki.fi>

function r=mod(x,y)

  if nargin != 2,
    usage("r=mod(x,y)");
  endif

  nz = y != 0.0;
  if all(all(nz))
    r = x - floor(x./y).*y;
  elseif is_scalar(y)
    r = x;
  elseif is_scalar(x)
    dfi = do_fortran_indexing;
    unwind_protect
      do_fortran_indexing = 1;
      r = x*ones(size(y));
      y = y(nz);
      r(nz) = x - floor(x./y).*y;
    unwind_protect_cleanup
      do_fortran_indexing = 0;
    end_unwind_protect
  else
    dfi = do_fortran_indexing;
    unwind_protect
      do_fortran_indexing = 1;
      r = x;
      x = x(nz);
      y = y(nz);
      r(nz) = x - floor(x./y).*y;
    unwind_protect_cleanup
      do_fortran_indexing = 0;
    end_unwind_protect
  endif

endfunction;
  
%!assert (mod(5, 3), 2);
%!assert (mod(-5, 3), 1);
%!assert (mod(0, 3), 0);
%!assert (isempty(mod([], [])));
%!assert (mod([-5, 5, 0], [3, 3, 3]), [1, 2, 0]);
%!assert (mod([-5; 5; 0], [3; 3; 3]), [1; 2; 0]);
%!assert (mod([-5, 5; 0, 3], [3, 3 ; 3, 1]), [1, 2 ; 0, 0]);
%!assert (mod(5, 0), 5);
%!assert (mod(-5, 0), -5);
%!assert (mod([-5, 5, 0], [3, 0, 3]), [1, 5, 0]);
%!assert (mod([-5; 5; 0], [3; 0; 3]), [1; 5; 0]);
%!assert (mod([-5, 5; 0, 3], [3, 0 ; 3, 1]), [1, 5 ; 0, 0]);

