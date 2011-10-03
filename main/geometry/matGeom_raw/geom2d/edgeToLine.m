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


function line = edgeToLine(edge)
%EDGETOLINE Convert an edge to a straight line
%
%   LINE = edgeToLine(EDGE);
%   Returns the line containing the edge EDGE.
%
%   Example
%       edge = [2 3 4 5];
%       line = edgeToLine(edge);
%       figure(1); hold on; axis([0 10 0 10]);
%       drawLine(line, 'color', 'g')
%       drawEdge(edge, 'linewidth', 2)
%   
%   See also
%   edges2d, lines2d
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2009-07-23,    using Matlab 7.7.0.471 (R2008b)
% Copyright 2009 INRA - Cepia Software Platform.

line = [edge(:, 1:2) edge(:, 3:4)-edge(:, 1:2)];
