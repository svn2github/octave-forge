function [y,M]=sem(x,DIM)
% SEM calculates the standard error of the mean
% 
% [SE,M] = SEM(x [, DIM])
%   calculates the standard error (SE) in dimension DIM
%   the default DIM is the first non-single dimension
%   M returns the mean. 
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

%    Copyright (C) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>	


% check input arguments 
if nargin==1,
        DIM=0;
elseif nargin==2,
        if ~isnumeric(DIM),
                DIM=0;
        end
else
        fprintf(2,'Error SEM: invalid number of arguments\n usage: v=var(x [,DIM])\n');
end
if ~DIM;
        DIM=flag_implicit_dimension;
end;	
if ~DIM;
        DIM=min(find(size(x)>1));
        if isempty(DIM), DIM=1; end;
end;

[Y,N,SSQ] = sumskipnan(x,DIM);
y = sqrt((SSQ-Y.*Y./N)./(N.*max(N-1,0))); 
if nargout>1,
        M = Y./N;
end;
