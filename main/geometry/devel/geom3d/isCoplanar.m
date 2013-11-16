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

function copl = isCoplanar(x,y,z,tolerance)
#ISCOPLANAR Tests input points for coplanarity in 3-space.
#
# COPL = isCoplanar(X,Y,Z,TOLERANCE) takes input arguments x,y, and z as column vectors;
#        TOLERANCE is optional.
# COPL = isCoplanar(x) takes an n x 3 input argument in the form [x1 y1 z1;x2 y2 z2;...;xn yn zn]
# 
# The optional argument TOLERANCE allows for roundoff error; if each combination of four points is
# truly coplanar, the volume of the tetrahedron they define is zero. When computational round-off
# error is introduced, this volume can be close to, but not equal to zero. Setting the tolerance
# to a value greater than zero enables the algorithm to return a "correct" finding of coplanarity
# within the tolerance specified.
# 
# EXAMPLES: iscoplanar([1 2 -2;-3 1 -14;-1 2 -6;1 -2 -8],eps)
#           copl = iscoplanar([1 -3 -1 1]',[2 1 2 -2]',[-2 -14 -6 -8]')

#
# Written by Brett Shoelson, Ph.D.
# brett.shoelson@joslin.harvard.edu
#
# Thanks to Roger Stafford, roger.ellie@mindspring.com for his dilligence
# in uncovering problems with my original code.
#
# Completed 6/10/01.
# Written and tested under MATLAB V6 (R12).
# Modified 2/10/04; now uses determinant discrimination, which is much
# faster (on the order of ten times) than previous way. Also, old version
# had a typo; should have (but didn't) compared ABSOLUTE VALUE of error
#
#   04/01/2007: clean up input processing (DL)

if nargin == 0
	error('Requires at least one input argument.'); 
elseif nargin == 1
	if size(x,2) == 3
		# Matrix of all x,y,z is input
		allpoints = x;
		tolerance = 0;
	else
		error('Invalid input.')
	end
elseif nargin == 2
	if size(x,2) == 3
		# Matrix of all x,y,z is input
		allpoints = x;
		tolerance = y;
	else
		error('Invalid input.')
	end
elseif nargin == 3
	# Compile a matrix of all x,y,z
	allpoints = [x y z];
	tolerance = 0;
else
	allpoints = [x y z];
end

if length(x)<=3
#  disp('Three or fewer points are necessarily coplanar.');
	copl=1;
	return;
end

#Compare all 4-tuples of point combinations; {P1:P4} are coplanar iff
#det([x1 y1 z1 1;x2 y2 z2 1;x3 y3 z3 1;x4 y4 z4 1])==0
tmp = nchoosek(1:size(allpoints,1),4);
for ii = 1:size(tmp,1)
	copl = abs(det([allpoints(tmp(ii, :), :) ones(4,1)])) <= tolerance;
	if ~copl
		break
	end
end
