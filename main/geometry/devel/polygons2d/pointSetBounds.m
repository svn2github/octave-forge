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

function box = pointSetBounds(points)
#POINTSETBOUNDS Bounding box of a set of points
#
#   BOX = pointSetBounds(POINTS)
#   Returns the bounding box of the set of points POINTS. POINTS can be
#   either a N-by-2 or N-by-3 array. The result BOX is a 1-by-4 or 1-by-6
#   array, containing:
#   [XMIN XMAX YMIN YMAX] (2D point sets)
#   [XMIN XMAX YMIN YMAX ZMIN ZMAX] (3D point sets)
#
#   Example
#     # Draw the bounding box of a set of random points
#     points = rand(30, 2);
#     drawPoint(points, '.');
#     hold on;
#     box = pointSetBounds(points);
#     drawBox(box, 'r');
#
#   See also
#   polygonBounds, drawBox
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2011-04-01,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2011 INRA - Cepia Software Platform.

#   HISTORY
#   2011-04-08 add example

# compute extreme x and y values
xmin = min(points(:,1));
xmax = max(points(:,1));
ymin = min(points(:,2));
ymax = max(points(:,2));
box = [xmin xmax ymin ymax];

# process case of 3D points
if size(points, 2) > 2
    zmin = min(points(:,3));
    zmax = max(points(:,3));
    box = [xmin xmax ymin ymax zmin zmax];
end
