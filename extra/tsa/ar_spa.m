function  [w,A,B,R,P,F,ip] = ar_spa(ARP,nhz,E);
% Spectral analysis of AR-polynomial
% function  [w,A] = ar_spa(ARP,fs,E);
%
%  INPUT:
% ARP   autoregressive parameters
% fs    sampling rate, gives w and B in [Hz], if not given in radians 
% E     noise level (root mean square),  gives A and F in units of E, if not given as relative amplitude
%
%  OUTPUT
% w	center frequency (in radians)
% A     Amplitude
% B     bandwidth
% R	residual
% P	poles
% ip	number of complex conjugate poles
% real(F)     	power, absolute values are obtained by multiplying with noise variance E(p+1) 
% imag(F)	assymetry, - " -
%
% All input and output parameters are organized in rows, one row 
% corresponds to the parameters of one channel
%
% see also ACOVF ACORF DURLEV IDURLEV PARCOR YUWA 
% 
% REFERENCES:
% Zetterberg L.H. (1969) Estimation of parameter for linear difference equation with application to EEG analysis. Math. Biosci., 5, 227-275. 
% Isaksson A. and Wennberg, A. (1975) Visual evaluation and computer analysis of the EEG - A comparison. Electroenceph. clin. Neurophysiol., 38: 79-86.
% G. Florian and G. Pfurtscheller (1994) Autoregressive model based spectral analysis with application to EEG. IIG - Report Series, University of Technolgy Graz, Austria.

%	Version 2.70
%	last revision 14.02.2001
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

if nargout >5  
%        fprintf(2,'Warning %s: Amplitude might be errornous\n',mfilename); 
end;

[NTR,pp]=size(ARP);
%B=NaN;

R=zeros(size(ARP));
P=zeros(size(ARP));
w=zeros(size(ARP));
A=zeros(size(ARP));
B=zeros(size(ARP));
F=zeros(size(ARP));

for k=1:NTR, %if ~mod(k,100),k, end;
	[r,p,tmp] = residue(1,[1 -ARP(k,:)]);
	[tmp,idx] = sort(-abs(r));   
	R(k,:) = r(idx)';		% Residual, 
   	P(k,:) = p(idx)';		% Poles
   	%r(k,:)=roots([1 -ARP(k,:)])';
   	w(k,:) = angle(p(idx)');	% center frequency (in [radians])
   	A(k,:) = 1./polyval([1 -ARP(k,:)],exp(i*w(k,:)));	% Amplitude 
   	%A(k,:) = freqz(1,[1 -ARP(k,:)],w(k,:));	% Amplitude 
   	%A2(k,:) = abs(r)'./abs(exp(i*w(k,:))-r');   % Amplitude
   	B(k,:) = -log(abs(p(idx)'));  %Bandwidth
           
        if nargout >5  
           % Effizienz (Rechengeschwindigkeit) koennte eventuell noch gesteigert werden
        F(k,:) = (1+sign(imag(r(idx)')))./(polyval([-ARP(k,pp-1:-1:1).*(1:pp-1) pp],1./p(idx).').*polyval([-ARP(k,pp:-1:1) 1],p(idx).'));        
	end;

        if 0;
	        x1(k,:) = polyval([-ARP(k,pp-1:-1:1).*(1:pp-1) pp],1./p(idx).');
	        x2(k,:) = polyval([-ARP(k,pp:-1:1) 1],p(idx).');
		F(k,:) = (1+(imag(R)~=0))./(x1(k,:).*x2(k,:));        
        elseif 0 %for l=1:pp,
                if imag(R(k,l))==0,
                	F(k,l) = 1/(x1(k,l)*x2(k,l));        
                else,
                        %xn = (x1(k,l)*x2(k,l));
                        F(k,l) = 2/(x1(k,l)*x2(k,l));
                end;
        end;	
end;
if nargin>1
        w=w*nhz/2/pi;
        B=B*nhz/2/pi;
end;
if nargin>2
        A=A.*sqrt(E(:,ones(1,pp)));
        F=F.*E(:,ones(1,pp));
end;

ip=imag(R)~=0; return;

np(:,1) = sum(imag(R')==0)';   % number of real poles
np(:,2) = pp-np(:,1);		% number of imaginary poles


