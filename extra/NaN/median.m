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

%	$Revision$
%	$Id$
%	Copyright (C) 2000-2003 by  Alois Schloegl <a.schloegl@ieee.org>	

% check dimension of x
sz=size(x);
if length(sz)>2,
        fprintf('Error MEDIAN: data must have no more than 2 dimensions\n');	
	return;        
end;

% find the dimension for median
if nargin<2,
        DIM=min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

% number of valid elements
if flag_implicit_skip_nan,	% default
	n = sumskipnan(~isnan(x),DIM);   % make it compatible to 2.0.17
else				%  
	n = sumskipnan(ones(size(x)),DIM);
end;
        
if 0; %~exist('OCTAVE_VERSION'),
        [x,ix] = sort(x,DIM); % this relays on the sort order of IEEE754 inf < nan
else        
	if ~all(isnan(sort([3,4,NaN,3,4,NaN]))==[0,0,0,0,1,1]),  %~exist('OCTAVE_VERSION'),
    		warning('MEDIAN: sort does not handle NaN, workaround with bad performance necessary');
    		for k1=1:size(x,1),
            		for k2=1:size(x,2),	% needed for 2.0.17 
                    		if isnan(x(k1,k2)), 
                            		x(k1,k2) = inf;
                    		end;
			end;
                end;
        end;
	
	if DIM==1,
                [x,ix] = sort([x ; NaN*ones(1,sz(2))]);
        elseif DIM==2,
                [x,ix] = sort([x'; NaN*ones(1,sz(1))]);
        else
                fprintf('Error MEDIAN: DIM argument should be 1 or 2\n');	
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

