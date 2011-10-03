%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function trans = translation(varargin)
%TRANSLATION return 3*3 matrix of a translation
%
%   TRANS = translation(DX, DY);
%   Returns the translation corresponding to DX and DY.
%   The returned matrix has the form :
%   [1 0 DX]
%   [0 1 DY]
%   [0 0  1]
%
%   TRANS = translation(POINT);
%   Returns the translation corresponding to the given point [x y].
%
%
%   See also:
%   transforms2d, transformPoint, rotation, scaling
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 06/04/2004.
%

%   HISTORY
%   22/04/2009: copy to createTranslation and deprecate

% deprecation warning
warning('geom2d:deprecated', ...
    '''translation'' is deprecated, use ''createTranslation'' instead');

% call current implementation
trans = createTranslation(varargin{:});
