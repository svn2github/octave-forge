%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function vn = normalizeVector(v)
%NORMALIZEVECTOR Normalize a vector to have norm equal to 1
%
%   V2 = normalizeVector(V);
%   Returns the normalization of vector V, such that ||V|| = 1. V can be
%   either a row or a column vector.
%
%   When V is a MxN array, normalization is performed for each row of the
%   array.
%
%   Example:
%   vn = normalizeVector([3 4])
%   vn =
%       0.6000   0.8000
%   vectorNorm(vn)
%   ans =
%       1
%
%   See Also:
%   vectors2d, vecnorm
%
%
%   ---------
%
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 29/11/2004.
%

%   HISTORY
%   2005-01-14 correct bug
%   2009-05-22 rename as normalizeVector
%   2011-01-20 use bsxfun

dim = size(v);

if dim(1)==1 || dim(2)==1
    vn = v / sqrt(sum(v.^2));
else
    %same as: vn = v./repmat(sqrt(sum(v.*v, 2)), [1 dim(2)]);
    vn = bsxfun(@rdivide, v, sqrt(sum(v.^2, 2)));
end
