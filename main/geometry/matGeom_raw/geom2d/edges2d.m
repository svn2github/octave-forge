%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function edges2d(varargin)
%EDGES2D  Description of functions operating on planar edges
%
%   An edge is represented by the corodinate of its end points:
%   EDGE = [X1 Y1 X2 Y2];
%
%   A set of edges is represented by a N*4 array, each row representing an
%   edge.
%
%
%   See also:
%   lines2d, rays2d, points2d
%   createEdge, edgeAngle, edgeLength, edgeToLine, midPoint
%   intersectEdges, intersectLineEdge, isPointOnEdge
%   clipEdge, transformEdge
%   drawEdge, drawCenteredEdge
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

help('edges2d');
