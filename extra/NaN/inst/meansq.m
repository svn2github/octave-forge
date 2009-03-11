function o=meansq(x,DIM)
% MEANSQ calculates the mean of the squares
%
% y = meansq(x,DIM)
%
% DIM	dimension
%	1 STD of columns
%	2 STD of rows
% 	N STD of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument also in Octave
% - compatible to Matlab and Octave
%
% see also: SUMSQ, SUMSKIPNAN, MEAN, VAR, STD, RMS

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


%	Copyright (C) 2000-2003,2009 by Alois Schloegl <a.schloegl@ieee.org>	
%	$Id$
%       This is part of the NaN-toolbox for Octave and Matlab 
%       see also: http://hci.tugraz.at/schloegl/matlab/NaN/       


if nargin<2,
	[o,N,ssq] = sumskipnan(x);
else
	[o,N,ssq] = sumskipnan(x,DIM);
end;

o = ssq./N;

   
