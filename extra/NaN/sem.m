function y=sem(x,DIM)
% SEM calculates the standard error of the mean
% 
% y = SEM(x,DIM)
%   calculates the variance in dimension DIM
%   the default DIM is the first non-single dimension
%
% DIM	dimension
%	1: SEM of columns
%	2: SEM of rows
% 	N: SEM of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument 
% - compatible to Matlab and Octave
%
% see also: SUMSKIPNAN, MEAN, VAR, STD

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


% check input arguments 
if nargin==1,
        DIM=[];
elseif nargin==2,
        if ~isnumeric(DIM),
                DIM=[];
        end
else
        fprintf(2,'Error NaN/VAR: invalid number of arguments\n usage: v=var(x [,DIM] [,opt])\n');
end

% obtain which DIMENSION should be used
if isempty(DIM), 
        DIM=min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

% actual calculation 
[m,n] = sumskipnan(x,DIM);
m = m./n;	% mean
x = x-repmat(m,size(x)./size(m)); % remove mean
y = sumskipnan(x.*conj(x),DIM); % summed square

if 1; %flag_implicit_unbiased_estimation; 	% allways for SEM
    n1 	= max(n-1,0);			% in case of n=0 and n=1, the (biased) variance, STD and STE are INF
else
    n1	= n;
end;
y = sqrt(y./(n.*n1));	% normalize

