function [y] = nanstd(i,DIM)
% NANSTD same as STD but ignores NaN's. 
% NANSTD is OBSOLETE; use NaN/STD instead. NANSTD is included 
%    to fix a bug in some other versions. 
%
% Y = nanstd(x [,DIM])
% 
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

%	$Revision$
%	$Id$
%    Copyright (C) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>	


if nargin>1
        [s,n,y] = sumskipnan(i,DIM);
else
        [s,n,y] = sumskipnan(i);
end;

m = s./n;	% mean
y = (y-s.*m);   % n * (summed squares with removed mean)

n = max(n-1,0);	
y = sqrt(y./n);	% normalize


