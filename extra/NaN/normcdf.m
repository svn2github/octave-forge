function p = normcdf(x,m,s);
% Normal cumulative distribtion function
%
% cdf = normcdf(x,m,s);
%
% Computes the CDF of a the normal distribution 
%    with mean m and standard deviation s
%    default: m=0; s=1;
%
% see also: NORMPDF, NORMINV 

% Reference(s):

%	Version 1.28   Date: 23.Sep.2002
%	Copyright (c) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>	

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


if nargin==1,
        m=0; s=1;
elseif nargin==2,
        s=1;
end;        

% allocate output memory and check size of arguments
z = (x-m)./s;			% check size of arguments

p = (1 + erf(z/sqrt(2)))/2;

p(isnan(x) | isnan(m) | isnan(s) | (s<0)) = nan;

p(z==+inf) = 1;

p(z==-inf) = 0;

p((x<m) &(s==0)) = 0;

p((x==m)&(s==0)) = 0.5;

p((x>m) &(s==0)) = 1;





