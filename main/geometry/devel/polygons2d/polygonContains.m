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

function varargout = polygonContains(poly, point)
#POLYGONCONTAINS Test if a point is contained in a multiply connected polygon
#
#   B = polygonContains(POLYGON, POINT);
#   Returns TRUE if the (possibly multi-connected) polygon POLYGON contains
#   the point(s) given by POINT.
#   This is an extension of the Matlab function inpolygon for the case of
#   polygons with holes.
#
#   Example
#   POLY = [0 0; 10 0;10 10;0 10;NaN NaN;3 3;3 7;7 7;7 3];
#   PT = [5 1;5 4];
#   polygonContains(POLY, PT);
#   ans =
#        1
#        0
#
#   See also
#   polygons2d, 
#   inpolygon
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2007-10-11,    using Matlab 7.4.0.287 (R2007a)
# Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.


# transform as a cell array of simple polygons
polygons = splitPolygons(poly);
N = length(polygons);
Np = size(point, 1);

# compute orientation of polygon, and format to have Np*N matrix
ccw = polygonArea(polygons)>0;
ccw = repmat(ccw', Np, 1);

# test if point inside each polygon
in = false(size(point, 1), N);
for i=1:N
    poly = polygons{i};
    in(:, i) = inpolygon(point(:,1), point(:,2), poly(:,1), poly(:,2));
end

# count polygons containing point, weighted by polygon orientation
res = sum(in.*(ccw==1) - in.*(ccw==0), 2);

varargout{1} = res;