## Copyright (C) 1996, 1997 John W. Eaton
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
## @deftypefn {Function File} {} kron (@var{a}, @var{b})
## Form the kronecker product of two matrices, defined block by block as
##
## @example
## x = [a(i, j) b]
## @end example
##
## For example,
##
## @example
## @group
## kron (1:4, ones (3, 1))
##      @result{}  1  2  3  4
##          1  2  3  4
##          1  2  3  4
## @end group
## @end example
## @end deftypefn

## Author: A. S. Hodel <scotte@eng.auburn.edu>
## Created: August 1993
## Adapted-By: jwe
## Rewritten-By: Paul Kienzle <pkienzle@kienzle.powernet.co.uk>

function x = kron (a, b)
  if (nargin != 2)
    usage ("kron (a, b)");
  endif

  [ra, ca] = size (a);
  [rb, cb] = size (b);
  if (isempty (a) || isempty (b))
    x = zeros (ra*rb, ca*cb);
  else
    rak = 1:ra;    
    rak = rak (ones (1, rb), :);
    cak = 1:ca;    
    cak = cak (ones (1, cb), :);
    rbk = [1:rb]'; 
    rbk = rbk (:, ones (1, ra));
    cbk = [1:cb]'; 
    cbk = cbk (:, ones (1, ca));
    x = a (rak, cak) .* b (rbk, cbk);
  endif

endfunction
