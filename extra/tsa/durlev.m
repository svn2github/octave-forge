function [MX,res,arg3] = durlev(AutoCov);
% function  [AR,RC,PE] = durlev(ACF);
% function  [MX,PE] = durlev(ACF);
% estimates AR(p) model parameter by solving the
% Yule-Walker with the Durbin-Levinson recursion
% for multiple channels
%  INPUT:
% ACF	Autocorrelation function from lag=[0:p]
%
%  OUTPUT
% AR    autoregressive model parameter	
% RC    reflection coefficients (= -PARCOR coefficients)
% PE    remaining error variance
% MX    transformation matrix between ARP and RC (Attention: needs O(p^2) memory)
%        AR(:,K) = MX(:,K*(K-1)/2+(1:K));
%        RC(:,K) = MX(:,(1:K).*(2:K+1)/2);
%
% All input and output parameters are organized in rows, one row 
% corresponds to the parameters of one channel
%
% see also ACOVF ACORF AR2RC RC2AR LATTICE
% 
% REFERENCES:
%  Levinson N. (1947) "The Wiener RMS(root-mean-square) error criterion in filter design and prediction." J. Math. Phys., 25, pp.261-278.
%  Durbin J. (1960) "The fitting of time series models." Rev. Int. Stat. Inst. vol 28., pp 233-244.
%  P.J. Brockwell and R. A. Davis "Time Series: Theory and Methods", 2nd ed. Springer, 1991.
%  S. Haykin "Adaptive Filter Theory" 3rd ed. Prentice Hall, 1996.
%  M.B. Priestley "Spectral Analysis and Time Series" Academic Press, 1981. 
%  W.S. Wei "Time Series Analysis" Addison Wesley, 1990.

%	Version 2.71
%	last revision 16.02.2001
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


% Inititialization
[lr,lc]=size(AutoCov);

res=[AutoCov(:,1) zeros(lr,lc-1)];
d=zeros(lr,1);

if nargout<3         % needs O(p^2) memory 
        MX=zeros(lr,lc*(lc-1)/2);   
        idx=0;
        
        % Durbin-Levinson Algorithm
        for K=1:lc-1,
                %idx=K*(K-1)/2;  %see below
                % for L=1:lr, d(L)=arp(L,1:K-1)*transpose(AutoCov(L,K:-1:2));end;  % Matlab 4.x, Octave
                % d=sum(arp(:,1:K-1).*AutoCov(:,K:-1:2),2);              % Matlab 5.x
                MX(:,idx+K)=(AutoCov(:,K+1)-d)./res(:,K);
                %rc(:,K)=arp(:,K);
                if K>1   %for compatibility with OCTAVE 2.0.13
                        MX(:,idx+(1:K-1))=MX(:,(K-2)*(K-1)/2+(1:K-1))-MX(:,(idx+K)*ones(K-1,1)).*MX(:,(K-2)*(K-1)/2+(K-1:-1:1));
                end;   
                for L=1:lr, d(L)=MX(L,idx+(1:K))*(AutoCov(L,K+1:-1:2).');end; % Matlab 4.x, Octave
                % d=sum(MX(:,idx+(1:K)).*AutoCov(:,K+1:-1:2),2);              % Matlab 5.x
                res(:,K+1) = res(:,K).*(1-abs(MX(:,idx+K)).^2);
                idx=idx+K;
        end;
        %arp=MX(:,K*(K-1)/2+(1:K));
        %rc =MX(:,(1:K).*(2:K+1)/2);
        
else            % needs O(p) memory 
        
        arp=zeros(lr,lc-1);
        rc=zeros(lr,lc-1);
        
        % Durbin-Levinson Algorithm
        for K=1:lc-1,
                % for L=1:lr, d(L)=arp(L,1:K-1)*transpose(AutoCov(L,K:-1:2));end;  % Matlab 4.x, Octave
                % d=sum(arp(:,1:K-1).*AutoCov(:,K:-1:2),2);              % Matlab 5.x
                rc (:,K) = (AutoCov(:,K+1)-d)./res(:,K); % Yule-Walker
                arp(:,K) = rc(:,K);
                if K>1   %for compatibility with OCTAVE 2.0.13
                        arp(:,1:K-1)=arp(:,1:K-1)-arp(:,K*ones(K-1,1)).*arp(:,K-1:-1:1);
                end;
                for L=1:lr, d(L)=arp(L,1:K)*(AutoCov(L,K+1:-1:2).');end; % Matlab 4.x, Octave
                % d=sum(arp(:,1:K).*AutoCov(:,K+1:-1:2),2);              % Matlab 5.x
                res(:,K+1) = res(:,K).*(1-abs(arp(:,K)).^2);
        end;
        
        % assign output arguments
        arg3=res;
        res=rc;
        MX=arp;
end; %if