function sbispec(BISPEC)
% SBISPEC show BISPECTRUM 

%	Version 0.23
%	last revision 21.03.1998
%	Copyright (C) 1997, 1998 by Alois Schloegl <a.schloegl@ieee.org>

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
% License along with this library; If not, see <http://www.gnu.org/licenses/>.


[s1,s2]=size(BISPEC);
t1=(0:s1-1)/max(s1);
t2=(0:s2/2-1)/max(s2);
tmp=tril(NaN*ones(s1,s2),-1);
BISPEC=BISPEC+tmp+rot90(tmp);
BISPEC=BISPEC(1:s1/2,:);

subplot(211);
mesh(t1,t2,abs(BISPEC));
title('Bispectrum - mesh plot');

subplot(212);
contour(t1,t2,abs(BISPEC));
%contour(t1,t2,log(abs(BISPEC)));
title('Bispectrum - contour plot');
