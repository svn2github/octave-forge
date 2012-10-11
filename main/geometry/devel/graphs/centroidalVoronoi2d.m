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

function varargout = centroidalVoronoi2d(germs, box, varargin)
#CENTROIDALVORONOI2D Create a 2D Centroidal Voronoi Tesselation
#
#   [N E F] = centroidalVoronoi2d(GERMS, BOX)
#   GERMS are N-by-2 point array, BOX is given as [xmin xmax ymin ymax].
#   Algorithm is an iteration of voronoi diagram computations, using at
#   each steps the centroids of previous diagram as germs for the new
#   diagram.
#
#   [N E F] = centroidalVoronoi2d(GERMS, BOX, NITER)
#   Specifies the number of iterations.
#
#   [N E F G] = centroidalVoronoi2d(...)
#   also returns the positions of germs/centroids for each face. If the
#   number of iteration was sufficient, location of germs should correspond
#   to centroids of faces 'fc' computed using: 
#   fc(i,:) = polygonCentroid(n(f{i}, :));
#
#   Example
#   [n e f] = centroidalVoronoi2d(rand(20, 2)*100, [0 100 0 100]);
#   drawGraph(n, e, f);
#
#   See also
#
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2007-01-12
# Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

#   HISTORY
#   27/07/2007 add doc, and psb to specify number of iterations
#   18/09/2007 add psb to return germs of tessellation


# number of iteration
nIter = 10;
if ~isempty(varargin)
    nIter = varargin{1};
end

# limits and size of the box
x0 = box(1); x1 = box(2);
y0 = box(3); y1 = box(4);
dx = x1-x0;  dy = y1-y0;

# far points to bound the voronoi diagram
farPoints = [...
    x1+10*dx y1+10*dy;...
    x0-10*dx y1+10*dy;...
    x0-10*dx y0-10*dy;...
    x1+10*dx y0-10*dy];

# iterate bounded voronoi tesselation
for i = 1:nIter
    # generate Voronoi diagram, and clip woth the box
    [n e f] = voronoi2d([germs ; farPoints]);
    [n e f] = clipGraph(n, e, f, box);
    
    # compute new germs as centroids of of each face
    for j = 1:length(f)
        face = n(f{j}, :);
        germs(j, 1:2) = polygonCentroid(face);
    end
end

# result is given in n, e, and f, eventually germs
varargout{1} = n;
varargout{2} = e;
varargout{3} = f;
if nargout>3
    varargout{4} = germs;
end
