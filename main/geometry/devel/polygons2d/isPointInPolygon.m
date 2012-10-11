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

function b = isPointInPolygon(point, poly)
#ISPOINTINPOLYGON Test if a point is located inside a polygon
#
#   B = isPointInPolygon(POINT, POLYGON)
#   Returns true if the point is located within the given polygon.
#
#   This function is simply a wrapper for the function inpolygon, to avoid
#   decomposition of point and polygon coordinates.
#
#   Example
#   pt1 = [30 20];
#   pt2 = [30 5];
#   poly = [10 10;50 10;50 50;10 50];
#   isPointInPolygon([pt1;pt2], poly)
#   ans =
#        1
#        0
#
#   See also
#   points2d, polygons2d, inpolygon, isPointInTriangle

#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2009-06-19,    using Matlab 7.7.0.471 (R2008b)
# Copyright 2009 INRA - Cepia Software Platform.

b = inpolygon(point(:,1), point(:,2), poly(:,1), poly(:,2));
