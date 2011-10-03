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


function point = intersectLineEdge(line, edge)
%INTERSECTLINEEDGE Return intersection between a line and an edge
%
%   P = intersectLineEdge(LINE, EDGE);
%   returns the intersection point of lines LINE and edge EDGE. 
%   LINE is a 1x4 array containing parametric representation of the line
%   (in the form [x0 y0 dx dy], see 'createLine' for details). 
%   EDGE is a 1x4 array containing coordinates of first and second point
%   (in the form [x1 y1 x2 y2], see 'createEdge' for details). 
%   
%   In case of colinear line and edge, returns [Inf Inf].
%   If line does not intersect edge, returns [NaN NaN].
%
%   If each input is [N*4] array, the result is a [N*2] array containing
%   intersections for each couple of edge and line.
%   If one of the input has N rows and the other 1 row, the result is a
%   [N*2] array.
%
%   See also:
%   lines2d, edges2d, intersectEdges, intersectLines
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   19/02/2004: add support for multiple lines.
%   08/03/2007: update doc

x0 =  line(:,1);
y0 =  line(:,2);
dx1 = line(:,3);
dy1 = line(:,4);
x1 =  edge(:,1);
y1 =  edge(:,2);
x2 = edge(:,3);
y2 = edge(:,4);
dx2 = x2-x1;
dy2 = y2-y1;

N1 = length(x0);
N2 = length(x1);

% indices of parallel lines
par = abs(dx1.*dy2-dx2.*dy1)<1e-14;

% indices of colinear lines
col = abs((x1-x0).*dy1-(y1-y0).*dx1)<1e-14 & par ;

xi(col) = Inf;
yi(col) = Inf;
xi(par & ~col) = NaN;
yi(par & ~col) = NaN;

i = ~par;

% compute intersection points
if N1==N2
	xi(i) = ((y1(i)-y0(i)).*dx1(i).*dx2(i) + x0(i).*dy1(i).*dx2(i) - x1(i).*dy2(i).*dx1(i)) ./ ...
        (dx2(i).*dy1(i)-dx1(i).*dy2(i)) ;
	yi(i) = ((x1(i)-x0(i)).*dy1(i).*dy2(i) + y0(i).*dx1(i).*dy2(i) - y1(i).*dx2(i).*dy1(i)) ./ ...
        (dx1(i).*dy2(i)-dx2(i).*dy1(i)) ;
elseif N1==1
	xi(i) = ((y1(i)-y0).*dx1.*dx2(i) + x0.*dy1.*dx2(i) - x1(i).*dy2(i).*dx1) ./ ...
        (dx2(i).*dy1-dx1.*dy2(i)) ;
	yi(i) = ((x1(i)-x0).*dy1.*dy2(i) + y0.*dx1.*dy2(i) - y1(i).*dx2(i).*dy1) ./ ...
        (dx1.*dy2(i)-dx2(i).*dy1) ;
elseif N2==1
	xi(i) = ((y1-y0(i)).*dx1(i).*dx2 + x0(i).*dy1(i).*dx2 - x1(i).*dy2.*dx1(i)) ./ ...
        (dx2.*dy1(i)-dx1(i).*dy2) ;
	yi(i) = ((x1-x0(i)).*dy1(i).*dy2 + y0(i).*dx1(i).*dy2 - y1(i).*dx2.*dy1(i)) ./ ...
        (dx1(i).*dy2-dx2.*dy1(i)) ;
end

point   = [xi' yi'];
out     = find(~isPointOnEdge(point, edge));
point(out, :) = repmat([NaN NaN], [length(out) 1]);
