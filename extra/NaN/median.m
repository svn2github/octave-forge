function [y]=median(x,DIM)
% MEDIAN data elements, 
% [y]=median(x [,DIM])
%
% DIM	dimension
%	1: mean of columns
%	2: mean of rows
% 	N: mean of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - accepts dimension argument like in Matlab in Octave, too. 
% - compatible to Matlab and Octave 
%
% see also: SUMSKIPNAN
 
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

%	Version 1.23;	07 Jun 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>	

% check dimension of x
sz=size(x);
if length(sz)>2,
        fprintf('Error MEDIAN: data must have no more than 2 dimensions\n');	
	return;        
end;

% find the dimension for median
if nargin<2
        DIM=min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

% number of valid elements
n = sum(~isnan(x),DIM);
        
if all(sort([3,4,NaN,3,4,NaN])==[3,3,4,4,NaN,NaN]),  %~exist('OCTAVE_VERSION'),
        [x,ix] = sort(x,DIM); % this relays on the sort order of IEEE754 inf < nan
else        
        if DIM==1,
                x(isnan(x)) = inf;
                [x,ix] = sort([x;inf*ones(1,sz(2))]);
        elseif DIM==2,
                x(isnan(x)) = inf;
                [x,ix] = sort([x';inf*ones(1,sz(1))]);
        else
                fprintf('Warning MEDIAN: DIM argument should be 1 or 2\n');	
                return;        
        end;
end;
        
y = zeros(size(n));
for k = 1:prod(size(y)),
        if n(k)==0,
                y(k) = nan;
        elseif ~rem(n(k),2),
                y(k) = (x(n(k)/2,k) + x(n(k)/2+1,k)) / 2;
        elseif rem(n(k),2),
                y(k) = x((n(k)+1)/2,k);
        end;
end;

