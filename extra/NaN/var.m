function y=var(x,DIM)
% VAR calculates the variance.
% 
% y = var(x,DIM)
%   calculates the variance in dimension DIM
%   the default DIM is the first non-single dimension
%
% DIM	dimension
%	1: STD of columns
%	2: STD of rows
% 	N: STD of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument 
% - compatible to Matlab and Octave
%
% see also: MEANSQ, SUMSQ, SUMSKIPNAN, MEAN, RMS, STD,

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

%	Copyright (C) 2000-2002 by  Alois Schloegl  <a.schloegl@ieee.org>	

ver = version;
if nargin == 1,
        DIM = [];
elseif nargin == 2,
        if ~isnumeric(DIM),
                DIM = [];
        end
else
        fprintf(2,'Error VAR: invalid number of arguments\n usage: v=var(x [,DIM])\n');
end

% obtain which DIMENSION should be used
if isempty(DIM), 
        DIM = min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

% actual calculation 
[s,n,y] = sumskipnan(x, DIM);
m = s./n;	% mean
y = (y-s.*m);   % n * (summed squares with removed mean)

%if flag_implicit_unbiased_estim;    %% ------- unbiased estimates ----------- 
    n = max(n-1,0);			% in case of n=0 and n=1, the (biased) variance, STD and STE are INF
%end;
y = y./n;	% normalize

