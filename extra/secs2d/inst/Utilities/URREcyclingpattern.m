## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## SECS2D is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
##
## AUTHOR: Carlo de Falco <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
##
## @deftypefn {Function File}@
## {@var{RREpattern}} = URREcyclingpattern(@var{RREnnit},@var{RRErank},@var{maxit})
##
## Precompute cycling pattern for RRE extrapolation:
## @itemize @bullet
## @item -1         = do nothing
## @item 0          = extrapolate
## @item 1..RRErank = store
## @end itemize
##
## @end deftypefn

function RREpattern = URREcyclingpattern(RREnnit,RRErank,maxit);

  RREpattern = zeros(RREnnit(1),1)-1;

  while length(RREpattern)<maxit
    RREpattern = [...
		  RREpattern
		  [1:RRErank]'
		  0
		  (zeros(RREnnit(2),1)-1)...
		  ];
  endwhile

endfunction