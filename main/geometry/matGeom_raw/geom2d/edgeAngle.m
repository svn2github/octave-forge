%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function theta = edgeAngle(edge)
%EDGEANGLE Return angle of edge
%
%   A = edgeAngle(EDGE)
%   Returns the angle between horizontal, right-axis and the edge EDGE.
%   Angle is given in radians, between 0 and 2*pi, in counter-clockwise
%   direction. 
%   Notation for edge is [x1 y1 x2 y2] (coordinates of starting and ending
%   points).
%
%   Example
%   p1 = [10 20];
%   p2 = [30 40];
%   rad2deg(edgeAngle([p1 p2]))
%   ans = 
%       45
%
%   See also
%   edges2d, angles2d, edgeAngle, lineAngle, edgeLength
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2003.
%

line = createLine(edge(:,1:2), edge(:,3:4));
theta = lineAngle(line);
