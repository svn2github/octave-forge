function [ACF] = acf(Z,N);
% Autocorrelation function
% [ACF] = acorf(Z,N);
%
% Input:	Z    Signal 
%		N    # of coefficients
% Output:	ACF autocorrelation function

%	Version 2.45
%	last revision 28.07.1998
%	Copyright (c) 1997-98 by Alois Schloegl
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


[lr,lc]=size(Z);
if (lc==1)
        Z=Z.';
elseif lc<N 
        if lr<N 
                fprintf(2,'Error ACF: #cols in Z must be larger than N\n');        
        else
                fprintf(2,'Warning ACF: Z should be in row order\n');        
                Z=Z.'; 
        end;
end;

ACF=acorf(Z,N);
fprintf(2,'please use in future function ACORF instead of ACF\n');