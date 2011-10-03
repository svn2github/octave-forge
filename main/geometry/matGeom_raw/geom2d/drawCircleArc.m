%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function varargout = drawCircleArc(varargin)
%DRAWCIRCLEARC Draw a circle arc on the current axis
%
%   drawCircleArc(XC, YC, R, START, EXTENT);
%   Draws circle with center (XC, YC), with radius R, starting from angle
%   START, and with angular extent given by EXTENT. START and EXTENT angles
%   are given in degrees.
%
%   drawCircleArc(ARC);
%   Puts all parameters into one single array.
%
%   drawCircleArc(..., PARAM, VALUE);
%   specifies plot properties by using one or several parameter name-value
%   pairs.
%
%   H = drawCircleArc(...);
%   Returns a handle to the created line object.
%
%   Example
%     % Draw a red thick circle arc
%     arc = [10 20 30 -120 240];
%     figure;
%     axis([-50 100 -50 100]);
%     hold on
%     drawCircleArc(arc, 'LineWidth', 3, 'Color', 'r')
%
%   See also:
%   circles2d, drawCircle, drawEllipse
%
%   --------
%   author: David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 12/12/2003.
%

%   HISTORY
%   2004-05-03 angles are given as radians
%   2007-06-27 Now uses angle extent
%   2011-03-30 use angles in degrees
%   2011-06-09 add support for line styles

if nargin == 0
    error('Need to specify circle arc');
end

circle = varargin{1};
if size(circle, 2) == 5
    x0  = circle(:,1);
    y0  = circle(:,2);
    r   = circle(:,3);
    start   = circle(:,4);
    extent  = circle(:,5);
    varargin(1) = [];
    
elseif length(varargin) >= 5
    x0  = varargin{1};
    y0  = varargin{2};
    r   = varargin{3};
    start   = varargin{4};
    extent  = varargin{5};
    varargin(1:5) = [];
    
else
    error('drawCircleArc: please specify center, radius and angles of circle arc');
end

% convert angles in radians
t0  = deg2rad(start);
t1  = t0 + deg2rad(extent);

% number of line segments
N = 60;

% initialize handles vector
h   = zeros(length(x0), 1);

% draw each circle arc individually
for i = 1:length(x0)
    % compute basis
    t = linspace(t0(i), t1(i), N+1)';

    % compute vertices coordinates
    xt = x0(i) + r(i)*cos(t);
    yt = y0(i) + r(i)*sin(t);
    
    % draw the circle arc
    h(i) = plot(xt, yt, varargin{:});
end

if nargout > 0
    varargout = {h};
end
