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

function area = meshSurfaceArea(vertices, edges, faces)
#MESHSURFACEAREA Surface area of a polyhedral mesh
#
#   S = meshSurfaceArea(V, F)
#   S = meshSurfaceArea(V, E, F)
#   Computes the surface area of the mesh specified by vertex array V and
#   face array F. Vertex array is a NV-by-3 array of coordinates. 
#   Face array can be a NF-by-3 or NF-by-4 numeric array, or a Nf-by-1 cell
#   array, containing vertex indices of each face.
#
#   This functions iterates on faces, extract vertices of the current face,
#   and compute the sum of areas of face triangles.
#
#   This function assumes faces are coplanar and convex. If faces area
#   triangular, the function "trimeshSurfaceArea".
#
#
#   Example
#     # compute the surface of a unit cube (should be equal to 6)
#     [v f] = createCube;
#     meshSurfaceArea(v, f)
#     ans = 
#         6
#
#   See also
#   meshes3d, trimeshSurfaceArea
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2010-10-13,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2010 INRA - Cepia Software Platform.


# check input number
if nargin == 2
    faces = edges;
end

# pre-compute normals
normals = normalizeVector3d(faceNormal(vertices, faces));

# init accumulator
area = 0;


if isnumeric(faces)
    # iterate on faces in a numeric array
    for i = 1:size(faces, 1)
        poly = vertices(faces(i, :), :);        
        area = area + polyArea3d(poly, normals(i,:));
    end
    
else
    # iterate on faces in a cell array
    for i = 1:size(faces, 1)
        poly = vertices(faces{i}, :);
        area = area + polyArea3d(poly, normals(i,:));
    end
end


function a = polyArea3d(v, normal)

nv = size(v, 1);
v0 = repmat(v(1,:), nv, 1);
products = sum(cross(v-v0, v([2:end 1], :)-v0, 2), 1);
a = abs(dot(products, normal, 2))/2;
