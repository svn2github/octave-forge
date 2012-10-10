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

function mat = createRotation3dLineAngle(line, theta)
#CREATEROTATION3DLINEANGLE Create rotation around a line by an angle theta
#
#   MAT = createRotation3dLineAngle(LINE, ANGLE)
#
#   Example
#     origin = [1 2 3];
#     direction = [4 5 6];
#     line = [origin direction];
#     angle = pi/3;
#     rot = createRotation3dLineAngle(line, angle);
#     [axis angle2] = rotation3dAxisAndAngle(rot);
#     angle2
#     angle2 =
#           1.015
#
#   See also
#   transforms3d, rotation3dAxisAndAngle, rotation3dToEulerAngles,
#   createEulerAnglesRotation
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2010-08-11,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2010 INRA - Cepia Software Platform.

# determine rotation center and direction
center = [0 0 0];
if size(line, 2)==6
    center = line(1:3);
    vector = line(4:6);
else
    vector = line;
end

# normalize vector
v = normalizeVector(vector);

# compute projection matrix P and anti-projection matrix
P = v'*v;
Q = [0 -v(3) v(2) ; v(3) 0 -v(1) ; -v(2) v(1) 0];
I = eye(3);

# compute vectorial part of the transform
mat = eye(4);
mat(1:3, 1:3) = P + (I - P)*cos(theta) + Q*sin(theta);

# add translation coefficient
mat = recenterTransform3d(mat, center);
