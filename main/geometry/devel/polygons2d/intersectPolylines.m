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

function pts = intersectPolylines(poly1, varargin)
#INTERSECTPOLYLINES Find the common points between 2 polylines
#
#   INTERS = intersectPolylines(POLY1, POLY2)
#   Returns the intersection points between two polylines. Each polyline is
#   defined by a N-by-2 array representing coordinates of its vertices: 
#   [X1 Y1 ; X2 Y2 ; ... ; XN YN]
#   INTERS is a NP-by-2 array containing coordinates of intersection
#   points.
#
#   INTERS = intersectPolylines(POLY1)
#   Compute self-intersections of the polyline.
#
#   Example
#   # Compute intersection points between 2 simple polylines
#     poly1 = [20 10 ; 20 50 ; 60 50 ; 60 10];
#     poly2 = [10 40 ; 30 40 ; 30 60 ; 50 60 ; 50 40 ; 70 40];
#     pts = intersectPolylines(poly1, poly2);
#     figure; hold on; 
#     drawPolyline(poly1, 'b');
#     drawPolyline(poly2, 'm');
#     drawPoint(pts);
#     axis([0 80 0 80]);
#
#   See also
#   polygons2d, polylineSelfIntersections, intersectLinePolygon
#
#   This function uses the 'interX' function, found on the FileExchange,
#   and stored in 'private' directory of this function.
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2009-06-15,    using Matlab 7.7.0.471 (R2008b)
# Copyright 2009 INRA - Cepia Software Platform.

if isempty(varargin)
    # Compute self-intersections
    pts = InterX(poly1')';
    
else
    # compute intersection between two lines
    pts = InterX(poly1', varargin{1}')';
end
