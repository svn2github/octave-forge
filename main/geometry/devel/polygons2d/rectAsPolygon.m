## Copyright (C) 2003-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## 
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of the copyright holders.

function varargout = rectAsPolygon(rect)
#RECTASPOLYGON Convert a (centered) rectangle into a series of points
#
#   P = rectAsPolygon(RECT);
#   Converts rectangle given as [x0 y0 w h] or [x0 y0 w h theta] into a
#   4*2 array double, containing coordinate of rectangle vertices.
#
#   See also:
#   polygons2d, drawRect, drawRect2, drawPolygon
#
#
#   ---------
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 06/04/2005.
#

#   HISTORY

theta = 0;
x = rect(1);
y = rect(2);
w = rect(3)/2;  # easier to compute with w and h divided by 2
h = rect(4)/2;
if length(rect)>4
    theta = rect(5);
end

cot = cos(theta);
sit = sin(theta);

tx(1) = x - w*cot + h*sit;
ty(1) = y - w*sit - h*cot;
tx(2) = x + w*cot + h*sit;
ty(2) = y + w*sit - h*cot;
tx(3) = x + w*cot - h*sit;
ty(3) = y + w*sit + h*cot;
tx(4) = x - w*cot - h*sit;
ty(4) = y - w*sit + h*cot;


if nargout==1
    varargout{1}=[tx' ty'];
elseif nargout==2
    varargout{1}=tx';
    varargout{2}=ty';    
end
