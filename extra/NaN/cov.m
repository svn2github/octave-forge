function CC = cov(X,Y);
% COV covariance matrix
% X and Y can contain missing values encoded with NaN.
% NaN's are skipped, NaN do not result in a NaN output. 
% The output gives NaN only if there are insufficient input data
%
% C = COV(X);
%      calculates the (auto-)correlation matrix of X
% C = COV(X,Y);
%      calculates the crosscorrelation between X and Y
%
% 	C is the scaled by (N-1). Hence, C is the best unbiased estimator. 
%
% see also: COVM, SUMSKIPNAN
%
% REFERENCES:
% http://mathworld.wolfram.com/Covariance.html


%	Copyright (C) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>	


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


if nargin>1,
	CC = covm(X,Y,'D');	
elseif nargin==1,        
	CC = covm(X,'D');	
else
	fprintf(2,'Error COV: invalid number of arguments\n');
end;
