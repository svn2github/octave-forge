function ACF=rc2ac(RC,R0)
%
% [R] = rc2ac(K,R0);
%
%
% requires TSA-tb >Ver 2.70
%
% see also ACOVF ACORF AR2RC RC2AR DURLEV AC2POLY, POLY2RC, RC2POLY, RC2AC, AC2RC, POLY2AC
% 

%	Version 2.76
%	last revision 17.12.2001
%	Copyright (c) 1996-2001 by Alois Schloegl
%	e-mail: a.schloegl@ieee.org	

% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Library General Public
% License as published by the Free Software Foundation; either
% Version 2 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Library General Public License for more details.
%
% You should have received a copy of the GNU Library General Public
% License along with this library; if not, write to the
% Free Software Foundation, Inc., 59 Temple Place - Suite 330,
% Boston, MA  02111-1307, USA.


if all(size(RC)>1,
        fprintf(2,'Error RC2AC: "K" must be a vector\n');
        return;
end;

mfilename='RC2AC';
if ~exist('rc2ar','file')
        fprintf(2,'Error %s: RC2AR.M not found. \n Download TSA toolbox from http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/tsa/\n',mfilename);
        return;
end;

[AR,RC,PE,ACF] = rc2ar(RC(:).');

if nargin>1
        ACF=ACF*R0;
end;
