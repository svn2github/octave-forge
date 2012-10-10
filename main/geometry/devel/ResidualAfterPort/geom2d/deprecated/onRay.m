%% Copyright (c) 2011, INRA
%% 2007-2011, David Legland <david.legland@grignon.inra.fr>
%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%% All rights reserved.
%% (simplified BSD License)
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%%
%% 1. Redistributions of source code must retain the above copyright notice, this
%%    list of conditions and the following disclaimer.
%%     
%% 2. Redistributions in binary form must reproduce the above copyright notice, 
%%    this list of conditions and the following disclaimer in the documentation
%%    and/or other materials provided with the distribution.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
%% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%% POSSIBILITY OF SUCH DAMAGE.
%%
%% The views and conclusions contained in the software and documentation are
%% those of the authors and should not be interpreted as representing official
%% policies, either expressed or implied, of copyright holder.


function b = onRay(point, ray)
%ONRAY test if a point belongs to a ray
%
%   B = onRay(PT, RAY);
%   Returns 1 if point PT belongs to the ray RAY.
%   PT is given by [x y] and RAY by [x0 y0 dx dy].
%
%   See also:
%   rays2d, points2d, onLine
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   07/07/2005 : normalize condition to test if on the line
%       and add support of multiple rays or points
%   22/05/2009 deprecate

% deprecation warning
warning('geom2d:deprecated', ...
    '''onRay'' is deprecated, use ''isPointOnRay'' instead');

% number of rays and points
Nr = size(line, 1);
Np = size(point, 1);

% if several rays or several points, adapt sizes of arrays
x0 = repmat(ray(:,1)', Np, 1);
y0 = repmat(ray(:,2)', Np, 1);
dx = repmat(ray(:,3)', Np, 1);
dy = repmat(ray(:,4)', Np, 1);
xp = repmat(point(:,1), 1, Nr);
yp = repmat(point(:,2), 1, Nr);

% test if points belongs to the ray
b1 = abs((xp-x0).*dy-(yp-y0).*dx)./sqrt(dx.*dx+dy.*dy) < 1e-13;

% check if points lie the good direction on the rays
ind = abs(dx)>abs(dy);
t = zeros(size(b1));
t(ind) = (xp(ind)-x0(ind))./dx(ind);
t(~ind) = (yp(~ind)-y0(~ind))./dy(~ind);

% combine the two tests
b = b1 && (t>0);
