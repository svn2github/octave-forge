function cv=coefficient_of_variation(i,DIM)
% coefficient of variation
% FLAG_IMPLICIT_UNBIASED_ESTIM determines whether biased or unbiased
% estimates are returned;
% FLAG_IMPLICIT_SKIP_NAN determines whether NaNs are skipped or propagated.
% 
% cv=coefficient_of_variation(x [,DIM])
%  cv=std(x)/mean(x) 
%
% see also: SUMSKIPNAN, MEAN, STD
%
%   REFERENCE)S):
%   http://mathworld.wolfram.com/VariationCoefficient.html


%	Version 1.15
%	12 Mar 2002
%	Copyright (c) 1997-2002 by  Alois Schloegl
%	a.schloegl@ieee.org	

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


if nargin<2,
        DIM=[];
end;

if isempty(DIM), 
        DIM=min(find(size(i)>1));
        if isempty(DIM), DIM=1; end;
end;


[S,N] = sumskipnan(i,DIM);		% sum
M     = S./N;
i     = i - repmat(M,size(i)./size(S));		% remove mean
[S,N] = sumskipnan(i.^2,DIM);		% 
N     = max(N-1,0);

cv    = sqrt(S./N)./M;

