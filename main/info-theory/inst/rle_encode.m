## (C) 2006, August, Muthiah Annamalai, <muthiah.annamalai@uta.edu>
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

## usage: rle_encode(message)
## This function decodes a run-length encodes a message into its
## rle form. The original message has to be in the form of a 
## row-vector. The message format (encoded RLE) is like  repetition 
## factor, value.
##
## example: 
##          message=[    5   4   4   1   1   1]
##          rle_encode(message) #gives
##          ans = [1 5 2 4 3 1];
##
##
## see also: rle_decode()
##
function rmsg=rle_encode(message)
     if nargin < 1
       error('Usage: rle_encode(message)')
     end
     rmsg=[];
     L=length(message);
     itr=1;
     while itr <= L
       times=0;
       val=message(itr);
       while(itr <= L && message(itr)==val)
	 itr=itr+1;
	 times=times+1;
       end
       rmsg=[rmsg times val];
     end
     return
end
