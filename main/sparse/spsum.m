# Copyright (C) 1998,1999 Andy Adler
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#    This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#    You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# $Id$

# spsum (X, DIM)
#    Sum of elements along dimension DIM.  If DIM is omitted, it
#    defaults to 1 (column-wise sum), except for row-vectors,
#    where the row sum is taken.
#
# note - this is different than sum(x,1) (which is identical to sum(x))
#        but I think this is the right way.

## PKG_ADD dispatch ("sum", "spsum", "sparse");
## PKG_ADD dispatch ("sum", "spsum", "complex_sparse");
function y=spsum( x, dim)

if     nargin==1
   dim=1;
   if size(x,1)==1;
      dim=2;
   endif
elseif nargin==2
   #ok -> no change required
else
   error("y = spsum (x [, dim])");
   return;
endif   

if dim==1
   y= ones(1,size(x,1))*x;
elseif dim==2
   y= x*ones(size(x,2),1);
else
   error("spsum(x,dim) only allows dimension 1 or 2");
endif   

