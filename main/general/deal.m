## Copyright (C) 1998 Ariel Tankus
## 
## This program is free software.
## This file is part of the Image Processing Toolbox for Octave
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
##

## [...] = deal(...)
##
##   Copy the input parameters into the corresponding output parameters.  
##   E.g., [a,b,c]=deal(x,y,z) is equivalent to a=x; b=y; c=z;
##  
## [...] = deal(v)
##
##   Split the input vector into the corresponding output parameters.
##   E.g., [a,b,c]=deal([1,2,3]) is equivalent to a=1; b=2; c=3;
##
##   NOTE: this is not compatible behaviour.  When converting code to
##   run under octave, use a=b=c=X instead of [a,b,c] = deal(X).

## Author: Ariel Tankus.
## Created: 13.11.98.
## Almost completely replaced by Paul Kienzle and Etienne Grossman.

## pre 2.1.39 function [...] = deal(v)
function [varargout] = deal(varargin) ## pos 2.1.39

  if (nargin == 0)
    usage("[a,b,c,d]=deal(x,y,z,a)");
  elseif (nargin == 1)
    persistent warn = 1;
    if warn 
      warning("[a,b,c]=deal(X) is not the same as a=b=c=X"); 
      warn = 0;
    endif
    v = varargin{1};
    for i=1:nargout
      ## pre 2.1.39     vr_val(v(i));
      varargout{i} = v(i); ## pos 2.1.39
    end
  elseif nargin == nargout;
    ## pre 2.1.39  this needs a loop
    varargout = varargin; ## pos 2.1.39
  else
    error("deal should have one input for each output");
  endif

endfunction
