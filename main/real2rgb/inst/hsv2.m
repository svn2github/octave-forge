## Copyright (C) 2009-2012 Oliver Woodford
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
## 
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
## 
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

function map = hsv2(varargin)
%HSV2  Black to red variation of the hsv colormap
%
% Examples:
%   map = hsv2;
%   map = hsv2(len);
%   B = hsv2(A);
%   B = hsv2(A, lims);
%
% A variation of MATLAB's hsv colormap, which starts in black.
%
% The function can additionally be used to convert a real-valued array into
% a truecolor array using the colormap.
%
% IN:
%   len - Scalar length of the output colormap. If len == Inf the concise
%         table is returned. Default: len = size(get(gcf, 'Colormap'), 1);
%   A - Non-scalar numeric array of real values to be converted into
%       truecolor.
%   lims - 1x2 array of saturation limits to be used on A. Default:
%          [min(A(:)) max(A(:))].
%
% OUT:
%   map - (len)x3 colormap table.
%   B - size(A)x3 truecolor array.

% $Id: hsv2.m,v 1.2 2009/04/10 13:00:32 ojw Exp $
% Copyright: Oliver Woodford, 2009

map = [0 0 0; 0.5 0 0.5; 0 0 0.9; 0 1 1; 0 1 0; 1 1 0; 1 0 0];
map = colormap_helper(map, varargin{:});
