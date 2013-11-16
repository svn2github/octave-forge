## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [nodes2, edges2] = grRemoveNodes(nodes, edges, rmNodes)
#GRREMOVENODES Remove several nodes in a graph
#
#   usage:
#   [NODES2 EDGES2] = grRemoveNodes(NODES, EDGES, NODES2REMOVE)
#   remove the nodes with indices NODE2REMOVE from array NODES, and also
#   remove edges containing the nodes NODE2REMOVE.
#
#   -----
#
#   author: David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 13/08/2003.
#

#   HISTORY
#   10/02/2004 doc


## edges processing

# remove all edges connected to each node
for i = 1:length(rmNodes)
    neighbours = grNeighborNodes(edges, rmNodes(i));
    if ~isempty(neighbours)
        [nodes, edges] = grRemoveEdges(nodes, edges, neighbours);
    end
end

# change edges information, due to the node index shift
for n = 1:length(rmNodes)
    for i = 1:length(edges)
        if edges(i,1) > rmNodes(n)-n+1
            edges(i,1) = edges(i,1) - 1;
        end
        if edges(i,2) > rmNodes(n)-n+1
            edges(i,2) = edges(i,2) - 1;
        end
    end 
end

edges2 = edges;


## nodes processing

# number of nodes
N   = size(nodes, 1);
NR  = length(rmNodes);
N2  = N-NR;

# allocate memory
nodes2 = zeros(N2, 2);

# process the first node
nodes2(1:rmNodes(1)-1,:) = nodes(1:rmNodes(1)-1,:);

# process the classical nodes
for i = 2:NR
    nodes2(rmNodes(i-1)-i+2:rmNodes(i)-i, :) = nodes(rmNodes(i-1)+1:rmNodes(i)-1, :);
end

# process the last node
nodes2(rmNodes(NR)-NR+1:N2, :) = nodes(rmNodes(NR)+1:N, :);
