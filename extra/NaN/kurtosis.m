function R=kurtosis(i,DIM)
% KURTOSIS estimates the kurtosis
%
% y = kurtosis(x,DIM)
%   calculates kurtosis of x in dimension DIM
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
% - global FLAG_implicit_unbiased_estimation
%
% see also: SUMSKIPNAN, VAR, STD, VAR, SKEWNESS, MOMENT, STATISTIC, 
%    IMPLICIT_SKIP_NAN
%
% REFERENCE(S):
% http://mathworld.wolfram.com/

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
        DIM=min(find(size(i)>1));
        if isempty(DIM), DIM=1; end;
end;

R = statistic(i,DIM,'kurtosis');

