%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function ellipses2d(varargin)
%ELLIPSES2D Description of functions operating on ellipses
%   
%   Ellipses are represented by their center, the length of their 2
%   semi-axes length, and their angle from the Ox direction (in degrees). 
%   E = [XC YC A B THETA];
%
%   See also:
%   circles2d, inertiaEllipse, isPointInEllipse, ellipseAsPolygon
%   drawEllipse, drawEllipseArc
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2010 INRA - Cepia Software Platform.

help('ellipses2d');
