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

function edgeFaces = meshEdgeFaces(vertices, edges, faces) ##ok<INUSL>
#MESHEDGEFACES Compute index of faces adjacent to each edge of a mesh
#
#   EF = meshEdgeFaces(V, E, F)
#
#   Example
#   meshEdgeFaces
#
#   See also
#   meshes3d
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2010-10-04,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2010 INRA - Cepia Software Platform.

Ne = size(edges, 1);

# indices of faces adjacent to each edge
edgeFaces = zeros(Ne, 2);

# different method for extracting current face depending if faces are
# stored as index 2D array or as cell array of 1D arrays.
if isnumeric(faces)
    Nf = size(faces, 1);
    for i=1:Nf
        face = faces(i, :);
        processFace(face, i)
    end
elseif iscell(faces)
    Nf = length(faces);
    for i=1:Nf
        face = faces{i};
        processFace(face, i)
    end
end

    function processFace(face, indFace)
        for j = 1:length(face)
            # build edge: array of vertices
            currentEdge = [face(j) face(mod(j, length(face))+1)];
            
            # avoid the case of faces with last vertex equal to the first
            # one
            if currentEdge(1)==currentEdge(2)
                continue;
            end
            
            # find index of current edge within edge array
            b1 = ismember(edges, currentEdge, 'rows');
            indEdge = find(b1);
            if isempty(indEdge)
                b2 = ismember(edges, currentEdge([2 1]), 'rows');
                indEdge = find(b2);
            end
            
            # check up
            if isempty(indEdge)
                warning('geom3d:ElementNotFound', ...
                    'Edge #d of face #d was not found in edge array', ...
                    j, indFace);
                continue;
            end
            
            updateEdgeFaces(indEdge, i);
        end
    end

    function updateEdgeFaces(indEdge, indFace)
        # stores index of current face with found edge
        if edgeFaces(indEdge, 1)==0
            edgeFaces(indEdge, 1) = indFace;
        elseif edgeFaces(indEdge, 2)==0
            edgeFaces(indEdge, 2) = indFace;
        else
            error('Edge #d has more than 2 adjacent faces', indEdge);
        end
    end
end
