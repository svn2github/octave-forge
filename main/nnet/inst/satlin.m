## Copyright (C) 2007 Michel D. Schmid <michael.schmid@plexso.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}[@var{a} = satlin (@var{n})
## A neural feed-forward network will be trained with @code{trainlm}
##
## @end deftypefn

## @seealso{purelin,tansig,logsig}

## Author: Michel D. Schmid


function a = satlin(n)

  if (n<0)
    a = 0;
  elseif (n>=0 && n<=1)
    a = n;
  else
    a = 1; # if n>1
  endif

endfunction
