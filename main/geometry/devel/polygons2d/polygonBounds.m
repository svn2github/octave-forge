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

function box = polygonBounds(polygon)
#POLYGONBOUNDS Compute the bounding box of a polygon
#
#   BOX = polygonBounds(POLYGON);
#   Returns the bounding box of the polygon. 
#   BOX has the format: [XMIN XMAX YMIN YMAX].
#
#
#   See also
#   polygons2d, boxes2d, polygonBounds
#
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2007-10-12,    using Matlab 7.4.0.287 (R2007a)
# Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.


# transform as a cell array of simple polygons
polygons = splitPolygons(polygon);

# init extreme values
xmin = inf;
xmax = -inf;
ymin = inf;
ymax = -inf;

for i=1:length(polygons)
    polygon = polygons{i};
    
    xmin = min(xmin, min(polygon(:,1)));
    xmax = max(xmax, max(polygon(:,1)));
    ymin = min(ymin, min(polygon(:,2)));
    ymax = max(ymax, max(polygon(:,2)));
end

box = [xmin xmax ymin ymax];
