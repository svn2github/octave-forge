function [ARF,RCF,PE,DC,varargout] = mvar(Y, Pmax, Mode);
% MVAR estimates Multi-Variate AutoRegressive model parameters
% Several estimation algorithms are implemented, all estimators 
% can handle data with missing values encoded as NaNs.  
%
% 	[AR,RC,PE] = mvar(Y, p);
% 	[AR,RC,PE] = mvar(Y, p, Mode);
%
% INPUT:
%  Y	 Multivariate data series 
%  p     Model order
%  Mode	 determines estimation algorithm 
%
% OUTPUT:
%  AR    multivariate autoregressive model parameter
%  RC    reflection coefficients (= -PARCOR coefficients)
%  PE    remaining error variance
%
% All input and output parameters are organized in columns, one column 
% corresponds to the parameters of one channel.
%
% Mode determines estimation algorithm. 
%  1:  Correlation Function Estimation method using biased correlation function estimation method
%   		also called the "multichannel Yule-Walker" [1,2] 
%  6:  Correlation Function Estimation method using unbiased correlation function estimation method
%
%  2:  Partial Correlation Estimation: Vieira-Morf [2] using unbiased covariance estimates.
%               In [1] this mode was used and (incorrectly) denominated as Nutall-Strand. 
%		Its the DEFAULT mode; according to [1] it provides the most accurate estimates.
%  5:  Partial Correlation Estimation: Vieira-Morf [2] using biased covariance estimates.
%		Yields similar results than Mode=2;
%
%  3:  Partial Correlation Estimation: Nutall-Strand [2] (biased correlation function)
%  7:  Partial Correlation Estimation: Nutall-Strand [2] (unbiased correlation function)
%
%
% REFERENCES:
%  [1] A. Schl\"ogl, Comparison of Multivariate Autoregressive Estimators.
%       Signal processing, Elsevier B.V. (in press). 
%       available at http://dx.doi.org/doi:10.1016/j.sigpro.2005.11.007
%  [2] S.L. Marple "Digital Spectral Analysis with Applications" Prentice Hall, 1987.
%
%
% A multivariate inverse filter can be realized with 
%   [AR,RC,PE] = mvar(Y,P);
%   e = mvfilter([eye(size(AR,1)),-AR],eye(size(AR,1)),Y);
%  
% see also: MVFILTER, MVFREQZ, COVM, SUMSKIPNAN, ARFIT2

%	$Revision$
%	$Id$
%	Copyright (C) 1996-2005 by Alois Schloegl <a.schloegl@ieee.org>	
%       This is part of the TSA-toolbox. See also 
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/tsa/
%       http://octave.sourceforge.net/
%       http://biosig.sourceforge.net/

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
[N,M] = size(Y);

if nargin<2, 
        Pmax=max([N,M])-1;
end;

M2 = N+1;

if iscell(Y)
        Pmax = min(max(N ,M ),Pmax);
        C    = Y;
end;
if nargin<3,
        % according to [1], this is the best algorithm 
        Mode=2;
end;

[C(:,1:M),n] = covm(Y,'M');
PE(:,1:M)  = C(:,1:M)./n;

if Mode==0;  % this method is broken
        fprintf('Warning MVAR: Mode=0 is broken.\n')        
        C(:,1:M) = C(:,1:M)/N;
        F = Y;
        B = Y;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        for K=1:Pmax,
                [D,n] = covm(Y(K+1:N,:),Y(1:N-K,:),'M');
	        D = D/N;
                ARF(:,K*M+(1-M:0)) = D/PEB;	
                ARB(:,K*M+(1-M:0)) = D'/PEF;	
                
                tmp        = F(K+1:N,:) - B(1:N-K,:)*ARF(:,K*M+(1-M:0))';
                B(1:N-K,:) = B(1:N-K,:) - F(K+1:N,:)*ARB(:,K*M+(1-M:0))';
                F(K+1:N,:) = tmp;
                
                for L = 1:K-1,
                        tmp      = ARF(:,L*M+(1-M:0))   - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))   = tmp;
                end;
                
                RCF(:,K*M+(1-M:0)) = ARF(:,K*M+(1-M:0));
                RCB(:,K*M+(1-M:0)) = ARB(:,K*M+(1-M:0));
                
                PEF = [eye(M) - ARF(:,K*M+(1-M:0))*ARB(:,K*M+(1-M:0))]*PEF;
                PEB = [eye(M) - ARB(:,K*M+(1-M:0))*ARF(:,K*M+(1-M:0))]*PEB;
                PE(:,K*M+(1:M)) = PEF;        
        end;

        
elseif Mode==1, %%%%% Levinson-Wiggens-Robinson (LWR) algorithm using biased correlation function
	% ===== In [1,2] this algorithm is denoted "Multichannel Yule-Walker" ===== %
        C(:,1:M) = C(:,1:M)/N;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        
        for K=1:Pmax,
                [C(:,K*M+(1:M)),n] = covm(Y(K+1:N,:),Y(1:N-K,:),'M');
                C(:,K*M+(1:M)) = C(:,K*M+(1:M))/N;

                D = C(:,K*M+(1:M));
                for L = 1:K-1,
                        D = D - ARF(:,L*M+(1-M:0))*C(:,(K-L)*M+(1:M));
                end;
                ARF(:,K*M+(1-M:0)) = D / PEB;	
                ARB(:,K*M+(1-M:0)) = D'/ PEF;	
                for L = 1:K-1,
                        tmp                    = ARF(:,L*M+(1-M:0)) - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))     = tmp;
                end;
                
                RCF(:,K*M+(1-M:0)) = ARF(:,K*M+(1-M:0));
                RCB(:,K*M+(1-M:0)) = ARB(:,K*M+(1-M:0));
                
                PEF = [eye(M) - ARF(:,K*M+(1-M:0))*ARB(:,K*M+(1-M:0))]*PEF;
                PEB = [eye(M) - ARB(:,K*M+(1-M:0))*ARF(:,K*M+(1-M:0))]*PEB;
                PE(:,K*M+(1:M)) = PEF;        
        end;

        
elseif Mode==6, %%%%% Levinson-Wiggens-Robinson (LWR) algorithm using unbiased correlation function
        C(:,1:M) = C(:,1:M)/N;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        
        for K = 1:Pmax,
                [C(:,K*M+(1:M)),n] = covm(Y(K+1:N,:),Y(1:N-K,:),'M');
                C(:,K*M+(1:M)) = C(:,K*M+(1:M))./n;
		%C{K+1} = C{K+1}/N;

                D = C(:,K*M+(1:M));
                for L = 1:K-1,
                        D = D - ARF(:,L*M+(1-M:0))*C(:,(K-L)*M+(1:M));
                end;
                ARF(:,K*M+(1-M:0)) = D / PEB;	
                ARB(:,K*M+(1-M:0)) = D'/ PEF;	
                for L = 1:K-1,
                        tmp      = ARF(:,L*M+(1-M:0))   - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))   = tmp;
                end;
                
                RCF(:,K*M+(1-M:0)) = ARF(:,K*M+(1-M:0));
                RCB(:,K*M+(1-M:0)) = ARB(:,K*M+(1-M:0));
                
                PEF = [eye(M) - ARF(:,K*M+(1-M:0))*ARB(:,K*M+(1-M:0))]*PEF;
                PEB = [eye(M) - ARB(:,K*M+(1-M:0))*ARF(:,K*M+(1-M:0))]*PEB;
                PE(:,K*M+(1:M)) = PEF;        
        end;
        

elseif Mode==2 %%%%% Partial Correlation Estimation: Vieira-Morf Method [2] with unbiased covariance estimation
	%===== In [1] this algorithm is denoted "Nutall-Strand with unbiased covariance" =====%
        C(:,1:M) = C(:,1:M)/N;
        F = Y;
        B = Y;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        for K = 1:Pmax,
                [D,n]	= covm(F(K+1:N,:),B(1:N-K,:),'M');
                D = D./n;

		ARF(:,K*M+(1-M:0)) = D / PEB;	
                ARB(:,K*M+(1-M:0)) = D'/ PEF;	
                
                tmp        = F(K+1:N,:) - B(1:N-K,:)*ARF(:,K*M+(1-M:0)).';
                B(1:N-K,:) = B(1:N-K,:) - F(K+1:N,:)*ARB(:,K*M+(1-M:0)).';
                F(K+1:N,:) = tmp;
                
                for L = 1:K-1,
                        tmp      = ARF(:,L*M+(1-M:0))   - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))   = tmp;
                end;
                
                RCF(:,K*M+(1-M:0)) = ARF(:,K*M+(1-M:0));
                RCB(:,K*M+(1-M:0)) = ARB(:,K*M+(1-M:0));
                
                [PEF,n] = covm(F(K+1:N,:),F(K+1:N,:),'M');
                PEF = PEF./n;

		[PEB,n] = covm(B(1:N-K,:),B(1:N-K,:),'M');
                PEB = PEB./n;

                PE(:,K*M+(1:M)) = PEF;        
        end;
        

elseif Mode==5 %%%%% Partial Correlation Estimation: Vieira-Morf Method [2] with biased covariance estimation
	%===== In [1] this algorithm is denoted "Nutall-Strand with biased covariance" ===== %
        %C{1} = C{1}/N;
        F = Y;
        B = Y;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        for K=1:Pmax,
                [D,n]  = covm(F(K+1:N,:),B(1:N-K,:),'M');
                %D=D/N;

                ARF(:,K*M+(1-M:0)) = D / PEB;	
                ARB(:,K*M+(1-M:0)) = D'/ PEF;	
                
                tmp        = F(K+1:N,:) - B(1:N-K,:)*ARF(:,K*M+(1-M:0)).';
                B(1:N-K,:) = B(1:N-K,:) - F(K+1:N,:)*ARB(:,K*M+(1-M:0)).';
                F(K+1:N,:) = tmp;
                
                for L = 1:K-1,
                        tmp      = ARF(:,L*M+(1-M:0))   - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))   = tmp;
                end;
                
                RCF(:,K*M+(1-M:0)) = ARF(:,K*M+(1-M:0));
                RCB(:,K*M+(1-M:0)) = ARB(:,K*M+(1-M:0));
                
                [PEB,n] = covm(B(1:N-K,:),B(1:N-K,:),'M');
                %PEB = D/N;

                [PEF,n] = covm(F(K+1:N,:),F(K+1:N,:),'M');
                %PEF = D/N;

                PE(:,K*M+(1:M)) = PEF;        
        end;

        
elseif Mode==3 %%%%% Partial Correlation Estimation: Nutall-Strand Method [2] with biased covariance estimation
        C(:,1:M) = C(:,1:M)/N;
        F = Y;
        B = Y;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        for K=1:Pmax,
                [D, n]  = covm(F(K+1:N,:),B(1:N-K,:),'M');
                D = D./N;

                ARF(:,K*M+(1-M:0)) = 2*D / (PEB+PEF);	
                ARB(:,K*M+(1-M:0)) = 2*D'/ (PEF+PEB);	
                
                tmp        = F(K+1:N,:) - B(1:N-K,:)*ARF(:,K*M+(1-M:0)).';
                B(1:N-K,:) = B(1:N-K,:) - F(K+1:N,:)*ARB(:,K*M+(1-M:0)).';
                F(K+1:N,:) = tmp;
                
                for L = 1:K-1,
                        tmp      = ARF(:,L*M+(1-M:0))   - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))   = tmp;
                end;
                
                %RCF{K} = ARF{K};
                RCF = ARF(:,K*M+(1-M:0));
                
                [PEF,n] = covm(F(K+1:N,:),F(K+1:N,:),'M');
                PEF = PEF./N;

		[PEB,n] = covm(B(1:N-K,:),B(1:N-K,:),'M');
                PEB = PEB./N;

                %PE{K+1} = PEF;        
                PE(:,K*M+(1:M)) = PEF;        
        end;

        
elseif Mode==7 %%%%% Partial Correlation Estimation: Nutall-Strand Method [2] with unbiased covariance estimation 
        C(:,1:M) = C(:,1:M)/N;
        F = Y;
        B = Y;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        for K=1:Pmax,
                [D,n]  = covm(F(K+1:N,:),B(1:N-K,:),'M');
                D = D./n;

                ARF(:,K*M+(1-M:0)) = 2*D / (PEB+PEF);	
                ARB(:,K*M+(1-M:0)) = 2*D'/ (PEF+PEB);	
                
                tmp        = F(K+1:N,:) - B(1:N-K,:)*ARF(:,K*M+(1-M:0)).';
                B(1:N-K,:) = B(1:N-K,:) - F(K+1:N,:)*ARB(:,K*M+(1-M:0)).';
                F(K+1:N,:) = tmp;
                
                for L = 1:K-1,
                        tmp      = ARF(:,L*M+(1-M:0))   - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))   = tmp;
                end;
                
                %RCF{K} = ARF{K};
                RCF = ARF(:,K*M+(1-M:0));
                
                [PEF,n] = covm(F(K+1:N,:),F(K+1:N,:),'M');
                PEF = PEF./n;

                [PEB,n] = covm(B(1:N-K,:),B(1:N-K,:),'M');
                PEB = PEB./n;

                %PE{K+1} = PEF;        
                PE(:,K*M+(1:M)) = PEF;        
        end;

        
elseif Mode==4,  %%%%% Kay, not fixed yet. 
        fprintf('Warning MVAR: Mode=4 is broken.\n')        
        
        C(:,1:M) = C(:,1:M)/N;
        K = 1;
        [C(:,M+(1:M)),n] = covm(Y(2:N,:),Y(1:N-1,:));
        C(:,M+(1:M)) = C(:,M+(1:M))/N;  % biased estimate

        D = C(:,M+(1:M));
        ARF(:,1:M) = C(:,1:M)\D;
        ARB(:,1:M) = C(:,1:M)\D';
        RCF(:,1:M) = ARF(:,1:M);
        RCB(:,1:M) = ARB(:,1:M);
        PEF = C(:,1:M)*[eye(M) - ARB(:,1:M)*ARF(:,1:M)];
        PEB = C(:,1:M)*[eye(M) - ARF(:,1:M)*ARB(:,1:M)];
        
        for K=2:Pmax,
                [C(:,K*M+(1:M)),n] = covm(Y(K+1:N,:),Y(1:N-K,:),'M');
                C(:,K*M+(1:M)) = C(:,K*M+(1:M)) / N; % biased estimate

                D = C(:,K*M+(1:M));
                for L = 1:K-1,
                        D = D - C(:,(K-L)*M+(1:M))*ARF(:,L*M+(1-M:0));
                end;
                
                ARF(:,K*M+(1-M:0)) = PEB \ D;	
                ARB(:,K*M+(1-M:0)) = PEF \ D';	
                for L = 1:K-1,
                        tmp = ARF(:,L*M+(1-M:0)) - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0)) = tmp;
                end;
                RCF(:,K*M+(1-M:0)) = ARF(:,K*M+(1-M:0)) ;
                RCB(:,K*M+(1-M:0)) = ARB(:,K*M+(1-M:0)) ;
                
                PEF = PEF*[eye(M) - ARB(:,K*M+(1-M:0)) *ARF(:,K*M+(1-M:0)) ];
                PEB = PEB*[eye(M) - ARF(:,K*M+(1-M:0)) *ARB(:,K*M+(1-M:0)) ];
                PE(:,K*M+(1:M))  = PEF;        
        end;
end;

if any(ARF(:)==inf),
% Test for matrix division bug. 
% This bug was observed in LNX86-ML5.3, 6.1 and 6.5, but not in SGI-ML6.5, LNX86-ML6.5, Octave 2.1.35-40; Other platforms unknown.
p = 3;
FLAG_MATRIX_DIVISION_ERROR = ~all(all(isnan(repmat(0,p)/repmat(0,p)))) | ~all(all(isnan(repmat(nan,p)/repmat(nan,p))));

if FLAG_MATRIX_DIVISION_ERROR, 
	%fprintf(2,'### Warning MVAR: Bug in Matrix-Division 0/0 and NaN/NaN yields INF instead of NAN.  Workaround is applied.\n');
	warning('MVAR: bug in Matrix-Division 0/0 and NaN/NaN yields INF instead of NAN.  Workaround is applied.');

	%%%%% Workaround 
	ARF(ARF==inf)=NaN;
	RCF(RCF==inf)=NaN;
end;
end;	

%MAR   = zeros(M,M*Pmax);
DC     = zeros(M);
for K  = 1:Pmax,
%       VAR{K+1} = -ARF(:,K*M+(1-M:0))';
        DC  = DC + ARF(:,K*M+(1-M:0))'.^2; %DC meausure [3]
end;
