function [ACF,WACF] = acovf(Z,KMAX,Mode,Mode2);
% Autocorrelation function (not normalized) for multiple channels
% [ACF,WACF] = acovf(Z,N);
% Handles missing values (NaN). Default is setting missing values to zero;
% If missing values should be set to the mean (or the median), the mean ( or median) 
% should be removed in advance.
%        [ACF] = acovf(Z-nanmean(Z),KMAX);
% Alternatively, the missing values can be set to the desired values 
%        Z(isnan(Z))=mean(Z(~isnan(Z))); 
%        [ACF,WACF] = acovf(Z,KMAX);
%
% Input:	Z    Signal (one channel per row);
%		N+1  # of coefficients
% Output:	ACF  autocovariance function
%		WACF weighted autocorrelation function
%
% REFERENCES:
%  A.V. Oppenheim and R.W. Schafer, Digital Signal Processing, Prentice-Hall, 1975.
%  S. Haykin "Adaptive Filter Theory" 3ed. Prentice Hall, 1996.
%  M.B. Priestley "Spectral Analysis and Time Series" Academic Press, 1981. 
%  W.S. Wei "Time Series Analysis" Addison Wesley, 1990.
%  J.S. Bendat and A.G.Persol "Random Data: Analysis and Measurement procedures", Wiley, 1986.

%	Version 2.80
%	last revision 03.01.2002
%	Copyright (c) 1996-2002 by Alois Schloegl
%	e-mail: a.schloegl@ieee.org	

% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Library General Public
% License as published by the Free Software Foundation; either
% version 2 of the License, or (at your option) any later version.
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


if nargin<3, Mode='biased'; end;

[lr,lc]=size(Z);

MISSES=sum(isnan(Z)')';
if any(MISSES); % missing values
        Z(isnan(Z))=0;
else
        MISSES=[];
end;

if (nargin == 1) KMAX = lc-1; 
elseif (KMAX >= lc-1) KMAX = lc-1;
end;

ACF=zeros(lr,KMAX+1);

if nargin>3,		% for testing, use arg4 for comparing the methods,
elseif 	(KMAX*KMAX > lc*log(lc)) & isempty(MISSES);	Mode2=1;
elseif 	exist('xcorr','file')    & isempty(MISSES);	Mode2=2;
elseif 	(10*KMAX > lc);		Mode2=3;
else	Mode2=4;
end;
        
% the following algorithms gve equivalent results, however, the computational effort is different,
% depending on lr,lc and KMAX, a different algorithm is most efficient.
if Mode2==1;%,KMAX*KMAX > lc*log(lc);        % O(n.logn)+O(K�)
        tmp = fft(Z',2^nextpow2(size(Z,2))*2);
        tmp = ifft(tmp.*conj(tmp));
        ACF = tmp(1:KMAX+1,:)'; 
        if ~any(any(imag(Z))), ACF=real(ACF); end; % should not be neccessary, unfortunately it is.
elseif Mode2==2; %,exist('xcorr','file');
        for L=1:lr,
	        tmp = xcorr(Z(L,:), KMAX);
        	ACF(L,:) = tmp(KMAX+1+(0:KMAX));
	end;
elseif Mode2==3; %(10*KMAX > lc)   % O(n*K)     % use fast Built-in filter function
        for L=1:lr,
                acf = filter(Z(L,lc:-1:1),1,Z(L,:));
                ACF(L,:)= acf(lc:-1:lc-KMAX);
        end;    
elseif  Mode2==4;%
	%elseif 1         % O(n*K)
        for L=1:lr,
                for K = 0:KMAX, 
                        ACF(L,K+1) = Z(L,1:lc-K) * Z(L,1+K:lc)';
                end;
        end;    
end;

if strcmp(Mode,'biased')
	if isempty(MISSES),
	        ACF=ACF/lc;
	else
	        ACF=ACF./((lc-MISSES)*ones(1,KMAX+1));
	end;
elseif strcmp(Mode,'unbiased')
	if isempty(MISSES),
	        ACF=ACF./(ones(lr,1)*(lc:-1:lc-KMAX));
	else
	        ACF=ACF./((lc-MISSES)*ones(1,KMAX+1) - ones(lr,1)*(0:KMAX));
	end;
end;


if nargout>2
        WACF = ACF ./ ACF(:,ones(1,KMAX+1)) .* ((lc(ones(lr,1))-MISSES)*ones(1,KMAX+1));
end;

