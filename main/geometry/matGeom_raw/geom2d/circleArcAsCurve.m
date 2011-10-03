%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function varargout = circleArcAsCurve(arc, N)
%CIRCLEARCASCURVE Convert a circle arc into a series of points
%
%   P = circleArcAsCurve(ARC, N);
%   convert the circle ARC into a series of N points. 
%   ARC is given in the format: [XC YC R THETA1 DTHETA]
%   where XC and YC define the center of the circle, R its radius, THETA1
%   is the start of the arc and DTHETA is the angle extent of the arc. Both
%   angles are given in degrees. 
%   N is the number of vertices of the resulting polyline, default is 65.
%
%   The result is a N-by-2 array containing coordinates of the N points. 
%
%   [X Y] = circleArcAsCurve(ARC, N);
%   Return the result in two separate arrays with N lines and 1 column.
%
%
%   See also:
%   circles2d, circleAsPolygon, drawCircle, drawPolygon
%
%
% ---------
% author : David Legland 
% created the 22/05/2006.
% Copyright 2010 INRA - Cepia Software Platform.
%

% HISTORY
% 2011-03-30 use angles in degrees, add default value for N

% default value for N
if nargin < 2
    N = 65;
end

% vector of positions
t0 = deg2rad(arc(4));
t1 = t0 + deg2rad(arc(5));
t = linspace(t0, t1, N)';

% compute coordinates of vertices
x = arc(1) + arc(3) * cos(t);
y = arc(2) + arc(3) * sin(t);

% format output
if nargout <= 1
    varargout = {[x y]};
else
    varargout = {x, y};
end
