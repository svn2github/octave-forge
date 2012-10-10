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


function line = createMedian(varargin)
%CREATEMEDIAN create a median line
%
%   DEPRECATED: use medianLine instead
%
%   l = CREATEMEDIAN(P1, P2) create the median line of points P1 and P2, 
%   that is the line containing all points located at equal distance of 
%   P1 and P2.
%
%   l = CREATEMEDIAN(points) create the median line of 2 points, given as
%   a 2*2 array. array has the form :
%   [ [ x1 y1 ] ; [ x2 y2 ] ]
%
%   l = CREATEMEDIAN(edge) create the median of the edge. Edge is a 1*4
%   array, containing [x0 y0] coordiantes of first point, and [dx dy],
%   the vector from first point to second point.
% 
%   
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

% deprecation warning
warning('geom2d:deprecated', ...
    '''createMedian'' is deprecated, use ''medianLine'' instead');


nargs = length(varargin);
x0=0;
y0=0;
dx=0;
dy=0;

if nargs == 1
    tab = varargin{1};
    if size(tab, 2)==2
        % array of two points
        x0 = tab(1,1); y0 = tab(1,2);
        dx = tab(2,1)-x0; dy = tab(2,2)-y0;
    else
        % edge equation
        x0 = tab(1); y0 = tab(2);
        dx = tab(3); dy = tab(4);
    end
elseif nargs==2
    % two points
    p1 = varargin{1};
    p2 = varargin{2};
    x0 = p1(1); y0 = p1(2);
    dx = p2(1)-x0; dy = p2(2)-y0;
end
    
        
line = [x0+dx/2, y0+dy/2, -dy, dx];
