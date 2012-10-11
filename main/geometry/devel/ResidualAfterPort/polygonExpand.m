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

function poly2 = polygonExpand(polygon, dist)
#POLYGONEXPAND 'expand' a polygon with a given distance
#
#   EXPOLY = polygonExpand(POLYGON, D);
#   Associates each edge of POLYGON to an edge located at distance D, and
#   computes polygon given by growing edges. 
#   This is a kind of dilatation, but behaviour on corners is different.
#   This function keeps angles of polygons, but there is no direct relation
#   between length of 2 polygons.
#
#   It works fine for convex polygons, or for polygons whose complexity is
#   not too high (self intersection of result polygon is not tested).
#
#   It is also possible to specify negative distance, and get all points
#   inside the polygon. If the polygon is convex, the result equals
#   morphological erosion of polygon by a ball with radius equal to the
#   given distance.
#
#   See also:
#   polygons2d
#
#   ---------
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 14/05/2005.
#

#   HISTORY :
#   31/07/2005 : change algo for negative distance : use clipping of
#   polygon by half-planes
#   17/06/2009 deprecate

# deprecation warning
warning('geom2d:deprecated', ...
    '''polygonExpand'' is deprecated, use ''expandPolygon'' instead');

# eventually copy first point at the end
if sum(polygon(end, :)==polygon(1,:))~=2
    polygon = [polygon; polygon(1,:)];
end

# number of vertics of polygon
N = size(polygon, 1)-1;

# find lines parallel to polygon edges with distance DIST
line = zeros(N, 4);
for i=1:N
    side = createLine(polygon(i,:), polygon(i+1,:));
    #perp = orthogonalLine(side, polygon(i,:));
    #pts2 = pointOnLine(perp, -dist);
    line(i, 1:4) = parallelLine(side, -dist);
end


if dist>0
    # compute intersection points of consecutive lines
    line = [line;line(1,:)];
    poly2 = zeros(N, 2);
    for i=1:N
        poly2(i,1:2) = intersectLines(line(i,:), line(i+1,:));
    end
else
    poly2 = polygon;
    # clip polygon with all lines parallel to edges
    for i=1:N
        poly2 = clipPolygonHP(poly2, line(i,:));
    end
end
