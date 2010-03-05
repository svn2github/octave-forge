## Copyright (C) 1998, 2000, 2004, 2005, 2006, 2007 Kai P. Mueller
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
## @deftypefn {Function File} {@var{W} =} wgt1o (@var{vl}, @var{vh}, @var{fc})
## State space description of a first order weighting function.
##
## Weighting function are needed by the 
## @iftex
## @tex
## $ { \cal H }_2 / { \cal H }_\infty $
## @end tex
## @end iftex
## @ifinfo
## H-2/H-infinity
## @end ifinfo
## design procedure.
## These functions are part of the augmented plant @var{P}
## (see @command{hinfdemo} for an application example).
##
## @strong{Inputs}
## @table @var
## @item vl
## Gain at low frequencies.
## @item vh
## Gain at high frequencies.
## @item fc
## Corner frequency (in Hz, @strong{not} in rad/sec)
## @end table
##
## @strong{Output}
## @table @var
## @item W
## Weighting function, given in form of a system data structure.
## @end table
## @end deftypefn

## Author: Kai P. Mueller <mueller@ifr.ing.tu-bs.de>
## Created: September 30, 1997

function wsys = wgt1o (vl, vh, fc)

  if (nargin != 3)
    print_usage ();
  endif

  if (vl == vh)
      a = [];
      b = [];
      c = [];
  else
      a = -2*pi*fc;
      b = -2*pi*fc;
      c = vh-vl;
  endif
  d = vh;

  wsys = ss (a, b, c, d);

endfunction
