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
##

## usage: conditionalentropy_XY(XY) computes the 
## H(Y/X) = SUM( P(Xi)*H(Y/Xi) ), where H(Y/Xi) = SUM( -P(Yk/Xi)log(P(Yk/Xi)) )
## 
## XY matrix must have, Y along rows
## X along columns
## Xi = SUM( COLi ) 
## Yi = SUM( ROWi )
## H(Y|X) = H(X,Y) - H(X)
##
## See also: conditionalentropy_XY
function val=conditionalentropy_YX(XY)
  val=0.0;
  for i=1:size(XY)(1)
    Xi = sum(XY(:,i));
    val = val + Xi*entropy(XY(:,i)/sum(XY(:,i)));
  end
  return
end
