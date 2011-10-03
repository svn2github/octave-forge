%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function b = isPointInEllipse(point, ellipse, varargin)
%ISPOINTINELLIPSE Check if a point is located inside a given ellipse
%
%   B = isPointInEllipse(POINT, ELLIPSE) 
%   Returns true if point is located inside the given ellipse.
%
%   B = isPointInEllipse(POINT, ELLIPSE, TOL) 
%   Specifies the tolerance value
%
%   Example:
%   isPointInEllipse([1 0], [0 0 2 1 0])
%   ans =
%       1
%   isPointInEllipse([0 0], [0 0 2 1 0])
%   ans =
%       1
%   isPointInEllipse([1 1], [0 0 2 1 0])
%   ans =
%       0
%   isPointInEllipse([1 1], [0 0 2 1 30])
%   ans =
%       1
%
%   See also:
%   ellipses2d, isPointInCircle
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 11/03/2011
%

%   HISTORY

% extract computation tolerance
tol = 1e-14;
if ~isempty(varargin)
    tol = varargin{1};
end

% compute ellipse to unit circle transform
rot = createRotation(-deg2rad(ellipse(5)));
sca = createScaling(1./ellipse(3:4));
trans = sca * rot;

% transform points to unit circle basis
pTrans = bsxfun(@minus, point, ellipse(:,1:2));
pTrans = transformPoint(pTrans, trans);

% test if distance to origin smaller than 1
b = sqrt(sum(power(pTrans, 2), 2)) - 1 <= tol;
    
