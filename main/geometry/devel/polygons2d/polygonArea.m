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

function area = polygonArea(varargin)
#POLYGONAREA Compute the signed area of a polygon
#
#   A = polygonArea(POINTS);
#   Compute area of a polygon defined by POINTS. POINTS is a N-by-2 array
#   of double containing coordinates of vertices.
#   
#   Vertices of the polygon are supposed to be oriented Counter-Clockwise
#   (CCW). In this case, the signed area is positive.
#   If vertices are oriented Clockwise (CW), the signed area is negative.
#
#   If polygon is self-crossing, the result is undefined.
#
#   
#   References
#   algo adapted from P. Bourke web page
#   http://local.wasp.uwa.edu.au/~pbourke/geometry/polyarea/
#
#   See also :
#   polygons2d, polygonCentroid, drawPolygon
#
#   ---------
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 05/05/2004.
#

#   HISTORY
#   25/04/2005: add support for multiple polygons
#   12/10/2007: update doc

# in case of polygon sets, computes several areas
if nargin > 0
    var = varargin{1};
    if iscell(var)
        area = zeros(length(var), 1);
        for i = 1:length(var)
            area(i) = polygonArea(var{i}, varargin{2:end});
        end
        return;
    end
end

# extract coordinates
if nargin == 1
    var = varargin{1};
    px = var(:, 1);
    py = var(:, 2);
elseif nargin == 2
    px = varargin{1};
    py = varargin{2};
end

# indices of next vertices
N = length(px);
iNext = [2:N 1];

# compute area (vectorized version)
area = sum(px .* py(iNext) - px(iNext) .* py) / 2;
