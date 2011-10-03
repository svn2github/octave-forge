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


function point = intersectLines(line1, line2, varargin)
%INTERSECTLINES Return all intersection points of N lines in 2D
%
%   PT = intersectLines(L1, L2);
%   returns the intersection point of lines L1 and L2. L1 and L2 are [1*4]
%   arrays, containing parametric representation of each line (in the form
%   [x0 y0 dx dy], see 'createLine' for details).
%   
%   In case of colinear lines, returns [Inf Inf].
%   In case of parallel but not colinear lines, returns [NaN NaN].
%
%   If each input is [N*4] array, the result is a [N*2] array containing
%   intersections of each couple of lines.
%   If one of the input has N rows and the other 1 row, the result is a
%   [N*2] array.
%
%   PT = intersectLines(L1, L2, EPS);
%   Specifies the tolerance for detecting parallel lines. Default is 1e-14.
%
%   Example
%   line1 = createLine([0 0], [10 10]);
%   line2 = createLine([0 10], [10 0]);
%   point = intersectLines(line1, line2)
%   point = 
%       5   5
%
%   See also
%   lines2d, edges2d, intersectEdges, intersectLineEdge
%   intersectLineCircle
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   19/02/2004 add support for multiple lines.
%   08/03/2007 update doc

% extreact tolerance
tol = 1e-14;
if ~isempty(varargin)
    tol = varargin{1};
end

x1 =  line1(:,1);
y1 =  line1(:,2);
dx1 = line1(:,3);
dy1 = line1(:,4);

x2 =  line2(:,1);
y2 =  line2(:,2);
dx2 = line2(:,3);
dy2 = line2(:,4);

N1 = length(x1);
N2 = length(x2);

% indices of parallel lines
par = abs(dx1.*dy2 - dx2.*dy1) < tol;

% indices of colinear lines
col = abs((x2-x1) .* dy1 - (y2-y1) .* dx1) < tol & par ;

x0(col) = Inf;
y0(col) = Inf;
x0(par & ~col) = NaN;
y0(par & ~col) = NaN;

i = ~par;

% compute intersection points
if N1==N2
	x0(i) = ((y2(i)-y1(i)).*dx1(i).*dx2(i) + x1(i).*dy1(i).*dx2(i) - x2(i).*dy2(i).*dx1(i)) ./ ...
        (dx2(i).*dy1(i)-dx1(i).*dy2(i)) ;
	y0(i) = ((x2(i)-x1(i)).*dy1(i).*dy2(i) + y1(i).*dx1(i).*dy2(i) - y2(i).*dx2(i).*dy1(i)) ./ ...
        (dx1(i).*dy2(i)-dx2(i).*dy1(i)) ;
    
elseif N1==1
	x0(i) = ((y2(i)-y1).*dx1.*dx2(i) + x1.*dy1.*dx2(i) - x2(i).*dy2(i).*dx1) ./ ...
        (dx2(i).*dy1-dx1.*dy2(i)) ;
	y0(i) = ((x2(i)-x1).*dy1.*dy2(i) + y1.*dx1.*dy2(i) - y2(i).*dx2(i).*dy1) ./ ...
        (dx1.*dy2(i)-dx2(i).*dy1) ;
    
elseif N2==1
   	x0(i) = ((y2-y1(i)).*dx1(i).*dx2 + x1(i).*dy1(i).*dx2 - x2.*dy2.*dx1(i)) ./ ...
        (dx2.*dy1(i)-dx1(i).*dy2) ;
	y0(i) = ((x2-x1(i)).*dy1(i).*dy2 + y1(i).*dx1(i).*dy2 - y2.*dx2.*dy1(i)) ./ ...
        (dx1(i).*dy2-dx2.*dy1(i)) ;
    
else
    % formattage a rajouter
   	x0(i) = ((y2(i)-y1(i)).*dx1(i).*dx2(i) + x1(i).*dy1(i).*dx2(i) - x2(i).*dy2(i).*dx1(i)) ./ ...
        (dx2(i).*dy1(i)-dx1(i).*dy2(i)) ;
	y0(i) = ((x2(i)-x1(i)).*dy1(i).*dy2(i) + y1(i).*dx1(i).*dy2(i) - y2(i).*dx2(i).*dy1(i)) ./ ...
        (dx1(i).*dy2(i)-dx2(i).*dy1(i)) ;
end

% concatenate result
point = [x0' y0'];
