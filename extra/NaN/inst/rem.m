function [z,e] = rem(x,y)
% REM calculates remainder of X / Y  
%
%     z = x - y * fix(x/y);
%     e = eps * fix(x/y);
%
%    [z,e] = REM(X,Y)
%	z is the remainder of X / Y
%	e is the error tolerance, for checking the accuracy
%		z(e > abs(y)) is not defined 
%
% 	z has always the same sign than x	
% 
% see also: MOD

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
%    along with this program; If not, see <http://www.gnu.org/licenses/>.

%       $Id$
%	Copyright (C) 2004,2009 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://biosig-consulting.com/matlab/NaN/


s = warning;
warning('off');

if ((numel(x)~=1) && (numel(y)~=1) && any(size(x)~=size(y))) 
        error('size of input arguments do not fit.');
end;

t = fix(x./y);
z = x - y.*t;

if numel(x)==1,
	z(~t) = x;		% remainder is x if y = inf
else
	z(~t) = x(~t);		% remainder is x if y = inf
end;
z(repmat(~y,size(z)./size(y))) = 0;	% remainder must be 0 if y==0

warning(s);			% reset warning status

if nargout > 1,
        e = (abs(t)*eps);	% error interval 
        %z(e > abs(y)) = NaN;	% uncertainty of rounding error to large
end;



