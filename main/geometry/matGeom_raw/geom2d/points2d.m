%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function points2d
%POINTS2D  Description of functions operating on points
%
%   A point is defined by its two cartesian coordinate, put into a row
%   vector of 2 elements:
%   P = [x y];
%
%   Several points are stores in a matrix with two columns, one for the
%   x-coordinate, one for the y-coordinate.
%   PTS = [x1 y1 ; x2 y2 ; x3 y3];
%   
%   Example
%   P = [5 6];
%
%   See also:
%   centroid, midPoint, polarPoint, pointOnLine
%   isCounterClockwise, angle2Points, angle3Points, angleSort
%   distancePoints, minDistancePoints
%   transformPoint, clipPoints, drawPoint
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

help('points2d');
