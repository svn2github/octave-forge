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

function varargout = grMergeMultipleEdges(nodes, edges)
#GRMERGEMULTIPLEEDGES Remove all edges sharing the same extremities
#
#   [NODES2 EDGES2] = grMergeMultipleEdges(NODES, EDGES)
#   Remove configuration with two edges sharing the same 2 nodes.
#
#   -----
#
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 13/08/2003.
#

#   HISTORY
#   10/02/2004 doc
#   2011-05-18 rename to grMergeMultipleEdges

rmedge = [];
for e = 1:length(edges)
    edge = edges(e, :);
    for e2 = e+1:length(edges)
        if (edge(1) == edges(e2, 1) && edge(2) == edges(e2, 2)) || ...
           (edge(1) == edges(e2, 2) && edge(2) == edges(e2, 1))
                rmedge(length(rmedge)+1) = e2; ##ok<AGROW>
        end
    end
end

[nodes edges] = grRemoveEdges(nodes, edges, rmedge);

# process output depending on how many arguments are needed
if nargout == 1
    out{1} = nodes;
    out{2} = edges;
    varargout{1} = out;
end

if nargout == 2
    varargout = {nodes, edges};
end

