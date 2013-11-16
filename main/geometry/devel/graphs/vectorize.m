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

function varargout = vectorize(img)
#VECTORIZE Transform a binary skeleton into a graph (nodes and edges)
#
#   [NODES EDGES] = vectorize(IMG);
#   IMG is a binary image, with structure of width 1 pixel (such as the
#   result of sketetonization)
#   NODES is a Nnodes*2 array of doubles containing values of vertices
#   coordinates
#   EDGES is a Nedges*2 array of integers, containing indices of vertices
#   of each extremity.
#
#   GRAPH = vectorize(IMG);
#   return the result as a graph structure, containing fields 'nodes' and
#   'edges'.
#
#
#   Example:
#   img = imread('circles.png');
#   skel = bwmorph(img, 'shrink', Inf);
#   [nodes, edges] = vectorize(skel);
#   figure; imshow(skel); hold on;
#   drawGraph(nodes, edges);
#
#
#   See Also: drawGraph, minGraph, removeMultiplePoints
#
#   -----
#
#   author : David Legland 
#   INRA - TPV URPOI - BIA IMASTE
#   created the 17/07/2003.
#

#   HISTORY
#   21/07/2003 : uses only one loop to detect nodes and edges
#   26/01/2004 : reverse direction of searching pixels in array : faster
#   10/02/2004 : documentation
#   11/02/2004 : supprime calcul du temps execution
#   18/01/2006 : rewrite by using a label for each point, making it working
#   faster


## Initialisations

# nodes array
[y x] = find(img>0);
points = [x y];

# intialize empty edges array.
edges  = zeros(0, 2);


# adapt datasize of label image to the number of points.
n = length(x);
if n < 256
    typ = 'uint8';
elseif n < power(2, 16)
    typ = 'uint16';
elseif n < power(2, 32);
    typ = 'uint32';
else
    typ = 'uint64';
end

# create label image
dim = size(img);
img = zeros(dim, typ);
for i = 1:length(x)
    img(y(i), x(i)) = i;
end

## detection of edges

# first line 
for x = 2:dim(2)
    # continue if no point
    if img(1, x) == 0
        continue;
    end
    
    # check the point to the left
    if img(1, x-1) > 0
        edges = [edges; img(1, x) img(1, x-1)];
    end
end

# normal lines 
for y = 2:dim(1)
    
    # first point of the line 
    if img(y, 1) > 0

        # check point on the top
        if img(y-1,1)>0
            edges = [edges; img(y, 1) img(y-1,1)];
        end

        # check point on the top-right
        if img(y-1,2)>0
            edges = [edges; img(y, 1) img(y-1,2)];
        end
    end
    
    # each 'normal' point of the line 
    for x=2:dim(2)-1
        if ~img(y,x)
            continue;
        end
        
        # check point on the left
        if img(y, x-1)>0
            edges = [edges; img(y, x) img(y, x-1)];
        end

        # check point on the top-left
        if img(y-1, x-1)>0
            edges = [edges; img(y, x) img(y-1, x-1)];
        end
        
        # check point on the top
        if img(y-1, x)>0
            edges = [edges; img(y, x) img(y-1, x)];
        end
        
        # check point on the top-right
        if img(y-1, x+1)>0
            edges = [edges; img(y, x) img(y-1, x+1)];
        end
        
    end
    
    # last point of the line 
    if img(y, dim(2))

        # check point on the left
        if img(y, dim(2)-1)>0
            edges = [edges; img(y, dim(2)) img(y, dim(2)-1)];
        end
        
        # check point on the top-left
        if img(y-1, dim(2)-1)>0
            edges = [edges; img(y, dim(2)) img(y-1, dim(2)-1)];
        end
        
        # check point on the top
        if img(y-1, dim(2))>0
            edges = [edges; img(y, dim(2)) img(y-1, dim(2))];
        end
    end
end


## Format output arguments

# process output depending on how many arguments are needed
if nargout == 1
    out.nodes = points;
    out.edges = edges;
    varargout{1} = out;
end

if nargout == 2
    varargout{1} = points;
    varargout{2} = edges;
end

