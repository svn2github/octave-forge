function [idx,score] = fss(D,cl,N,MODE)
% FSS - feature subset selection
%   the method is motivated by the max-relevance-min-redundancy (mRMR) 
%   approach [1], but instead of mutual information partial correlation 
%   is used.
%    
%  [idx,score] = fss(D,cl,MODE) 
%    
% D 	data - each column represents a feature 
% cl	classlabel   
% Mode 	'Pearson' [default] correlation
%	'rank' correlation 
%
% score score of the feature
% idx	ranking of the feature    
%       [tmp,idx]=sort(-score)
%
% REFERENCES:
% [1] Peng, H.C., Long, F., and Ding, C., 
%   Feature selection based on mutual information: criteria of max-dependency, max-relevance, and min-redundancy, 
%   IEEE Transactions on Pattern Analysis and Machine Intelligence, 
%   Vol. 27, No. 8, pp.1226-1238, 2005.


%	$Id$
%	Copyright (C) 2009 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/


%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; If not, see <http://www.gnu.org/licenses/>.


if nargin<3, 
	MODE = []; 
	N = [];
elseif ischar(N)
	MODE = N; 
	N = [];	
elseif nargin<4,
	MODE = [];	
end; 

if isempty(N) N = size(D,2); end
score = repmat(NaN,1,size(D,2));

for k=1:N,
	f = isnan(score);
	r = partcorrcoef(cl,D(:,f),D(:,~f),MODE);
	[s,ix] = max(sumsq(r,1));
	f = find(f);
	idx(k) = f(ix);
	score(idx(k)) = s;
end; 	


