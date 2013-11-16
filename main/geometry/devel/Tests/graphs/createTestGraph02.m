function [nodes edges] = createTestGraph02(varargin)
#CREATETESTGRAPH02  Test graph for geodesic functions
#
#   [nodes edges] = createTestGraph02;
#
#   Example
#     [nodes edges] = createTestGraph02;
#     figure;
#     axis([0 100 10 90]);
#     axis equal;
#     drawGraph(nodes, edges);
#
#   See also
#
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2011-05-19,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2011 INRA - Cepia Software Platform.

nodes = [ ...
   10 40; ...
   10 60; ...
   20 50; ...
   40 50; ...
   50 20; ...
   50 40; ...
   50 60; ...
   50 80; ...
   60 50; ...
   80 50; ...
   90 40; ...
   90 60];

edges = [...
    1  3; ...
    2  3; ...
    3  4; ...
    4  6; ...
    4  7; ...
    5  6; ...
    6  9; ...
    7  8; ...
    7  9; ...
    9 10; ...
   10 11; ...
   10 12];