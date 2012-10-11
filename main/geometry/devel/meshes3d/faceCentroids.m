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

function centroids = faceCentroids(nodes, faces)
#FACECENTROIDS Compute centroids of a mesh faces
#
#   NORMALS = faceCentroids(VERTICES, FACES)
#   VERTICES is a set of 3D points  (as a Nx3 array), and FACES is either a
#   [Nx3] indices array or a cell array of indices. The function computes
#   the centroid of each face.
#
#   
#
#   See also:
#   meshes3d, drawMesh, faceNormal, convhull, convhulln
#
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2006-07-05
# Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

#   HISTORY
#   2007/09/18 fix: worked only for 2D case, now works also for 3D


if isnumeric(faces)
    nf = size(faces, 1);
    centroids = zeros(nf, size(nodes, 2));
    if size(nodes, 2)==2
        for f=1:nf
            centroids(f,:) = polygonCentroid(nodes(faces(f,:), :));
        end
    else
        for f=1:nf
            centroids(f,:) = polygonCentroid3d(nodes(faces(f,:), :));
        end
    end        
else
    nf = length(faces);
    centroids = zeros(nf, size(nodes, 2));
    if size(nodes, 2)==2
        for f=1:nf
            centroids(f,:) = polygonCentroid(nodes(faces{f}, :));
        end
    else
        for f=1:nf
            centroids(f,:) = polygonCentroid3d(nodes(faces{f}, :));
        end
    end
end

