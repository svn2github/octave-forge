function  [AR,RC] = arcext(MX,K);
% Extract AR and RC of order P from Matrix MX
% function  [AR,RC] = arcext(MX,P);
%
%  INPUT:
% MX 	AR and RC matrix calculated by durlev 
% P 	model order (default maximum possible)
%
%  OUTPUT
% AR    autoregressive model parameter	
% RC    reflection coefficients (= -PARCOR coefficients)
%
% All input and output parameters are organized in rows, one row 
% corresponds to the parameters of one channel
%
% see also ACOVF ACORF IDURLEV PARCOR YUWA 
% 
% REFERENCES:
%  P.J. Brockwell and R. A. Davis "Time Series: Theory and Methods", 2nd ed. Springer, 1991.
%  S. Haykin "Adaptive Filter Theory" 3rd ed. Prentice Hall, 1996.
%  M.B. Priestley "Spectral Analysis and Time Series" Academic Press, 1981. 
%  W.S. Wei "Time Series Analysis" Addison Wesley, 1990.

%  Version 2.72
%  03.04.2001
%  Copyright (c) 1998-2001 by  Alois Schloegl
%  a.schloegl@ieee.org	

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

if nargin<2
        [lr,lc]=size(MX);
	K=floor(sqrt(2*lc));
end;
    
AR = MX(:,K*(K-1)/2+(1:K));
RC = MX(:,(1:K).*(2:K+1)/2);

