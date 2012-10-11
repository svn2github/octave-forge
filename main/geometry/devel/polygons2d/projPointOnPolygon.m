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

function varargout = projPointOnPolygon(point, poly, varargin)
#PROJPOINTONPOLYGON  Compute position of a point projected on a polygon
#
#   POS = projPointOnPolygon(POINT, POLYGON)
#   Compute the position of the orthogonal projection of a point on a
#   polygon.
#   POINT is a 1x2 row vector containing point coordinates
#   POLYGON is a Nx2 array containing coordinates of polygon vertices
#
#   When POINT is an array of points, returns a column vector with as many
#   rows as the number of points. 
#
#   [POS DIST] = projPointOnPolygon(...)
#   Also returns the distance between POINT and POLYGON. The distance is
#   negative if the point is located inside of the polygon.
#
#   Example
#   projPointOnPolygon
#
#   See also
#   points2d, polygons2d, polygonPoint
#   distancePointpolygon, projPointOnPolyline
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2009-04-30,    using Matlab 7.7.0.471 (R2008b)
# Copyright 2009 INRA - Cepia Software Platform.


# eventually copy first point at the end to ensure closed polygon
if sum(poly(end, :)==poly(1,:))~=2
    poly = [poly; poly(1,:)];
end

# compute position wrt outline
[pos minDist] = projPointOnPolyline(point, poly);

# process output arguments
if nargout<=1
    varargout{1} = pos;
elseif nargout==2
    varargout{1} = pos;
    if inpolygon(point(:,1), point(:,2), poly(:,1), poly(:,2))
        minDist = -minDist;
    end
    varargout{2} = minDist;
end
