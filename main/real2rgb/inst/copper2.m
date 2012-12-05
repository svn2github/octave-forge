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

function map = copper2(varargin)
%COPPER2  Black-copper-white colormap
%
% Examples:
%   map = copper2;
%   map = copper2(len);
%   B = copper2(A);
%   B = copper2(A, lims);
%
% A variation of MATLAB's copper colormap, which continues on to white.
% This colormap converts linearly to grayscale when printed in black &
% white.
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

% $Id: copper2.m,v 1.2 2009/04/10 13:00:32 ojw Exp $
% Copyright: Oliver Woodford, 2009

map = [0 0 0; 0.2651 0.2426 0.2485; 0.666 0.4399 0.3738; 0.8118 0.7590 0.5417; 1 1 1];
map = colormap_helper(map, varargin{:});
