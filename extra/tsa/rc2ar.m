function [MX,res,arg3,acf] = rc2ar(rc);
% converts reflection coefficients into autoregressive parameters
% with the Durbin-Levinson recursion for multiple channels
% function  [AR,RC,PE,ACF] = rc2ar(RC);
% function  [MX,PE] = rc2ar(RC);
%
%  INPUT:
% RC    reflection coefficients
%
%  OUTPUT
% AR    autoregressive model parameter	
% RC    reflection coefficients (= -PARCOR coefficients)
% PE    remaining error variance (relative to PE(1)=1)
% MX    transformation matrix between ARP and RC (Attention: needs O(p^2) memory)
%        arp=MX(:,K*(K-1)/2+(1:K));
%        rc =MX(:,(1:K).*(2:K+1)/2);
%
% All input and output parameters are organized in rows, one row 
% corresponds to the parameters of one channel
%
% see also ACOVF ACORF DURLEV IDURLEV PARCOR YUWA 
% 
% REFERENCES:
%  P.J. Brockwell and R. A. Davis "Time Series: Theory and Methods", 2nd ed. Springer, 1991.
%  S. Haykin "Adaptive Filter Theory" 3rd ed. Prentice Hall, 1996.
%  M.B. Priestley "Spectral Analysis and Time Series" Academic Press, 1981. 
%  W.S. Wei "Time Series Analysis" Addison Wesley, 1990.

%	Version 2.90	last revision 10.04.2002
%	Copyright (c) 1996-2002 by Alois Schloegl
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


% Inititialization
[lr,lc]=size(rc);
res=[ones(lr,1) zeros(lr,lc)];
if nargout<3         % needs O(p^2) memory 
        MX=zeros(lr,lc*(lc+1)/2);   
        idx=0;
        
        % Durbin-Levinson Algorithm
        for K=1:lc,
                MX(:,idx+K)=rc(:,K);%(AutoCov(:,K+1)-d)./res(:,K);
                %rc(:,K)=arp(:,K);
                if K>1   %for compatibility with OCTAVE 2.0.13
                        MX(:,idx+(1:K-1))=MX(:,(K-2)*(K-1)/2+(1:K-1))-MX(:,(idx+K)*ones(K-1,1)).*MX(:,(K-2)*(K-1)/2+(K-1:-1:1));
                end;   
                res(:,K+1) = res(:,K).*(1-abs(MX(:,idx+K)).^2);
                idx=idx+K;
        end;
        %arp=MX(:,K*(K-1)/2+(1:K));
        %rc =MX(:,(1:K).*(2:K+1)/2);

else            % needs O(p) memory 
        ar=zeros(lr,lc);
        acf=[ones(lr,1),zeros(lr,lc)];
        %rc=RC; %zeros(lr,lc-1);
        
        % Durbin-Levinson Algorithm
        for K=1:lc,
        	acf(:,K+1) = -sum(acf(:,K:-1:1).*ar(:,1:K),2);        
                ar(:,K) = rc(:,K);
                if K>1, %for compatibility with OCTAVE 2.0.13
                        ar(:,1:K-1) = ar(:,1:K-1) - ar(:,K*ones(K-1,1)) .* ar(:,K-1:-1:1);
                end;
                res(:,K+1) = res(:,K) .* (1-abs(ar(:,K)).^2);
        end;
        
        % assign output arguments
        arg3=res;
        res=rc;
        MX=ar;
end; %if
