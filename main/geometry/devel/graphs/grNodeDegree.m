%% Copyright (C) 2011 David Legland <david.legland@grignon.inra.fr>
%% All rights reserved.
%% 
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%% 
%%     1 Redistributions of source code must retain the above copyright notice,
%%       this list of conditions and the following disclaimer.
%%     2 Redistributions in binary form must reproduce the above copyright
%%       notice, this list of conditions and the following disclaimer in the
%%       documentation and/or other materials provided with the distribution.
%% 
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
%% ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function degree = grNodeDegree(node, edges)
%GRNODEDEGREE Degree of a node in a (undirected) graph
%
%   DEG = grNodeDegree(NODE_INDEX, EDGES);
%   return the degree of a node in the given edge list, that is the number
%   of edges connected to it.
%   NODE_INDEX is the index of the node, and EDGES is a liste of couples of
%   indices (origin and destination node).   
%   This degree is the sum of inner degree (number of edges arriving on the
%   node) and the outer degree (number of emanating edges).
%  
%   Note: Also works when NODE_INDEX is a vector of indices
%
%   To get degrees of all nodes:
%   grNodeDegree(1:size(nodes, 1), edges)
%
%   See Also: grNodeInnerDegree, grNodeOuterDegree
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2003-08-13
% Copyright 2006 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

%   HISTORY
%   10/02/2004 documentation
%   17/01/2006 change name, reimplement, and rewrite doc.

degree = zeros(size(node));

for i = 1:length(node(:))
    degree(i) = sum(edges(:,1) == node(i)) + sum(edges(:,2) == node(i));
end
