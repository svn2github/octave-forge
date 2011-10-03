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


function d = linePosition(point, line)
%LINEPOSITION Position of a point on a line
%
%   POS = linePosition(POINT, LINE);
%   Computes position of point POINT on the line LINE, relative to origin
%   point and direction vector of the line.
%   LINE has the form [x0 y0 dx dy],
%   POINT has the form [x y], and is assumed to belong to line.
%
%   POS = linePosition(POINT, LINES);
%   If LINES is an array of NL lines, return NL positions, corresponding to
%   each line.
%
%   POS = linePosition(POINTS, LINE);
%   If POINTS is an array of NP points, return NP positions, corresponding
%   to each point.
%
%   POS = linePosition(POINTS, LINES);
%   If POINTS is an array of NP points and LINES is an array of NL lines,
%   return an array of [NP NL] position, corresponding to each couple
%   point-line.
%
%   Example
%   line = createLine([10 30], [30 90]);
%   linePosition([20 60], line)
%   ans =
%       .5
%
%   See also:
%   lines2d, createLine, projPointOnLine, isPointOnLine
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 25/05/2004.
%

%   HISTORY
%   2005-07-07 manage multiple input
%   2011-06-15 avoid the use of repmat when possible

% number of inputs
Nl = size(line, 1);
Np = size(point, 1);

if Np == Nl
    % if both inputs have the same size, no problem
    dxl = line(:, 3);
    dyl = line(:, 4);
    dxp = point(:, 1) - line(:, 1);
    dyp = point(:, 2) - line(:, 2);

elseif Np == 1
    % one point, several lines
    dxl = line(:, 3);
    dyl = line(:, 4);
    dxp = point(ones(Nl, 1), 1) - line(:, 1);
    dyp = point(ones(Nl, 1), 2) - line(:, 2);
    
elseif Nl == 1
    % one line, several points
    dxl = line(ones(Np, 1), 3);
    dyl = line(ones(Np, 1), 4);
    dxp = point(:, 1) - line(1);
    dyp = point(:, 2) - line(2);
    
else
    % expand one of the array to have the same size
    dxl = repmat(line(:,3)', Np, 1);
    dyl = repmat(line(:,4)', Np, 1);
    dxp = repmat(point(:,1), 1, Nl) - repmat(line(:,1)', Np, 1);
    dyp = repmat(point(:,2), 1, Nl) - repmat(line(:,2)', Np, 1);
end

% compute position
d = (dxp.*dxl + dyp.*dyl) ./ (dxl.^2 + dyl.^2);

