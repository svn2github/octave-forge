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

function res = subCurve(curve, P1, P2, varargin)
#SUBCURVE  extract a portion of a curve
#
#   CURVE2 = subCurve(CURVE, POS1, POS2)
#   extract a subcurve by keeping only points located between indices POS1
#   and POS2. If POS1>POS2, function considers all points after POS1 and
#   all points before POS2.
#
#   CURVE2 = subCurve(CURVE, POS1, POS2, DIRECT)
#   If DIRECT is false, curve points are taken in reverse order, from POS1
#   to POS2 with -1 increment, or from POS1 to 1, then from last point to
#   POS2 index. If direct is true, behaviour corresponds to the first
#   described case.
#
#   Example
#   C = circleAsPolygon([0 0 10], 120);
#   C2 = subCurve(C, 30, 60);
#
#   See also
#   polygons2d
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2007-08-23,    using Matlab 7.4.0.287 (R2007a)
# Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

# deprecation warning
warning('geom2d:deprecated', ...
    '''subCurve'' will be deprecated in a future release, please consider using ''polylineSubcurve''');

# check if curve is inverted
direct = true;
if ~isempty(varargin)
    direct = varargin{1};
end

# process different cases
if direct
    if P1<P2
        res = curve(P1:P2, :);
    else
        res = curve([P1:end 1:P2], :);
    end
else
    if P1<P2
        res = curve([P1:-1:1 end:-1:P2], :);
    else
        res = curve(P1:-1:P2, :);
    end
end

