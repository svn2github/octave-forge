function [y] = harmmean(x,DIM)
% HARMMEAN calculates the harmonic mean of data elements. 
% The harmonic mean is the inverse of the mean of the inverse elements.
% 
% 	y = harmmean(x [,DIM]) is the same as 
% 	y = mean(x,'H' [,DIM]) 
%
% DIM	dimension
%	1 STD of columns
%	2 STD of rows
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument also in Octave
% - compatible to Matlab and Octave
%
% see also: SUMSKIPNAN, MEAN, GEOMEAN
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
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


% original Copyright by:  KH <Kurt.Hornik@ci.tuwien.ac.at>
% Copyright (c) 2001 by Alois Schloegl <a.schloegl@ieee.org>	

%	Version 1.23;	07 Jun 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl
%	a.schloegl@ieee.org	



if nargin<2
        DIM=[]; 
end
if isempty(DIM), 
        DIM=flag_implicit_dimension;
end;	
if ~DIM
        DIM=min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

[y, n] = sumskipnan(1./x,DIM);
y = n./y;

