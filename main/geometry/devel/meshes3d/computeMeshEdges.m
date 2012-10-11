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

function edges = computeMeshEdges(faces)
#COMPUTEMESHEDGES Computes edges array from face array
#
#   EDGES = computeMeshEdges(FACES);
#
#   Example
#   computeMeshEdges
#
#   See also
#   meshes3d
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2011-06-28,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2011 INRA - Cepia Software Platform.

if ~iscell(faces)
    # faces is given as numeric array, 
    # all faces have same number of vertices
    
    # compute total number of edges
    nFaces  = size(faces, 1);
    nVF     = size(faces, 2);
    nEdges  = nFaces * nVF;
    
    # create all edges (with double ones)
    edges = zeros(nEdges, 2);
    for i = 1:nFaces
        f = faces(i, :);
        edges(((i-1)*nVF+1):i*nVF, :) = [f' f([2:end 1])'];
    end
    
else
    # faces are given as a cell array, with possibly different number of
    # vertices
    nFaces  = length(faces);
    
    # compute number of edges
    nEdges = 0;
    for i = nFaces
        nEdges = nEdges + length(faces{i});
    end
    
    # allocate memory
    edges = zeros(nEdges, 2);
    ind = 0;
    
    # fillup edge array
    for i = 1:nFaces
        f = faces{i};
        nVF = length(f);
        edges(ind+1:ind+nVF, :) = [f' f([2:end 1])'];
        ind = ind + nVF;
    end
    
end

# keep only unique edges
edges = unique(sort(edges, 2), 'rows');
