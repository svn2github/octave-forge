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


function b = onLine(point, line)
#ONLINE test if a point belongs to a line
#
#   B = onLine(POINT, LINE)
#   with POINT being [xp yp], and LINE being [x0 y0 dx dy].
#   Returns 1 if point lies on the line, 0 otherwise.
#
#   If POINT is an N*2 array of points, B is a N*1 array of booleans.
#
#   If LINE is a N*4 arrat of line, B is a 1*N array of booleans.
#
#   See also: 
#   lines2d, points2d, onEdge, onRay, angle3Points
#
#   ---------
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 31/10/2003.
#

#   HISTORY
#   11/03/2004 : support for multiple inputs
#   08/12/2004 : complete implementation, add doc
#   22/05/2009 deprecate

# deprecation warning
warning('geom2d:deprecated', ...
    '''onLine'' is deprecated, use ''isPointOnLine'' instead');

Nl = size(line, 1);
Np = size(point, 1);

x0 = repmat(line(:,1)', Np, 1);
y0 = repmat(line(:,2)', Np, 1);
dx = repmat(line(:,3)', Np, 1);
dy = repmat(line(:,4)', Np, 1);
xp = repmat(point(:,1), 1, Nl);
yp = repmat(point(:,2), 1, Nl);


    
# test if lines are colinear
b = abs((xp-x0).*dy-(yp-y0).*dx)./sqrt(dx.*dx+dy.*dy) < 1e-14;















