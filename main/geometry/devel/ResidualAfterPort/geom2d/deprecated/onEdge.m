## Copyright (c) 2011, INRA
## 2007-2011, David Legland <david.legland@grignon.inra.fr>
## 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## All rights reserved.
## (simplified BSD License)
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
## 1. Redistributions of source code must retain the above copyright notice, this
##    list of conditions and the following disclaimer.
##     
## 2. Redistributions in binary form must reproduce the above copyright notice, 
##    this list of conditions and the following disclaimer in the documentation
##    and/or other materials provided with the distribution.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.
##
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of copyright holder.


function b = onEdge(point, edge)
#ONEDGE test if a point belongs to an edge
#
#   B = onEdge(POINT, EDGE)
#   with POINT being [xp yp], and EDGE being [x1 y1 x2 y2].
#
#   See also:
#   edges2d, points2d, onLine
#
#   ---------
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 31/10/2003.
#

# HISTORY
# 11/03/2004 : change input format : edge is [x1 y1 x2 y2].
# 17/01/2005 : if test N edges with N points, return N boolean.
# 21/01/2005 : normalize test for colinearity, so enhance precision
#   22/05/2009 deprecate

# deprecation warning
warning('geom2d:deprecated', ...
    '''onEdge'' is deprecated, use ''isPointOnEdge'' instead');

Np = size(point, 1);
Ne = size(edge, 1);

if Np==1 || Ne==1
    x0 = repmat(edge(:,1)', Np, 1);
    y0 = repmat(edge(:,2)', Np, 1);
    dx = repmat(edge(:,3)', Np, 1)-x0;
    dy = repmat(edge(:,4)', Np, 1)-y0;
    xp = repmat(point(:,1), 1, Ne);
    yp = repmat(point(:,2), 1, Ne);
elseif Np==Ne
    x0 = edge(:,1);
    y0 = edge(:,2);
    dx = edge(:,3)-x0;
    dy = edge(:,4)-y0;
    xp = point(:,1);
    yp = point(:,2);
    
end


# test if lines are colinear
b1 = abs((xp-x0).*dy - (yp-y0).*dx)./(dx.*dx+dy.*dy)<1e-13;

ind  = abs(dx)>abs(dy);
t = zeros(max(Np, Ne), 1);
t(ind) = (xp(ind)-x0(ind))./dx(ind);
t(~ind) = (yp(~ind)-y0(~ind))./dy(~ind);
b = t>-1e-14 & t-1<1e-14 & b1;




