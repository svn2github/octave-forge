function [ACF,rc,ar,PE,ACFsd]=invest0(Z,Pmax);
% First Investigation of a signal (time series)
% [ACOVF,PACF,AR,E,ACFsd]=invest0(Y,Pmax);
%
% Y	time series
% Pmax	maximal order (optional)
%
% ACOVF	Autocovariance 
% ACF	Autocorrelation
% PACF	Partial Autocorrelation
% AR    Autoregressive Parameter for order Pmax-1
% E	Error function E(p)

%	Version 2.50
%	last revision 03.07.1998
%	Copyright (c) 1996-1998 by Alois Schloegl
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

[lr,nc]=size(Z);
if nargin<2 Pmax=min([100 nc/3]); end;
M=min(Pmax+1,nc-1);
lc=M+1;
% Inititialization
ACF=zeros(lr,M+1);
for L=1:lr,
	ACF(L,1) = Z(L,1:lc) * Z(L,1:lc)';
end;
[lr,lc]=size(ACF);
ar=zeros(lr,M);
rc=zeros(lr,M);
PE=ACF;	
d=zeros(lr,1);

% Durbin-Levinson Algorithm
for K=1:lc-1,
          % Matlab 4.x, Octave
        for L=1:lr, 
                d(L)=ar(L,1:K-1)*ACF(L,K:-1:2)';
		ACF(L,K+1) = Z(L,1:lc-K) * Z(L,1+K:lc)';
        end;
              % Matlab 5.x
        % ACF(:,K+1) = sum(Z(:,1:lc-K).*Z(:,1+K:lc),2);
        % d=sum(ar(:,1:K-1).*ACF(:,K:-1:2),2);        
        
        ar(:,K)=(ACF(:,K+1)-d)./PE(:,K);
        rc(:,K)=ar(:,K);
        PE(:,K+1) = PE(:,K).*(1-ar(:,K).*ar(:,K));
        ar(:,1:K-1)=ar(:,1:K-1)-ar(:,K*ones(K-1,1)).*ar(:,K-1:-1:1);
end;

if nargout > 4
        ACFsd=ones(1,M)*sqrt(1/nc);
end;



                    
                    
                    
                    
                    
                    