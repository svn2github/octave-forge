%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function vr = rotateVector(v, angle)
%ROTATEVECTOR Rotate a vector by a given angle
%
%   VR = rotateVector(V, THETA)
%   Rotate the vector V by an angle THETA, given in radians.
%
%   Example
%   rotateVector([1 0], pi/2)
%   ans = 
%       0   1
%
%   See also
%   vectors2d, transformVector, createRotation
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-04-14,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% precomputes angles
cot = cos(angle);
sit = sin(angle);

% compute rotated coordinates
vr = [cot * v(:,1) - sit * v(:,2) , sit * v(:,1) + cot * v(:,2)];
