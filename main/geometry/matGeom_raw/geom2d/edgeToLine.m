%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function line = edgeToLine(edge)
%EDGETOLINE Convert an edge to a straight line
%
%   LINE = edgeToLine(EDGE);
%   Returns the line containing the edge EDGE.
%
%   Example
%       edge = [2 3 4 5];
%       line = edgeToLine(edge);
%       figure(1); hold on; axis([0 10 0 10]);
%       drawLine(line, 'color', 'g')
%       drawEdge(edge, 'linewidth', 2)
%   
%   See also
%   edges2d, lines2d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-07-23,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

line = [edge(:, 1:2) edge(:, 3:4)-edge(:, 1:2)];
