function R = mad(i,DIM)
% MAD estimates the Mean Absolute deviation
% (note that according to [1,2] this is the mean deviation; 
% not the mean absolute deviation)
%
% y = mad(x,DIM)
%   calculates the mean deviation of x in dimension DIM
%
% DIM	dimension
%	1: STATS of columns
%	2: STATS of rows
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument 
% - compatible to Matlab and Octave
% - global FLAG_implicit_skip_nan
%
% see also: SUMSKIPNAN, VAR, STD, 
%
% REFERENCE(S):
% [1] http://mathworld.wolfram.com/MeanDeviation.html
% [2] L. Sachs, "Applied Statistics: A Handbook of Techniques", Springer-Verlag, 1984, page 253.
%
% [3] http://mathworld.wolfram.com/MeanAbsoluteDeviation.html
% [4] Kenney, J. F. and Keeping, E. S. "Mean Absolute Deviation." �6.4 in Mathematics of Statistics, Pt. 1, 3rd ed. Princeton, NJ: Van Nostrand, pp. 76-77 1962. 

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

%	Version 1.17;	17 Mar 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl
%	a.schloegl@ieee.org	
	

if nargin==1,
        DIM=0;
end
if ~DIM;
        DIM=flag_implicit_dimension;
end;	
if ~DIM;
        DIM=min(find(size(i)>1));
        if isempty(DIM), DIM=1; end;
end;


[S,N] = sumskipnan(i,DIM);		% sum
i     = i - repmat(S./N,size(i)./size(S));		% remove mean
[S,N] = sumskipnan(abs(i),DIM);		% 

if flag_implicit_unbiased_estim;
    n1 	= max(N-1,0);			% in case of n=0 and n=1, the (biased) variance, STD and STE are INF
else
    n1	= N;
end;

R     = S./n1;


