## Copyright (c) 2011, INRA
## 2007-2011, David Legland <david.legland@grignon.inra.fr>
## 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## All rights reserved.
## (simplified BSD License)
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
## 1. Redistributions of source code must retain the above copyright notice, this
##    list of conditions and the following disclaimer.
##     
## 2. Redistributions in binary form must reproduce the above copyright notice, 
##    this list of conditions and the following disclaimer in the documentation
##    and/or other materials provided with the distribution.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.
##
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of copyright holder.

function varargout = drawRect2(varargin)
#DRAWRECT2 Draw centered rectangle on the current axis
#   
#   r = drawRect2(x, y, w, h) draw rectangle with width W and height H,
#   whose center is located at (x, y);
#
#   The four corners of rectangle are then :
#   (X-W/2, Y-H/2), (X+W/2, Y-H/2), (X+W/2, Y+H/2), (X-W/2, Y+H/2).
#
#   r = drawRect2(x, y, w, h, theta) also specifies orientation for
#   rectangle. Theta is given in radians.
#
#   r = drawRect2(coord) is the same as DRAWRECT2(X,Y,W,H), but all
#   parameters are packed into one array, whose dimensions is 4*1 or 5*1.
#
#   deprecated: use 'drawOrientedBox' instead
#
#   See Also :
#   drawRect
#
#   ---------
#
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 04/05/2004.
#

warning('polygons2d:deprecated', ...
    'This function is deprecated, use "drawOrientedBox" instead');

# default values
theta = 0;

# get entered values
if length(varargin)>3
    x = varargin{1};
    y = varargin{2};
    w = varargin{3};
    h = varargin{4};
    if length(varargin)>4
        theta = varargin{5};
    end
else
    coord = varargin{1};
    x = coord(:, 1);
    y = coord(:, 2);
    w = coord(:, 3);
    h = coord(:, 4);
    
    if length(coord)>4
        theta = coord(:, 5);
    else
        theta = zeros(size(x));
    end
end

# use only the half length of each rectanhle
w = w/2;
h = h/2;

hr = zeros(length(x), 1);
for i=1:length(x)
    tx = zeros(5, 1);
    ty = zeros(5, 1);
    
    tx(1) = x(i) - w(i)*cos(theta(i)) + h(i)*sin(theta(i));
    ty(1) = y(i) - w(i)*sin(theta(i)) - h(i)*cos(theta(i));
    
    tx(2) = x(i) + w(i)*cos(theta(i)) + h(i)*sin(theta(i));
    ty(2) = y(i) + w(i)*sin(theta(i)) - h(i)*cos(theta(i));
    
    tx(3) = x(i) + w(i)*cos(theta(i)) - h(i)*sin(theta(i));
    ty(3) = y(i) + w(i)*sin(theta(i)) + h(i)*cos(theta(i));
    
    tx(4) = x(i) - w(i)*cos(theta(i)) - h(i)*sin(theta(i));
    ty(4) = y(i) - w(i)*sin(theta(i)) + h(i)*cos(theta(i));
    
    tx(5) = x(i) - w(i)*cos(theta(i)) + h(i)*sin(theta(i));
    ty(5) = y(i) - w(i)*sin(theta(i)) - h(i)*cos(theta(i));
    
    hr(i) = line(tx, ty);
end

if nargout > 0
    varargout{1} = hr;
end
