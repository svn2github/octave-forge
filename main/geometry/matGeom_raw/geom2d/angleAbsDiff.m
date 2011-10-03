%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function dif = angleAbsDiff(angle1, angle2)
%ANGLEABSDIFF Absolute difference between two angles
%
%   AD = angleAbsDiff(ANGLE1, ANGLE2)
%   Computes the absolute angular difference between two angles in radians.
%   The result is comprised between 0 and PI.
%
%   Example
%     A = angleAbsDiff(pi/2, pi/3)
%     A = 
%         0.5236   % equal to pi/6
%
%   See also
%   angles2d, angleDiff
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-07-27,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% first, normalization
angle1 = normalizeAngle(angle1);
angle2 = normalizeAngle(angle2);

% compute difference and normalize
dif = normalizeAngle(angle1 - angle2);
dif = min(dif, 2*pi - dif);
