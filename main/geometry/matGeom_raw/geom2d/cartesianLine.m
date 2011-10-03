%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function line = cartesianLine(varargin)
%CARTESIANLINE Create a straight line from cartesian equation coefficients
%
%   L = cartesianLine(A, B, C);
%   Create a line verifying the Cartesian equation:
%   A*x + B*x + C = 0;
%
%   See also:
%   lines2d, createLine
%
%   ---------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% created the 25/05/2004.
% Copyright 2010 INRA - Cepia Software Platform.


if length(varargin)==1
    var = varargin{1};
    a = var(:,1);
    b = var(:,2);
    c = var(:,3);
elseif length(varargin)==3
    a = varargin{1};
    b = varargin{2};
    c = varargin{3};
end

% normalisation factor
d = a.*a + b.*b;

x0 = -a.*c./d;
y0 = -b.*c./d;
theta = atan2(-a, b);
dx = cos(theta);
dy = sin(theta);

line = [x0 y0 dx dy];
