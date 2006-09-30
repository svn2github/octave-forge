## (C) Aug, 2006 Muthiah Annamalai, <muthiah.annamalai@uta.edu>
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

## usage: avgbits = laverage(codebook,problist);
##
## Compute the average word length SUM(i=1:N)Li.Pi
## where codebook is a struct of strings, where each
## string represents the codeword. Problist is the 
## probability values.
## 
## example: x={"0","111","1110"}; p=[0.1 0.5 0.4];
## laverage(x,p) #must give
## ans =  3.2000
function Lavg=laverage(codebook,problist)
     if nargin < 2
        error('usage laverage(codebook,problist)');
     end
     Lavg=0.0;
     for itr=1:length(codebook)
       Lavg=Lavg+length(codebook{itr})*problist(itr);
     end
     return
end

%!
%! x={"0","111","1110"}; 
%! p=[0.1 0.5 0.4];
%! assert(laverage(x,p),3.200,0.001);
%!