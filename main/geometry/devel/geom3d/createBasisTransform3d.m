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

function transfo = createBasisTransform3d(source, target)
#CREATEBASISTRANSFORM3D Compute matrix for transforming a basis into another basis
#
#   TRANSFO = createBasisTransform3d(SOURCE, TARGET) will create a 4-by-4
#   transformation matrix representing the transformation from SOURCE basis
#   to TARGET basis. 
#    SOURCE and TARGET are either standard 1-by-9 geom3d PLANE
#    representations of the form: [x0 y0 z0  ex1 ey1 ez1  ex2 ey2 ez2]
#     OR
#    SOURCE and TARGET may be any string such as 'global' or 'g' in which
#    case they represent the global plane [0 0 0 1 0 0 0 1 0].
#
#   The resulting TRANSFO matrix is such that a point expressed with
#   coordinates of the first basis will be represented by new coordinates
#   P2 = transformPoint3d(P1, TRANSFO) in the target basis.
#
#   Example:
#     # Calculate local plane coords. of a point given in global coords
#     Plane = [5 50 500 1 0 0 0 1 0];
#     Tform = createBasisTransform3d('global', Plane);
#     PT_WRT_PLANE = transformPoint3d([3 8 2], Tform);
#
#   See also
#   transforms3d, transformPoint3d, createPlane
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2010-12-03,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2010 INRA - Cepia Software Platform.

# init basis transform to identity
t1 = eye(4);
t2 = eye(4);

# Place source and target planes into t1 and t2 t-form matrices. If either
# input is non-numeric it is assumed to mean 'global', or identity t-form.
if isnumeric(source)
    t1(1:3, 1) = source(4:6);
    t1(1:3, 2) = source(7:9);
    t1(1:3, 3) = cross(source(4:6), source(7:9));
    t1(1:3, 4) = source(1:3);
end
if isnumeric(target)
    t2(1:3, 1) = target(4:6);
    t2(1:3, 2) = target(7:9);
    t2(1:3, 3) = cross(target(4:6), target(7:9));
    t2(1:3, 4) = target(1:3);
end

# compute transfo
# same as: transfo = inv(t2)*t1;
transfo = t2 \ t1;
