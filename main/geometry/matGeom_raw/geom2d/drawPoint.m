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


function varargout = drawPoint(varargin)
%DRAWPOINT Draw the point on the axis.
%
%   drawPoint(X, Y);
%   Draws points defined by coordinates X and Y.
%   X and Y should be array the same size.
%
%   drawPoint(COORD);
%   Packs coordinates in a single [N*2] array.
%
%   drawPoint(..., OPT);
%   Draws each point with given option. OPT is a series of arguments pairs
%   compatible with 'plot' model.
%
%
%   H = drawPoint(...) also return a handle to each of the drawn points.
%
%   Example
%   drawPoint(10, 10);
%
%   t = linspace(0, 2*pi, 20)';
%   drawPoint([5*cos(t)+10 3*sin(t)+10], 'r+');
%
%   See also
%   points2d, clipPoints
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   23/02/2004 add more documentation. Manage different kind of inputs. 
%     Does not draw points outside visible area.
%   26/02/2007 update processing of input arguments.
%   30/04/2009 remove clipping of points (use clipPoints if necessary)

% process input arguments
var = varargin{1};
if size(var, 2)==1
    % points stored in separate arrays
    px = varargin{1};
    py = varargin{2};
    varargin(1:2) = [];
else
    % points packed in one array
    px = var(:, 1);
    py = var(:, 2);
    varargin(1) = [];
end

% ensure we have column vectors
px = px(:);
py = py(:);

% default drawing options, but keep specified options if it has the form of
% a bundled string
if length(varargin)~=1
    varargin = [{'linestyle', 'none', 'marker', 'o', 'color', 'b'}, varargin];
end

% plot the points, using specified drawing options
h = plot(px(:), py(:), varargin{:});

% process output arguments
if nargout>0
    varargout{1}=h;
end
