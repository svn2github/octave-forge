function r = rankcorr(x,y)
% SPEARMAN Spearman's rank correlation coefficient.
% This function is replaced by CORRCOEF. 
% Significance test and confidence intervals can be obtained from CORRCOEF, too. 
%
% [R,p,ci1,ci2] = CORRCOEF(x, [y, ] 'Rank');
%
% see also: CORRCOEF

%    Version 1.25  Date: 15 Aug 2002
%    Copyright (C) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>	

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


fprintf(2,'RANKCORR might become obsolete; use CORRCOEF(...,''Rank'') instead\n');

if nargin < 2
   r = corrcoef(x,'Rank');
else
   r = corrcoef(x,y,'Rank');
end