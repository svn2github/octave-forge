## (C)  Mon May 22 15:46:24 2006, Muthiah Annamalai, <muthiah.annamalai@uta.edu>
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

## usage: binaryn(val,digits) extracts the first MSB $digits of the 
##        number val in a string format.
##
##

function rval=binaryn(Val,digits)
%
% This function returns the first $digits 
% binary digits/bits of the value $Val
% as a string.
%
% FIXME: Is there a faster way to do this?
rval=sprintf("%d",ones(1,digits))
digits=digits+1;
while  digits > 1
  digits=digits-1;
  Val=Val*2;
  if(Val >= 1)
    b="1";
    Val=Val-1;     
    rval(digits)="1";
  else
    rval(digits)="0";
  end
end

return
end

%!
%!assert(binaryn(255,8),"11111111",0);
%!assert(binaryn(128,1),"1",0);
%!