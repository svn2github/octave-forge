## (C) 2005, December, Muthiah Annamalai, <muthiah.annamalai@uta.edu>
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

## usage: jointentropy(XY) computes the 
## joint entropy of the given channel transition matrix.
## By definition we have H(X,Y) given as
## H(X:Y) = SUMx( SUMy( P(x,y) log2 ( p(x,y) ) ) ) 
##
## see also: entropy, conditionalentropy
##
function val=jointentropy(XY)
     if nargin < 1 || ~ismatrix(XY)
       error('Usage: jointentropy(XY) where XY is the transition matrix');
     end

     val=0.0;
     S=size(XY);
     if (S(1)==1)
       val=entropy(XY)
     else
       row=S(2);
       col=S(1);
       for i=1:row
	 val=val+entropy(XY(i,:));
       end
     end
     return
end
