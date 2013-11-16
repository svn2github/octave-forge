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

function varargout = fillPolygon3d(varargin)
#FILLPOLYGON3D Fill a 3D polygon specified by a list of points
#
#   fillPolygon3d(COORD, COLOR)
#   packs coordinates in a single [N*3] array.
#   COORD can also be a cell array of polygon, in this case each polygon is
#   drawn using the same color.
#
#   fillPolygon3d(PX, PY, PZ, COLOR)
#   specify coordinates in separate arrays.
#
#   fillPolygon3d(..., PARAM, VALUE)
#   allow to specify some drawing parameter/value pairs as for the plot
#   function.
#
#   H = fillPolygon3d(...) also return a handle to the list of line objects.
#
#   See Also:
#   polygons3d, drawPolygon, drawPolyline3d
#
#
# ------
# Author: David Legland
# e-mail: david.legland@nantes.inra.fr
# Created: 2007-01-05
# Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

    
# check case we want to draw several curves, stored in a cell array
var = varargin{1};
if iscell(var)
    hold on;
    h = [];
    for i=1:length(var(:))
        h = [h; fillPolygon3d(var{i}, varargin{2:end})];
    end
    if nargout>0
        varargout{1}=h;
    end
    return;
end

# extract curve coordinate
if size(var, 2)==1
    # first argument contains x coord, second argument contains y coord
    # and third one the z coord
    px = var;
    if length(varargin)<3
        error('Wrong number of arguments in fillPolygon3d');
    end
    py = varargin{2};
    pz = varargin{3};
    varargin = varargin(4:end);
else
    # first argument contains both coordinate
    px = var(:, 1);
    py = var(:, 2);
    pz = var(:, 3);
    varargin = varargin(2:end);
end

# extract color information
if isempty(varargin)
    color = 'c';
else
    color = varargin{1};
    varargin = varargin(2:end);
end

# ensure polygon is closed
px = [px; px(1)];
py = [py; py(1)];
pz = [pz; pz(1)];

# fill the polygon
h = fill3(px, py, pz, color, varargin{:});

if nargout>0
    varargout{1}=h;
end
