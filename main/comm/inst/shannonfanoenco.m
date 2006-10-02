## (C) 2006, Oct 1, Muthiah Annamalai, <muthiah.annamalai@uta.edu>
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

##
## usage:shannonfanoenco(sig,dict)
## The function returns the Shannon Fano encoded signal using dict.
## This function uses a dict built from the shannonfanodict
## and uses it to encode a signal list into a shannon fano code.
## Restrictions include a signal set that strictly belongs
## in the range [1,N] with N=length(dict). Also dict can
## only be from the shannonfanodict() routine.
## 
## 
## example: hd=shannonfanodict(1:4,[0.5 0.25 0.15 0.10])
##          shannonfanoenco(1:4,hd) #  [   0   1   0   1   1   0   1   1   1   0]
##
##
function sf_code=shannonfanoenco(sig,dict)
  if nargin < 2
    error('usage: huffmanenco(sig,dict)');
  end
  if (max(sig) > length(dict)) || ( min(sig) < 1)
    error("signal has elements that are outside alphabet set ...
	Cannot encode.");
  end
  sf_code=[dict{sig}];
  return
end
%! 
%! assert(shannonfanoenco(1:4, shannonfanodict(1:4,[0.5 0.25 0.15 0.10])),[   0   1   0   1   1   0   1   1   1   0],0)
%!
