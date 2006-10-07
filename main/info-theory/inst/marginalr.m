## Copyright (C) 2005, December, Muthiah Annamalai, <muthiah.annamalai@uta.edu>
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
##

## -*- texinfo -*-
## @deftypefn {Function File} {} marginalr (@var{xy})
##
## Computes marginal  probabilities along rows. Where @var{xy} is the
## transition matrix
## @end deftypefn
## @seealso{marginalc}

function val=marginalr(XY)
   val=sum(XY');
   return
end
