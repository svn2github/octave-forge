%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function trans = homothecy(point, ratio)
%HOMOTHECY create a homothecy as an affine transform
%
%   TRANS = homothecy(POINT, K);
%   POINT is the center of the homothecy, K is its factor.
%
%   See also:
%   transforms2d, transformPoint, createTranslation
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 20/01/2005.
%

%   HISTORY
%   22/04/2009: copy to createHomothecy and deprecate

% deprecation warning
warning('geom2d:deprecated', ...
    '''homothecy'' is deprecated, use ''createHomothecy'' instead');

% call current implementation
trans = createHomothecy(point, ratio);
