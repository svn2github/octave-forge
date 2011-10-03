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


function transfo = createBasisTransform(source, target)
%CREATEBASISTRANSFORM Compute matrix for transforming a basis into another basis
%
%   TRANSFO = createBasisTransform(SOURCE, TARGET)
%   Both SOURCE and TARGET represent basis, in the following form:
%   [x0 y0  ex1 ey1  ex2 ey2]
%   [y0 y0] is the origin of the basis, [ex1 ey1] is the first direction
%   vector, and [ex2 ey2] is the second direction vector.
%
%   The result TRANSFO is a 3-by-3 matrix such that a point expressed with
%   coordinates of the first basis will be represented by new coordinates
%   P2 = transformPoint(P1, TRANSFO) in the target basis.
%   
%   TRANSFO = createBasisTransform(TARGET)
%   Assumes the source is the standard (Oij) basis, with origin at (0,0),
%   first direction vector equal to (1,0) and second direction  vector
%   equal to (0,1).
%
%
%   Example
%     % standard basis transform
%     src = [0 0   1 0   0 1];
%     % target transform, just a rotation by atan(2/3) followed by a scaling
%     tgt = [0 0   .75 .5   -.5 .75];
%     % compute transform
%     trans = createBasisTransform(src, tgt);
%     % transform the point (.25,1.25) into the point (1,1)
%     p1 = [.25 1.25];
%     p2 = transformPoint(p1, trans)
%     ans =
%         1   1
%
%   See also
%   transforms2d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2010-12-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2010 INRA - Cepia Software Platform.

% init basis transform to identity
t1 = eye(3);
t2 = eye(3);

if nargin==2
    % from source to reference basis
    t1(1:2, 1) = source(3:4);
    t1(1:2, 2) = source(5:6);
    t1(1:2, 3) = source(1:2);
else
    % if only one input, use first input as target basis, and leave the
    % first matrix to identity
    target = source;
end

% from reference to target basis
t2(1:2, 1) = target(3:4);
t2(1:2, 2) = target(5:6);
t2(1:2, 3) = target(1:2);

% compute transfo
% same as: transfo = inv(t2)*t1;
transfo = t2\t1;

