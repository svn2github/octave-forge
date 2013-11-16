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

function varargout = clipPoints3d(points, box)
#CLIPPOINTS3D Clip a set of points by a box
#
#   CLIP = clipPoints3d(POINTS, BOX);
#   Returns the set of points which are located inside of the box BOX.
#
#   [CLIP IND] = clipPoints2d(POINTS, BOX);
#   Also returns the indices of clipepd points.
#
#   See also
#   points3d, boxes3d
#
#
# ------
# Author: David Legland
# e-mail: david.legland@nantes.inra.fr
# Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
# Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

# get bounding box limits
xmin = box(1);
xmax = box(2);
ymin = box(3);
ymax = box(4);
zmin = box(5);
zmax = box(6);

# compute indices of points inside visible area
xOk = points(:,1) >= xmin & points(:,1) <= xmax;
yOk = points(:,2) >= ymin & points(:,2) <= ymax;
zOk = points(:,3) >= zmin & points(:,3) <= zmax;

# keep only points inside box
ind = find(xOk & yOk & zOk);
points = points(ind, :);

# process output arguments
varargout{1} = points;
if nargout == 2
    varargout{2} = ind;
end
