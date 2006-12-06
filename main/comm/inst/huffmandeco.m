## Copyright (C) 2006 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Function File} {@var{sig} = } huffmandeco (@var{hcode}, @var{dict})
##
## Returns the original signal that was Huffman encoded signal using 
## @code{huffmanenco}. This function uses a dict built from the 
## @code{huffmandict} and uses it to decode a signal list into a huffman 
## list. A restriction is that @var{hcode} is expected to be a binary code
## The returned signal set that strictly belongs in the range @code{[1,N]}
## with @code{N = length(@var{dict})}. Also @var{dict} can only be from the
## @code{huffmandict} routine. Whenever decoding fails, those signal values a
## re indicated by @code{-1}, and we successively  try to restart decoding 
## from the next bit that hasn't failed in decoding, ad-infinitum. An exmaple
## of the use of @code{huffmandeco} is
##
## @example
## @group
##   hd = huffmandict(1:4,[0.5 0.25 0.15 0.10])
##   hcode = huffmanenco(1:4,hd) #  [ 1 0 1 0 0 0 0 0 1 ]
##   huffmandeco(hcode,h d) # [1 2 3 4]
## @end group
## @end example
## @end deftypefn
## @seealso{huffmandict, huffmanenco}

function sig=huffmandeco(hcode,dict)
  if ( nargin < 2 || strcmp(class(dict),"cell")~=1 )
    error('usage: huffmanenco(sig,dict)');
  end
  if (max(hcode) > 1 || min(hcode) < 0)
    error("hcode has elements that are outside alphabet set ...
	Cannot decode.");
  end
  
# TODO:
# O(log(N)) algorithms exist, but we need some effort to implement those
# Maybe sometime later, it would be a nice 1-day project
# Ref: A memory efficient Huffman Decoding Algorithm, AINA 2005, IEEE
#

# TODO: Somebody can implement a 'faster' algorithm than O(N^3) at present
# Decoding Algorithm O(N+k*log(N)) which is approximately O(N+Nlog(N))
#
# 1.  Separate the dictionary  by the lengths
#     and knows symbol correspondence.
#
# 2.  Find the symbol in the dict of lengths l,h where
#     l = smallest cw length ignoring 0 length CW, and
#     h = largest cw length , with k=h-l+1;
#     
# 3.  Match the k codewords to the dict using binary
#     search, and then you can declare decision.
#
# 4.  In case of non-decodable words skip the start-bit
#     used in the previous case, and then restart the same
#     procedure from the next bit.
#
  L=length(dict);
  lenL=length(dict{1});
  lenH=0;

#  
# Know the ranges of operation
#  
  for itr=1:L
    t=length(dict{itr});
    if(t < lenL)
      lenL=t;
    end
    if(t > lenH)
      lenH=t;
    end
  end

#
# Now do a O(N^4) algorithm
#
  itr=0; #offset into the hcode
  sig=[]; #output
  CL=length(hcode);

  %whole decoding loop.
  while ( itr <  CL )
    %decode one element (or just try to).
    for itr_y=lenL:lenH
      %look for word in dictionary.
      %with flag to indicate found 
      %or not found. Detect end of buffer.
    
      if ( (itr+itr_y) > CL )
	break;
      end

      word=hcode(itr+1:itr+itr_y);
      flag=0;
      
      %word

      %search loop.
      for itr_z=1:L
	if(isequal(dict{itr_z},word))
	  itr=itr+itr_y; 
	  sig=[sig itr_z];
	  flag=1;
	  break;
	end
      end %for_ loop breaker

      if( flag == 1 )
	break; %also need to break_ above then.
      end

    end %for_ loop


    #could not decode
    if( flag == 0 )
      itr=itr+1;
      sig=[sig -1]; 
    end

  end  %while_ loop
end
%! 
%! assert(huffmandeco(huffmanenco(1:4, huffmandict(1:4,[0.5 0.25 0.15 0.10])), huffmandict(1:4,[0.5 0.25 0.15 0.10])), [1:4],0)
%!
