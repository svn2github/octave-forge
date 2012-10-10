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

function varargout = distancePointEdge3d(point, edge)
#DISTANCEPOINTEDGE3D Minimum distance between a 3D point and a 3D edge
#
#   DIST = distancePointEdge3d(POINT, EDGE);
#   Return the euclidean distance between edge EDGE and point POINT. 
#   EDGE has the form: [x1 y1 z1 x2 y2 z2], and POINT is [x y z].
#
#   If EDGE is N-by-6 array, result is N-by-1 array computed for each edge.
#   If POINT is a N-by-3 array, the result is computed for each point.
#   If both POINT and EDGE are array, they must have the same number of
#   rows, and the result is computed for each couple point(i,:);edge(i,:).
#
#   [DIST POS] = distancePointEdge3d(POINT, EDGE);
#   Also returns the position of closest point on the edge. POS is
#   comprised between 0 (first point) and 1 (last point).
#
#   See also:
#   edges3d, points3d, distancePoints3d, distancePointLine3d
#   
#
#   ---------
#   author : David Legland 
#   INRA - CEPIA URPOI - MIA MathCell
#   created the 07/04/2004.
#

#   HISTORY
#   2005-06-24 rename, and change arguments sequence
#   2009-04-30 add possibility to return position of closest point
#   2011-04-14 add checkup for degenerate edges, improve speed, update doc

# direction vector of each edge
vl = edge(:, 4:6) - edge(:, 1:3);

# compute position of points projected on the supporting line
# (Size of t is the max number of edges or points)
t = linePosition3d(point, [edge(:,1:3) vl]);

# ensure degenerated edges are correclty processed (consider the first
# vertex is the closest)
delta = vectorNorm(vl);
t(delta < eps) = 0;

# change position to ensure projected point is located on the edge
t(t < 0) = 0;
t(t > 1) = 1;

# coordinates of projected point
p0 = bsxfun(@plus, edge(:,1:3), [t .* vl(:,1) t .* vl(:,2) t .* vl(:,3)]);

# compute distance between point and its projection on the edge
dist = sqrt((point(:,1) - p0(:,1)) .^ 2 + (point(:,2) - p0(:,2)) .^ 2 + (point(:,3) - p0(:,3)) .^ 2);

# process output arguments
varargout{1} = dist;
if nargout > 1
    varargout{2} = t;
end
