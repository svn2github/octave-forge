function M=moment(i,p,opt,DIM)
% MOMENT estimates the p-th moment 
% 
% M = moment(x, p [,opt] [,DIM])
%   calculates p-th central moment of x in dimension DIM
%
% p	moment of order p
% opt   'ac': absolute 'a' and/or central ('c') moment
%	DEFAULT: '' raw moments are estimated
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
% - global FLAG_implicit_skip_nan
%
% see also: STD, VAR, SKEWNESS, KURTOSIS, STATISTIC, 
%     FLAG_IMPLICIT_SKIP_NAN, FLAG_IMPLICIT_UNBIASED_ESTIMATION
%
% REFERENCE(S):
% http://mathworld.wolfram.com/Moment.html

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

%	Version 1.15
%	12 Mar 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl
%	a.schloegl@ieee.org	

if nargin==2,
        DIM=[];
	opt=[];        
elseif nargin==3,
        DIM=[];
elseif nargin==4,
        
else
        fprintf('Error MOMENT: invalid number of arguments\n');
        return;
end;

if p<=0;
        fprintf('Error MOMENT: invalid model order p=%f\n',p);
        return;
end;

if isnumeric(opt) | ~isnumeric(DIM),
        tmp = DIM;
        DIM = opt;
	opt = tmp;        
end;

if ~isempty(opt),
        if any(opt=='c')
		[S,N] = sumskipnan(i,DIM);	% sum
		i = i - repmat(S./N,size(i)./size(S));
	end;
        if any(opt=='a')
		i = abs(i);	
	end;
end;

[M,N] = sumskipnan(i.^p,DIM);
if flag_implicit_unbiased_estim,
        N = max(N-1,0);			% in case of n=0 and n=1, the (biased) variance, STD and STE are INF
end;	
M = M./N;