function [y] = geomean(x,DIM)
% GEOMEAN calculates the geomentric mean of data elements. 
% 
% 	y = geomean(x [,DIM [,W]])   is the same as 
% 	y = mean(x,'G' [,DIM]) 
%
% DIM	dimension
%	1 STD of columns
%	2 STD of rows
%	default or []: first DIMENSION, with more than 1 element
% W	weights to compute weighted mean (default: [])
%	if W=[], all weights are 1. 
%	number of elements in W must match size(x,DIM) 
%
% features:
% - can deal with NaN's (missing values)
% - weighting of data 
% - dimension argument also in Octave
% - compatible to Matlab and Octave
%
% see also: SUMSKIPNAN, MEAN, HARMMEAN
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; If not, see <http://www.gnu.org/licenses/>.


%	$Id$ 
%	Copyright (C) 2000-2002,2009 by Alois Schloegl <a.schloegl@ieee.org>
%    	This is part of the NaN-toolbox. For more details see
%    	   http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/


if nargin<2
        DIM=min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

[y, n] = sumskipnan(log(x),DIM);
y = exp (y./n);

