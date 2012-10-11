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

function normals = faceNormal(nodes, faces)
#FACENORMAL Compute normal vector of faces in a 3D mesh
#
#   NORMALS = faceNormal(VERTICES, FACES)
#   VERTICES is a set of 3D points  (as a Nx3 array), and FACES is either a
#   [Nx3] indices array or a cell array of indices. The function computes
#   the normal of each face.
#   The orientation of the normal is undefined.
#
#
#   Example
#   [n e f] = createCube;
#   normals1 = faceNormal(n, f);
#
#   pts = rand(50, 3);
#   hull = minConvexHull(pts);
#   normals2 = faceNormal(pts, hull);
#
#   See also
#   meshes3d, drawMesh, convhull, convhulln
#
#
# ------
# Author: David Legland
# e-mail: david.legland@jouy.inra.fr
# Created: 2006-07-05
# Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

if isnumeric(faces)
    # compute vector of first edge
	v1 = nodes(faces(:,2),1:3) - nodes(faces(:,1),1:3);
    v2 = nodes(faces(:,3),1:3) - nodes(faces(:,1),1:3);
    
    # normalize vectors
    v1 = normalizeVector3d(v1);
    v2 = normalizeVector3d(v2);
   
    # compute normals using cross product
	normals = cross(v1, v2, 2);

else
    normals = zeros(length(faces), 3);
    
    for i=1:length(faces)
        face = faces{i};
        # compute vector of first edges
        v1 = nodes(face(2),1:3) - nodes(face(1),1:3);
        v2 = nodes(face(3),1:3) - nodes(face(1),1:3);
        
        # normalize vectors
        v1 = normalizeVector3d(v1);
        v2 = normalizeVector3d(v2);
        
        # compute normals using cross product
        normals(i, :) = cross(v1, v2, 2);
    end
end

