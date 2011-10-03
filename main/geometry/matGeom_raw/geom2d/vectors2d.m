%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function vectors2d
%VECTORS2D Description of functions operating on plane vectors
%
%   A vector is defined by its two cartesian coordinates, put into a row
%   vector of 2 elements:
%   V = [vx vy];
%
%   Several vectors are stored in a matrix with two columns, one for the
%   x-coordinate, one for the y-coordinate.
%   VS = [vx1 vy1 ; vx2 vy2 ; vx3 vy3];
%
%   See also: 
%   vectorNorm, vectorAngle, isPerpendicular, isParallel
%   normalizeVector, transformVector, rotateVector
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

help('vectors2d');
