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


function [dist, varargout] = minDistance(p, curve)
#MINDISTANCE compute minimum distance between a point and a set of points
#
#   Deprecated: use minDistancePoints instead
#
#   usage:
#   d = MINDISTANCE(P, POINTS)
#   POINTS is a [N*2] array of points, and P a single point. function
#   return the minimum distance between P and one of the points.
#
#   Also works for several points in P. In this case, return minimum
#   distance between each element of P and all element of POINTS. d is the
#   same length than P.
#
#   [d, i] = MINDISTANCE(P, POINTS)
#   also return index of closest point in POINTS.
#
#
#   ---------
#
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 23/02/2004.
#

#   HISTORY :
#   18/03/2004 : can also return index of closest point
#   08/04/2004 : return vertical array when input multiple points

dist = inf;

for i=1:size(p, 1)
    dx = curve(:,1)-p(i,1);
    dy = curve(:,2)-p(i,2);
    [dist(i,1), ind(i,1)] = min(sqrt(dx.*dx + dy.*dy));
end

if nargout>1
    varargout{1} = ind;
end
