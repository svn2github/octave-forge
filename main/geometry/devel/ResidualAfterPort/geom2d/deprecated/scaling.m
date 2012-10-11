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


function trans = scaling(varargin)
#SCALING return 3*3 matrix of a scaling in 2 dimensions
#
#   TRANS = scaling(SX, SY);
#   return the matrix corresponding to scaling by SX and SY in the 2
#   main directions.
#   The returned matrix has the form:
#   [SX  0  0]
#   [0  SY  0]
#   [0   0  1]
#
#   TRANS = scaling(SX);
#   Assume SX and SY are equals.
#
#   See also:
#   transforms2d, transformPoint, createTranslation, createRotation
#
#   ---------
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 07/04/2004.

#   HISTORY
#   04/01/2007: rename as scaling
#   22/04/2009: copy to createScaling and deprecate

# deprecation warning
warning('geom2d:deprecated', ...
    '''scaling'' is deprecated, use ''createScaling'' instead');

# call current implementation
trans = createScaling(varargin{:});
