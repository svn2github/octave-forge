%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function alpha = formatAngle(alpha)
%FORMATANGLE  Ensure an angle value is comprised between 0 and 2*PI
%   ALPHA2 = formatAngle(ALPHA)
%   ALPHA2 is the same as ALPHA modulo 2*PI and is positive.
%
%   Example:
%   formatAngle(5*pi)
%   ans =
%       3.1416
%
%   See also
%   vectorAngle, lineAngle
%
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2008-03-10,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2008 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

% HISTORY
% 2010-03-31 deprecate and replace by function 'normalizeAngle'

% deprecation warning
warning('geom2d:deprecated', ...
    '''formatAngle'' is deprecated, use ''normalizeAngle'' instead');

alpha = mod(alpha, 2*pi);
alpha(alpha<0) = 2*pi + alpha(alpha<0);
