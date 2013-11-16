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

function varargout = rotation3dToEulerAngles(mat)
#ROTATION3DTOEULERANGLES Extract Euler angles from a rotation matrix
#
#   [PHI, THETA, PSI] = rotation3dToEulerAngles(MAT)
#   Computes Euler angles PHI, THETA and PSI (in degrees) from a 3D 4-by-4
#   or 3-by-3 rotation matrix.
#
#   ANGLES = rotation3dToEulerAngles(MAT)
#   Concatenates results in a single 1-by-3 row vector. This format is used
#   for representing some 3D shapes like ellipsoids.
#
#   Example
#   rotation3dToEulerAngles
#
#   References
#   Code from Graphics Gems IV on euler angles
#   http://tog.acm.org/resources/GraphicsGems/gemsiv/euler_angle/EulerAngles.c
#   Modified using explanations in:
#   http://www.gregslabaugh.name/publications/euler.pdf
#
#   See also
#   transforms3d, rotation3dAxisAndAngle, createRotation3dLineAngle,
#   eulerAnglesToRotation3d
#
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2010-08-11,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2010 INRA - Cepia Software Platform.


# conversion from radians to degrees
k = 180 / pi;

# extract |cos(theta)|
cy = hypot(mat(1, 1), mat(2, 1));

# avoid dividing by 0
if cy > 16*eps
    # normal case: theta <> 0
#    psi     = k * atan2( mat(3, 2) / cy, mat(3, 3) / cy);
    psi     = k * atan2( mat(3, 2), mat(3, 3));
    theta   = k * atan2(-mat(3, 1), cy);
#    psi     = k * atan2( mat(2, 1) / cy, mat(1, 1) / cy);
    phi     = k * atan2( mat(2, 1), mat(1, 1));
else
    # 
    psi     = k * atan2(-mat(2, 3), mat(2, 2));
    theta   = k * atan2(-mat(3, 1), cy);
    phi     = 0;
end

# format output arguments
if nargout <= 1
    # one array
    varargout{1} = [phi theta psi];
else
    # three separate arrays
    varargout = {phi, theta, psi};
end
