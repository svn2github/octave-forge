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

function line = intersectPlanes(plane1, plane2)
#INTERSECTPLANES Return intersection line between 2 planes in space
#
#   LINE = intersectPlanes(PLANE1, PLANE2)
#   Returns the straight line belonging to both planes
#   PLANE: [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
#   LINE:  [x0 y0 z0 dx dy dz]
#
#   See also:
#   planes3d, lines3d, intersectLinePlane
#
#   ---------
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 17/02/2005.
#

#   HISTORY


# plane normal
n1 = normalizeVector(cross(plane1(:,4:6), plane1(:, 7:9), 2));
n2 = normalizeVector(cross(plane2(:,4:6), plane2(:, 7:9), 2));

# test if planes are parallel
if abs(cross(n1, n2, 2))<1e-14
    line = [NaN NaN NaN NaN NaN NaN];
    return;
end

# Uses Hessian form, ie : N.p = d
# I this case, d can be found as : -N.p0, when N is normalized
d1 = dot(n1, plane1(:,1:3), 2);
d2 = dot(n2, plane2(:,1:3), 2);

# compute dot products
dot1 = dot(n1, n1, 2);
dot2 = dot(n2, n2, 2);
dot12 = dot(n1, n2, 2);

# intermediate computations
det = dot1*dot2 - dot12*dot12;
c1  = (d1*dot2 - d2*dot12)./det;
c2  = (d2*dot1 - d1*dot12)./det;

# compute line origin and direction
p0  = c1*n1 + c2*n2;
dp  = cross(n1, n2, 2);

# concatenate result to form a new line
line = [p0 dp];
