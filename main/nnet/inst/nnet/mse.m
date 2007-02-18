## Copyright (C) 2005 Michel D. Schmid   <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {}@var{perf} = mse (@var{E})
## @code{mse} returns the Mean-Square-Error of a vector E
##
## @example
##
## This function is used to calculate the network performance
## @end example
##
## @end deftypefn

## @seealso{}

## Author: mds
## $LastChangedDate: 2006-08-20 21:47:51 +0200 (Sun, 20 Aug 2006) $
## $Rev: 38 $

function perf = mse(E)

  ## check number of inputs
  error(nargchk(1,1,nargin));

  if iscell(E)
    perf = 0;
    elements = 0;
    for i=1:size(E,1)
      for j=1:size(E,2)
        perf = perf + sum(sum(E{i,j}.^2));
        elements = elements + prod(size(E{i,j}));
      endfor
    endfor
    perf = perf / elements;
  else
    error("Error vector should be a cell array!")
  endif


endfunction