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

function varargout = drawGraphFaces(varargin)
#DRAWGRAPHFACES Draw faces of a graph
#
#   DRAWGRAPHFACES(NODES, EDGES) 
#   draw a graph specified by a set of nodes (array N*2 or N*3,
#   corresponding to coordinate of each node), and a set of edges (an array
#   Ne*2, containing for each edge the first and the second node).
#   Default drawing is a red circle for nodes and a blue line for edges.
#
#   DRAWGRAPHFACES(NODES, EDGES, FACES)
#   also draw faces of the graph as patches.
#
#   DRAWGRAPHFACES(GRAPH)
#   passes argument in a srtucture with at least 3 fields named 'nodes', 
#   'edges', and 'faces', corresponding to previously described parameters.
#   GRAPH can also be a cell array, whose first element is node array,
#   second element is edges array, and third element, if present, is faces
#   array.
#
#
#   DRAWGRAPHFACES(..., SFACES)
#   specify the draw mode for each element, as in the classical 'plot'
#   function. To not display some elements, uses 'none'.
#
#
#   H = DRAWGRAPHFACES(...) 
#   return handle to the set of faces.
#   
#
# ------
# Author: David Legland
# e-mail: david.legland@jouy.inra.fr
# Created: 2005-11-24
# Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).

#   HISTORY

## initialisations

f = [];

sf = 'c';       # faces are cyan


## process input arguments

if nargin==0
    help drawGraphFaces;
    return;
end

# First extract the graph structure

var = varargin{1};
if iscell(var)
    # graph is stored as a cell array : first cell is nodes, second one is
    # edges, and third is faces
    n = var{1};
    if length(var) > 2
        f = var{3};
    end
    varargin = varargin(2:length(varargin));
    
elseif isstruct(var)
    # graph is stored as a structure, with fields 'nodes', 'edges', and
    # eventually 'faces'.
    n = var.nodes;
    if isfield(var, 'faces')
        f = var.faces;
    end
    varargin = varargin(2:length(varargin));
    
else
    # graph is stored as set of variables : nodes, edges, and eventually
    # faces
    n = varargin{1};
    if length(varargin) > 2
        var = varargin{3};
        if isnumeric(var) || iscell(var)
            f = var;
            varargin = varargin(4:length(varargin));
        else
            varargin = varargin(3:length(varargin));
        end
    else
        varargin = varargin(3:length(varargin));
    end
        
end

# extract drawing style 
if ~isempty(varargin)
    sf = varargin{1};
end


## main drawing processing

hold on;

if size(n, 2) == 2
    # Draw faces of a 2D graph ------------
    if ~strcmp(sf, 'none')
        if iscell(f)
            # each face is contained in a cell.
            for fi=1:length(f)
                hf(fi) = patch('Faces', f{fi}, 'Vertices', n, 'FaceColor', sf, 'EdgeColor', 'none');  ##ok<AGROW>
            end
        else
            # process faces as an Nf*N array. Nf i the number of faces,
            # and all faces have the same number of vertices (nodes).
            hf = patch('Faces', f, 'Vertices', n, 'FaceColor', sf, 'EdgeColor', 'none'); 
        end
    end
    
elseif size(n, 2) == 3
    # Draw faces of a 3D graph ----------------------

    # use a zbuffer to avoid display pbms.
    set(gcf, 'renderer', 'zbuffer');
       
    # Draw 3D Faces ----------------------
    if ~strcmp(sf, 'none')
        if iscell(f)
            # each face is contained in a cell.
            for fi=1:length(f)
                hf(fi) = patch('Faces', f{fi}, 'Vertices', n, 'FaceColor', sf, 'EdgeColor', 'none');  ##ok<AGROW>
            end
        else
            # process faces as an Nf*N array. Nf i the number of faces,
            # and all faces have the same number of vertices (nodes).
            hf = patch('Faces', f, 'Vertices', n, 'FaceColor', sf, 'EdgeColor', 'none'); 
        end
    end
    
end


## format output arguments

if nargout==1
    varargout{1} = hf;
end
  
