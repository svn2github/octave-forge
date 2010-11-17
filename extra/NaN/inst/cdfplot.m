function [h,stats] = cdfplot(X)
% CDFPLOT plots empirical commulative distribution function
%
%   cdfplot(X)
%   h = cdfplot(X)
%   [h,stats] = cdfplot(X)
%
%  h is the handle to the cdf curve
%  stats is a struct containing various summary statistics
%      like mean, std, median, min, max, etc.
%
% see also: ecdf, median, statistics, hist2res
%
% References: 

%       $Id$
%       Copyright (C) 2009,2010 by Alois Schloegl <a.schloegl@ieee.org>
%       This function is part of the NaN-toolbox
%       http://pub.ist.ac.at/~schloegl/matlab/NaN/

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3
% of the  License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.


his = histo_mex(X(:));
cdf = cumsum(his.H,1) ./ sum(his.H,1);
ix1 = ceil ([1:2*size(his.X,1)]'/2);  
ix2 = floor([2:2*size(his.X,1)]'/2);  
hh  = plot (his.X(ix1), [0; cdf(ix2)]);

if nargout>0,
        h = hh; 
end;
if nargout>1,
        stats = hist2res(his);
        stats.median = quantile(his,.5); 
end;


