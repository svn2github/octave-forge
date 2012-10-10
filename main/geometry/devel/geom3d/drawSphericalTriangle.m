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

function varargout = drawSphericalTriangle(sphere, p1, p2, p3, varargin)
#DRAWSPHERICALTRIANGLE Draw a triangle on a sphere
#
#   drawSphericalTriangle(SPHERE, PT1, PT2, PT3);
#
#   See also
#   drawSphere, fillSphericalTriangle, drawSphericalPolygon
#
#   ---------
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 22/02/2005
#

#   HISTORY
#   27/06/2007 manage spheres other than origin
#   30/10/2008 replace intersectPlaneLine by intersectLinePlane

# extract data of the sphere
ori = sphere(:, 1:3);

# extract direction vectors for each point
v1  = normalizeVector(p1 - ori);
v2  = normalizeVector(p2 - ori);
v3  = normalizeVector(p3 - ori);

h1 = drawSphericalEdge(sphere, [v1 v2], varargin{:});
h2 = drawSphericalEdge(sphere, [v2 v3], varargin{:});
h3 = drawSphericalEdge(sphere, [v3 v1], varargin{:});

if nargout > 0
    varargout = {h1, h2, h3};
end
