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

function [cVertices cFaces] = clipMeshVertices(vertices, faces, box)
#CLIPMESHVERTICES Clip vertices of a surfacic mesh and remove outer faces
#
#   output = clipMeshVertices(input)
#
#   Example
#   clipMeshVertices
#
#   See also
#
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2011-04-07,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2011 INRA - Cepia Software Platform.

if isstruct(vertices)
    box = faces;
    faces = vertices.faces;
    vertices = vertices.vertices;
end

[cVertices indVertices] = clipPoints3d(vertices, box);


# for face indices relabeling
refInds = zeros(size(indVertices));
for i = 1:length(indVertices)
    refInds(indVertices(i)) = i;
end


if isnumeric(faces)
    # Faces given as numeric array
    indFaces = sum(~ismember(faces, indVertices), 2) == 0;
    cFaces = refInds(faces(indFaces, :));
    
elseif iscell(faces)
    # Faces given as cell array
    nFaces = length(faces);
    indFaces = false(nFaces, 1);
    for i = 1:nFaces
        indFaces(i) = sum(~ismember(faces{i}, indVertices), 2) == 0;
    end
    cFaces = faces(indFaces, :);
    
    # re-label indices of face vertices
    for i = 1:length(cFaces)
        cFaces{i} = refInds(cFaces{i});
    end
    
end
