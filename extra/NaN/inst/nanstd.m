function [y] = nanstd(i,FLAG,DIM)
% NANSTD same as STD but ignores NaN's. 
% NANSTD is OBSOLETE; use NaN/STD instead. NANSTD is included 
%    to fix a bug in alternative implementations and to 
%    provide some compatibility. 
%
% Y = nanstd(x, FLAG, [,DIM])
% 
% x     data
% FLAG  0: [default] normalizes with (N-1), N = sample size
% FLAG  1: normalizes with N, N = sample size
% DIM	dimension
%	1 sum of columns
%	2 sum of rows
%	default or []: first DIMENSION with more than 1 element
% Y	resulting standard deviation
% 
% see also: SUM, SUMSKIPNAN, NANSUM, STD

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

%    Copyright (C) 2000-2003,2006 by Alois Schloegl <a.schloegl@ieee.org>	
%	$Id$


if nargin<2,
	FLAG = 0; 
end;
	
if nargin<3,
	DIM = []; 
end;
if isempty(DIM), 
        DIM=min(find(size(i)>1));
        if isempty(DIM), DIM=1; end;
end;

[y,n] = sumskipnan(center(i,DIM).^2,DIM);

if (FLAG~=1)
        y = sqrt(y./max(n-1,0));	% normalize with N-1
else
        y = sqrt(y)./n;	% normalize with N
end;

