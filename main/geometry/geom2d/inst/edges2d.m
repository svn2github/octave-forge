%% Copyright (c) 2011, INRA
%% 2008-2011, David Legland <david.legland@grignon.inra.fr>
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

%% -*- texinfo -*-
%% @deftypefn {Function File}  edges2d ()
%% Description of functions operating on planar edges
%
%   An edge is represented by the corodinate of its end points:
%   EDGE = [X1 Y1 X2 Y2];
%
%   A set of edges is represented by a N*4 array, each row representing an
%   edge.
%
%
%   @seealso{lines2d, rays2d, points2d
%   createEdge, edgeAngle, edgeLength, edgeToLine, midPoint
%   intersectEdges, intersectLineEdge, isPointOnEdge
%   clipEdge, transformEdge
%   drawEdge, drawCenteredEdge}
%% @end deftypefn
function edges2d(varargin)

  help('edges2d');

endfunction

