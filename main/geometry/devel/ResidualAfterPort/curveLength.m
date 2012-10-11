## Copyright (C) 2003-2011 David Legland <david.legland@grignon.inra.fr>
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
## 
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of the copyright holders.

function len = curveLength(varargin)
#CURVELENGTH return length of a curve (a list of points)
#
#   Compute the length of a curve given as a list of following points. 
#
#   L = curveLength(X, Y);
#   L = curveLength(POINTS);
#   POINTS should be a [NxD] array, with N being the numbe of points and D
#   the dimension of the points.
#
#   PT = curveLength(..., TYPE);
#   Specifies if the last point is connected to the first one. TYPE can be
#   either 'closed' or 'open'.
#
#   TODO : specify norm (euclidian, taxi, ...).
#
#   Example:
#   Compute the perimeter of a circle with radius 1
#   curveLength(circleAsPolygon([0 0 1], 500), 'closed')
#   -> return 6.2831
#
#   See also:
#   polygons2d, curveCentroid
#
#   ---------
#
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 14/06/2004
#

#   HISTORY
#   22/05/2006 manage any dimension for points, closed and open curves, 
#       and update doc accordingly.
#   30/06/2009 deprecate and replace by 'polylineLength'.

# deprecation warning
warning('geom2d:deprecated', ...
    '''curveLength'' is deprecated, use ''polylineLength'' instead');

# check whether the curve is closed
closed = false;
var = varargin{end};
if ischar(var)
    if strcmpi(var, 'closed')
        closed = true;
    end
    varargin = varargin(1:end-1);
end

# extract point coordinates
if length(varargin)==1
    points = varargin{1};
elseif length(varargin)==2
    points = [varargin{1} varargin{2}];
end

# compute lengths of each line segment
if closed
    len = sum(sqrt(sum(diff(points([1:end 1],:)).^2, 2)));
else
    len = sum(sqrt(sum(diff(points).^2, 2)));
end
