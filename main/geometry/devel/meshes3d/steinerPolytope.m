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

function [nodes faces] = steinerPolytope(points)
#STEINERPOLYTOPE  Create a steiner polytope from a set of vectors
#
#   [NODES FACES] = steinerPolygon(POINTS)
#   create the steiner polytope defined by points POINTS.
#
#   Example
#   [n f] = steinerPolytope([1 0 0;0 1 0;0 0 1;1 1 1]);
#   drawMesh(n, f);
#
#   See also
#   meshes3d, drawMesh
#
# ------
# Author: David Legland
# e-mail: david.legland@jouy.inra.fr
# Created: 2006-04-28
# Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

# create candidate points
nodes = zeros(1, size(points, 2));
for i=1:length(points)
    nodes = [nodes; nodes+repmat(points(i,:), [size(nodes, 1) 1])];
end

# compute convex hull
K = convhulln(nodes);

# keep only relevant points, and update faces indices
ind = unique(K);
for i=1:length(ind)
    K(K==ind(i))=i;
end 

# return results
nodes = nodes(ind, :);
faces = K;
    
