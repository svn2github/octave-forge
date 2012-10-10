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

function ell = inertiaEllipsoid(points)
#INERTIAELLIPSOID Inertia ellipsoid of a set of 3D points
#
#   ELL = inertiaEllipsoid(PTS)
#   Compute the inertia ellipsoid of the set of points PTS. The result is
#   an ellispoid defined by:
#   ELL = [XC YC ZC A B C PHI THETA PSI]
#   where [XC YC ZY] is the centern [A B C] are length of semi-axes (in
#   decreasing order), and [PHI THETA PSI] are euler angles representing
#   the ellipsoid orientation, in degrees.
#
#   Example
#   inertiaEllipsoid
#
#   See also
#   spheres, drawEllipsoid, inertiaEllipse
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2011-03-12,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2011 INRA - Cepia Software Platform.

# number of points
n = size(points, 1);

# compute centroid
center = mean(points);

# compute the covariance matrix
covPts = cov(points)/n;

# perform a principal component analysis with 2 variables, 
# to extract inertia axes
[U S] = svd(covPts);

# extract length of each semi axis
radii = 2 * sqrt(diag(S)*n)';

# sort axes from greater to lower
[radii ind] = sort(radii, 'descend');

# format U to ensure first axis points to positive x direction
U = U(ind, :);
if U(1,1) < 0
    U = -U;
    # keep matrix determinant positive
    U(:,3) = -U(:,3);
end

# convert axes rotation matrix to Euler angles
angles = rotation3dToEulerAngles(U);

# concatenate result to form an ellipsoid object
ell = [center radii angles];
