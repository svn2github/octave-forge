%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function trans = lineSymmetry(line)
%LINESYMMETRY create line symmetry as 2D affine transform
%
%   TRANS = lineSymmetry(LINE);
%   where line is given as [x0 y0 dx dy], return the affine tansform
%   corresponding to the desired line symmetry
%
%
%   See also:
%   lines2d, transforms2d, transformPoint, translation, homothecy
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 19/01/2005.
%

% deprecation warning
warning('geom2d:deprecated', ...
    '''lineSymmetry'' is deprecated, use ''createLineReflection'' instead');

% call current implementation
trans = createLineReflection(line);
