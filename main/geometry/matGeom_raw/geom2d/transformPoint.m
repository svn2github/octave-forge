%% Copyright (c) 2011, INRA
%% 2007-2011, David Legland <david.legland@grignon.inra.fr>
%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%% All rights reserved.
%% (simplified BSD License)
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%%
%% 1. Redistributions of source code must retain the above copyright notice, this
%%    list of conditions and the following disclaimer.
%%     
%% 2. Redistributions in binary form must reproduce the above copyright notice, 
%%    this list of conditions and the following disclaimer in the documentation
%%    and/or other materials provided with the distribution.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
%% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%% POSSIBILITY OF SUCH DAMAGE.
%%
%% The views and conclusions contained in the software and documentation are
%% those of the authors and should not be interpreted as representing official
%% policies, either expressed or implied, of copyright holder.


function varargout = transformPoint(varargin)
%TRANSFORMPOINT Transform a point with an affine transform
%
%   PT2 = transformPoint(PT1, TRANS);
%   where PT1 has the form [xp yp], and TRANS is a [2*2], [2*3] or [3*3]
%   matrix, returns the point transformed with affine transform TRANS.
%
%   Format of TRANS can be one of :
%   [a b]   ,   [a b c] , or [a b c]
%   [d e]       [d e f]      [d e f]
%                            [0 0 1]
%
%   PT2 = transformPoint(PT1, TRANS);
%   Also works when PTA is a [N*2] array of double. In this case, PT2 has
%   the same size as PT1.
%
%   [PX2 PY2] = transformPoint(PX1, PY1, TRANS);
%   Also works when PX1 and PY1 are arrays the same size. The function
%   transform each couple of (PX1, PY1), and return the result in 
%   (PX2, PY2), which is the same size as (PX1 PY1).
%
%
%   See also:
%   points2d, transforms2d, translation, rotation
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2004.
%

%   HISTORY
%   25/04/2005 : support for 2D arrays of points (px, py, trans).


if length(varargin)==2
    var = varargin{1};
    px = var(:,1);
    py = var(:,2);
    trans = varargin{2};
elseif length(varargin)==3
    px = varargin{1};
    py = varargin{2};
    trans = varargin{3};
else
    error('wrong number of arguments in "transformPoint"');
end


% compute position
px2 = px*trans(1,1) + py*trans(1,2);
py2 = px*trans(2,1) + py*trans(2,2);

% add translation vector, if exist
if size(trans, 2)>2
    px2 = px2 + trans(1,3);
    py2 = py2 + trans(2,3);
end


if nargout==0 || nargout==1
    varargout{1} = [px2 py2];
elseif nargout==2
    varargout{1} = px2;
    varargout{2} = py2;
end
