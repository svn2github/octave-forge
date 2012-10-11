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

function [v e] = quiverToGraph(x, y, dx, dy)
#QUIVERTOGRAPH Converts quiver data to quad mesh
#
#   [V E] = quiverToGraph(x, y, dx, dy)
#   x, y, dx and dy are matrices the same dimension, typically ones used
#   for display using 'quiver'.
#   V and E are vertex coordinates, and edge vertex indices of the graph
#   joining end points of vector arrows.
#
#   Example
#   quiverToGraph
#
#   See also
#
#
# ------
# Author: David Legland
# e-mail: david.legland@grignon.inra.fr
# Created: 2010-06-16,    using Matlab 7.9.0.529 (R2009b)
# Copyright 2010 INRA - Cepia Software Platform.

# compute vertex coordinates
vx = x+dx;
vy = y+dy;
v = [vx(:) vy(:)];

# index of vertices
labels = reshape(1:numel(x), size(x));

# compute indices of vertical edges
N1 = numel(labels(1:end-1,:));
vedges = [reshape(labels(1:end-1, :), [N1 1]) reshape(labels(2:end, :), [N1 1])];

# compute indices of horizontal edges
N2 = numel(labels(:, 1:end-1));
hedges = [reshape(labels(:, 1:end-1), [N2 1]) reshape(labels(:, 2:end), [N2 1])];

# concatenate horizontal and vertical edges
e = [hedges ; vedges];
