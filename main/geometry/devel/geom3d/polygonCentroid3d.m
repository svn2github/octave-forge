## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
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

function centroid = polygonCentroid3d(varargin)
#POLYGONCENTROID3D Centroid (or center of mass) of a polygon
#
#   PTC = polygonCentroid3d(POLY)
#   Computes center of mass of a polygon defined by POLY. POLY is a N-by-3
#   array of double containing coordinates of polygon vertices.
#
#   PTC = polygonCentroid3d(VX, VY, VZ)
#   Specifies vertex coordinates as three separate arrays.
#
#   Example
#     # compute centroid of a basic polygon
#     poly = [0 0 0; 10 0 10;10 10 20;0 10 10];
#     centro = polygonCentroid3d(poly)
#     centro =
#         5.0000    5.0000    10.0000
#
#   See also
#   polygons3d, polygonArea3d, polygonCentroid
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2007-09-18
# Copyright 2007 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).


if nargin==1
    # polygon is given as a single argument
    pts = varargin{1};
    
elseif nargin==2
    # polygon is given as 3 corodinate arrays
    px = varargin{1};
    py = varargin{2};
    pz = varargin{3};
    pts = [px py pz];
end

# create supporting plane (assuming first 3 points are not colinear...)
plane = createPlane(pts(1:3, :));

# project points onto the plane
pts = planePosition(pts, plane);

# compute centroid in 2D
centro2d = polygonCentroid(pts);

# project back in 3D
centroid = planePoint(plane, centro2d);