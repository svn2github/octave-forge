function o=meansq(i,DIM)
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
% - global FLAG_implicit_unbiased_estimation
%
% see also: SUMSQ, SUMSKIPNAN, MEAN, VAR, STD, RMS, FLAG_IMPLICIT_SKIP_NAN

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
%	Version 1.15
%	12 Mar 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl
%	a.schloegl@ieee.org	


if nargin<2,
        DIM=[];
end;

if isempty(DIM), 
        DIM=min(find(size(i)>1));
        if isempty(DIM), DIM=1; end;
end;

o = sumskipnan(i.*conj(i),DIM)./sumskipnan(~isnan(i),DIM);
   
   
   