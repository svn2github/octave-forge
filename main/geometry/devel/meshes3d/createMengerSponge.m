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

function varargout = createMengerSponge()
#CREATEMENGERSPONGE Create a cube with an inside cross removed
#
#   [n e f] = createMengerSponge;
#   Main use is to test possibility of drawing polyhedra with complex faces
#   (polygonal faces with holes)
#
#   Example
#   [n e f] = createMengerSponge;
#   drawMesh(n, f);
#   
#   See also
#   meshes3d, drawMesh
#
# ------
# Author: David Legland
# e-mail: david.legland@nantes.inra.fr
# Created: 2007-10-18
# Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

#   HISTORY
#   2008-10-17 finishes implementation

nodes =[...
    ... # main cube corners (1->8)
    0 0 0; ...
    3 0 0; ...
    0 3 0; ...
    3 3 0; ...
    0 0 3; ...
    3 0 3; ...
    0 3 3; ...
    3 3 3; ...
    ... # outer cube inner face corners
    1 1 0; ... # face z=0 (9->12)
    2 1 0; ...
    1 2 0; ...
    2 2 0; ...
    1 1 3; ... # face z=3 (13->16)
    2 1 3; ...
    1 2 3; ...
    2 2 3; ...
    1 0 1; ... # face y=0 (17->20)
    2 0 1; ...
    1 0 2; ...
    2 0 2; ...
    1 3 1; ... # face y=3 (21->24)
    2 3 1; ...
    1 3 2; ...
    2 3 2; ...
    0 1 1; ... # face x=0 (25->28)
    0 2 1; ...
    0 1 2; ...
    0 2 2; ...
    3 1 1; ... # face x=3 (29->32)
    3 2 1; ...
    3 1 2; ...
    3 2 2; ...
    ... # inner cube corners  (33->40)
    1 1 1; ...
    2 1 1; ...
    1 2 1; ...
    2 2 1; ...
    1 1 2; ...
    2 1 2; ...
    1 2 2; ...
    2 2 2; ...
    ];
    
edges = [...
    1 2;1 3;2 4;3 4;5 6;5 7;6 8;7 8;1 5;2 6;3 7;4 8;... # outer cube
    9 10;9 11;10 12;11 12;13 14;13 15;14 16;15 16; ... 
    17 18;17 19;18 20;19 20; 21 22;21 23;22 24;23 24; ...
    25 26;25 27;26 28;27 28; 29 30;29 31;30 32;31 32; ...
    33 34;33 35;34 36;35 36; 37 38;37 39;38 40;39 40; ... # inner cube
    33 37;34 38;35 39;36 40; ...
     9 33;10 34;11 35;12 36; ... # parallel to xy
    13 37;14 38;15 39;16 40; ...
    17 33;18 34;19 37;20 38; ... # parallel to yz
    21 35;22 36;23 39;24 40; ...
    25 33;26 35;27 37;28 39; ... # parallel to xz
    29 34;30 36;31 38;32 40; ...
    ];

# Alternative definition for faces:
#     [1 2 4 3 NaN 9  11 12 10], ... 
#     [5 6 8 7 NaN 13 15 16 14], ...
#     [1 5 7 3 NaN 25 26 28 27], ....
#     [2 6 8 4 NaN 29 30 32 31], ...
#     [1 2 6 5 NaN 17 18 20 19], ...
#     [3 4 8 7 NaN 21 22 24 23], ...

faces = {...
    ... # 6 square faces with a square hole
    [1 2 4 3 1 9  11 12 10  9], ... 
    [5 6 8 7 5 13 15 16 14 13], ...
    [1 5 7 3 1 25 26 28 27 25], ....
    [2 6 8 4 2 29 30 32 31 29], ...
    [1 2 6 5 1 17 18 20 19 17], ...
    [3 4 8 7 3 21 22 24 23 21], ...
    ... # faces orthogonal to XY plane, parallel to Oz axis
    [ 9 10 34 33], [ 9 11 35 33], [10 12 36 34], [11 12 36 35], ... 
    [13 14 38 37], [13 15 39 37], [14 16 40 38], [15 16 40 39], ...
    ... # faces orthogonal to YZ plane, parallel to Oy axis
    [17 18 34 33], [17 19 37 33], [18 20 38 34], [19 20 38 37], ...
    [21 22 36 35], [21 23 39 35], [22 24 40 36], [23 24 40 39], ...
    ...# faces orthogonal to the YZ plane, parallel to Ox axis
    [25 33 35 26], [25 33 37 27], [26 35 39 28], [27 37 39 28], ...
    [29 30 36 34], [29 31 38 34], [30 32 40 36], [31 32 40 38], ...
    };

# format output
varargout = formatMeshOutput(nargout, nodes, edges, faces);
