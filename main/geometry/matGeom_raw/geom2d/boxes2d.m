%% Copyright (c) 2010, David Legland <david.legland@grignon.inra.fr>
%%
%% All rights reserved.
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the BSD License. For details see the COPYING
%% file included as part of this distribution.

%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function boxes2d(varargin)
%BOXES2D Description of functions operating on bounding boxes
%
%   A box is represented as a set of limits in each direction:
%   BOX = [XMIN XMAX YMIN YMAX].
%
%   Boxes are used as result of computation for bounding boxes, and to clip
%   shapes.
%
%   See also
%   clipPoints, clipLine, clipEdge, clipRay
%   mergeBoxes, intersectBoxes, randomPointInBox
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2008-10-13,    using Matlab 7.4.0.287 (R2007a)
% Copyright 2010 INRA - Cepia Software Platform.

help('boxes2d');
