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


function varargout = drawOrientedBox(box, varargin)
%DRAWORIENTEDBOX Draw centered oriented rectangle
%   
%   Syntax
%   drawOrientedBox(BOX)
%   drawOrientedBox(BOX, 'PropertyName', propertyvalue, ...)
%
%   Description
%   drawOrientedBox(OBOX)
%   Draws an oriented rectangle (or bounding box) on the current axis. 
%   OBOX is a 1-by-5 row vector containing box center, dimension (length
%   and width) and orientation (in degrees): 
%   OBOX = [CX CY LENGTH WIDTH THETA].
%
%   When OBOX is a N-by-5 array, the N boxes are drawn.
%
%   HB = drawOrientedBox(...) 
%   Returns a handle to the created graphic object(s). Object style can be
%   modified using syntaw like:
%   set(HB, 'color', 'g', 'linewidth', 2);
%
%   See also
%   drawPolygon, drawRect, drawBox
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-05-09,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% HISTORY
%   2011-07-22 simplifies code


%% Parses input arguments

if nargin > 4 && sum(cellfun(@isnumeric, varargin(1:4))) == 4
    cx  = box;
    cy  = varargin{1};
    hl   = varargin{2} / 2;
    hw   = varargin{3} / 2;
    theta   = varargin{4};
    varargin = varargin(5:end);
else
    cx  = box(:,1);
    cy  = box(:,2);
    hl   = box(:,3) / 2;
    hw   = box(:,4) / 2;
    theta = box(:,5);
end


%% Draw each box

% allocate memory for graphical handle
hr = zeros(length(cx), 1);

% iterate on oriented boxes
for i = 1:length(cx)
    % pre-compute angle data
    cot = cosd(theta(i));
    sit = sind(theta(i));
    
    % x and y shifts
    lc = hl(i) * cot;
    ls = hl(i) * sit;
    wc = hw(i) * cot;
    ws = hw(i) * sit;

    % coordinates of box vertices
    vx = cx(i) + [-lc + ws; lc + ws ; lc - ws ; -lc - ws ; -lc + ws];
    vy = cy(i) + [-ls - wc; ls - wc ; ls + wc ; -ls + wc ; -ls - wc];

    % draw polygons
    hr(i) = line(vx, vy, varargin{:});
end


%% Format output

if nargout > 0
    varargout = {hr};
end
