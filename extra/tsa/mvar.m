function [ARF,RCF,PE,DC,varargout] = mvar(Y, Pmax, Mode);
% function  [MAR,RC,PE] = mvar(Y [,Pmax]);
% estimates a multivariate AR(p) model parameter by solving the
% multivariate Yule-Walker with various methods [2]
%
%  INPUT:
% ACF	Autocorrelation function from lag=[0:p]
% Pmax 	Model order
%
%  OUTPUT
% MAR   multivariate autoregressive model parameter (same format as in [4]	
% RC    reflection coefficients (= -PARCOR coefficients)
% PE    remaining error variance
%
% All input and output parameters are organized in rows, one row 
% corresponds to the parameters of one channel.
%
% see also: MVFILTER, COVM, SUMSKIPNAN
%
% REFERENCES:
%  [1] M.S. Kay "Modern Spectral Estimation" Prentice Hall, 1988. 
%  [2] S.L. Marple "Digital Spectral Analysis with Applications" Prentice Hall, 1987.
%  [3] M. Kaminski, M. Ding, W. Truccolo, S.L. Bressler, Evaluating causal realations in neural systems:
%	Granger causality, directed transfer functions and statistical assessment of significance.
%	Biol. Cybern., 85,145-157 (2001)
%  [4] T. Schneider and A. Neumaier, A. 2001. 
%	Algorithm 808: ARFIT-a Matlab package for the estimation of parameters and eigenmodes 
%	of multivariate autoregressive models. ACM-Transactions on Mathematical Software. 27, (Mar.), 58-65.
%  [5] A. Schloegl 2002. 
%	Validation of MVAR estimators or Remark on Algorithm 808: ARFIT, 
%	ACM-Transactions on Mathematical Software. submitted.


%	Version 2.90
%	last revision 06.04.2002
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
[N,M] = size(Y);

if nargin<2, 
        Pmax=max([N,M])-1;
end;

if iscell(Y)
        Pmax = min(max(N ,M ),Pmax);
        C    = Y;
else
        %%%%% Estimate Autocorrelation funtion 	
        if 0, 
                [tmp,LAG]=xcorr(Y,Pmax,'biased');
                for K=0:Pmax,
                        C{K+1}=reshape(tmp(find(LAG==K)),M ,M );	
                        C(:,K*M+(1:M))=reshape(tmp(find(LAG==K)),M ,M );	
                end;
        else
                for K =0:Pmax;
                        %C{K+1}=Y(1:N-K,:)'*Y(K+1:N ,:)/N ;
                        %C{K+1}=Y(K+1:N,:)'*Y(1:N-K,:)/N; % =Rxx(-k)=conj(Rxx(k)) in [2] with K=k+1; 
                end;
        end;
end;
if nargin<3,
        % tested with a bootstrap validation, Mode 2 or 5 are recommended
        %Mode=5;  % M*P << N
        %Mode=5;  % 5*6 << 100, test=900, permutations 1000
        Mode=2;    % M*P ~~ N
end;

[C(:,1:M),n] = covm(Y,'M');
PE(:,1:M)  = C(:,1:M)./n;
if Mode==0;  % %%%%% multi-channel Levinsion algorithm [2]
        % multivariate Autoregressive parameter estimation
        fprintf('Warning MDURLEV: It''s not recommended to use this mode\n')        
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
                
                tmp        = F(K+1:N,:) - B(1:N-K,:)*ARF{K}';
                B(1:N-K,:) = B(1:N-K,:) - F(K+1:N,:)*ARB{K}';
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
        
elseif Mode==1, 
        %%%%% multi-channel Levinson algorithm 
        %%%%% with correlation function estimation method 
        %%%%% also called the "multichannel Yule-Walker"
        %%%%% using the biased correlation 
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
                        tmp      = ARF(:,L*M+(1-M:0))   - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))   = tmp;
                        %tmp      = ARF{L}   - ARF{K}*ARB{K-L};
                        %ARB{K-L} = ARB{K-L} - ARB{K}*ARF{L};
                        %ARF{L}   = tmp;
                end;
                
                RCF(:,K*M+(1-M:0)) = ARF(:,K*M+(1-M:0));
                RCB(:,K*M+(1-M:0)) = ARB(:,K*M+(1-M:0));
                
                PEF = [eye(M) - ARF(:,K*M+(1-M:0))*ARB(:,K*M+(1-M:0))]*PEF;
                PEB = [eye(M) - ARB(:,K*M+(1-M:0))*ARF(:,K*M+(1-M:0))]*PEB;
                PE(:,K*M+(1:M)) = PEF;        
        end;
        
elseif Mode==6, 
        %%%%% multi-channel Levinson algorithm 
        %%%%% with correlation function estimation method 
        %%%%% also called the "multichannel Yule-Walker"
        %%%%% using the unbiased correlation 
        
        C(:,1:M) = C(:,1:M)/N;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        
        for K=1:Pmax,
                C(:,K*M+(1:M)) = covm(Y(K+1:N,:),Y(1:N-K,:),'M');
                %C{K+1} = C{K+1}/N;
                D = C{K+1};
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
        
elseif Mode==2, 
        %%%%% multi-channel Levinsion algorithm 
        %%%%% using Nutall-Strand Method [2]
        %%%%% Covariance matrix is normalized by N=length(X)-p 
        C(:,1:M) = C(:,1:M)/N;
        F = Y;
        B = Y;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        for K=1:Pmax,
                D      = covm(F(K+1:N,:),B(1:N-K,:),'M');
                ARF(:,K*M+(1-M:0)) = D / PEB;	
                ARB(:,K*M+(1-M:0)) = D'/ PEF;	
                
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
                
                PEF = covm(F(K+1:N,:),F(K+1:N,:),'M');
                PEB = covm(B(1:N-K,:),B(1:N-K,:),'M');
                PE(:,K*M+(1:M)) = PEF;        
        end;
        
elseif Mode==5, %%%%% multi-channel Levinsion algorithm [2] using Nutall-Strand Method
        %%%%% multi-channel Levinsion algorithm 
        %%%%% using Nutall-Strand Method [2]
        %%%%% Covariance matrix is normalized by N=length(X) 
        
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
                
                tmp        = F(K+1:N,:) - B(1:N-K,:)*ARF{K}';
                B(1:N-K,:) = B(1:N-K,:) - F(K+1:N,:)*ARB{K}';
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
        
elseif Mode==3, %%%%% multi-channel Levinsion algorithm [2] using Vieira-Morf Method
        fprintf('Warning MDURLEV: It''s not recommended to use this mode\n')        
        C(:,1:M) = C(:,1:M)/N;
        F = Y;
        B = Y;
        PEF = C(:,1:M);
        PEB = C(:,1:M);
        for K=1:Pmax,
                D      = covm(F(K+1:N,:),B(1:N-K,:),'M');
                ARF{K} = (PEF.^-.5)*D*(PEB.^-.5)';	
                ARB{K} = ARF{K}; 
                
                tmp        = F(K+1:N,:) - B(1:N-K,:)*ARF{K}';
                B(1:N-K,:) = B(1:N-K,:) - F(K+1:N,:)*ARB{K}';
                F(K+1:N,:) = tmp;
                
                for L = 1:K-1,
                        tmp      = ARF(:,L*M+(1-M:0))   - ARF(:,K*M+(1-M:0))*ARB(:,(K-L)*M+(1-M:0));
                        ARB(:,(K-L)*M+(1-M:0)) = ARB(:,(K-L)*M+(1-M:0)) - ARB(:,K*M+(1-M:0))*ARF(:,L*M+(1-M:0));
                        ARF(:,L*M+(1-M:0))   = tmp;
                end;
                
                %RCF{K} = ARF{K};
                RCF(:,K*M+(1-M:0)) = ARF(:,K*M+(1-M:0));
                
                PEF = covm(F(K+1:N,:),F(K+1:N,:),'M');
                PEB = covm(B(1:N-K,:),B(1:N-K,:),'M');
                %PE{K+1} = PEF;        
                PE(:,K*M+(1:M)) = PEF;        
        end;
        
elseif Mode==4,  %%%%% nach Kay, not fixed yet. 
        fprintf('Warning MDURLEV: It''s not recommended to use this mode\n')        
        
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
                        D = D - ARF(:,L*M+(1-M:0))*C(:,(K-L)*M+(1:M));
                end;
                ARF(:,K*M+(1-M:0)) = PEB \ D;	
                ARB(:,K*M+(1-M:0)) = PEF \ D';	
                for L = 1:K-1,
                        ARFtmp(:,L*M+(1-M:0))  = ARF(:,L*M+(1-M:0))  - ARB(:,(K-L)*M+(1-M:0)) *ARF(:,K*M+(1-M:0)) ;
                        ARB(:,L*M+(1-M:0))  = ARB(:,L*M+(1-M:0))  - ARF(:,(K-L)*M+(1-M:0)) *ARB(:,K*M+(1-M:0)) ;
                end;
                ARF(:,1:(K-1)*M) = ARFtmp;
                RCF{K} = ARF(:,K*M+(1-M:0)) ;
                RCB{K} = ARB(:,K*M+(1-M:0)) ;
                
                PEF = PEF*[eye(M) - ARB(:,K*M+(1-M:0)) *ARF(:,K*M+(1-M:0)) ];
                PEB = PEB*[eye(M) - ARF(:,K*M+(1-M:0)) *ARB(:,K*M+(1-M:0)) ];
                PE(:,K*M+(1:M))  = PEF;        
        end;
end;

VAR{1} = eye(M);
MAR    = zeros(M,M*Pmax);
DC     = zeros(M);

for K  = 1:Pmax,
        VAR{K+1} = -ARF(:,K*M+(1-M:0))';
        DC = DC + ARF(:,K*M+(1-M:0))'.^2; %DC meausure [3]
end;

DC = sqrt(DC);
if (exist('F')==1) & (nargout>4)
        varargout{1} = F(Pmax+1:N,:);
        [u,s,v] = svd(F(Pmax+1:N,:),0);
        varargout{2} = diag(s);
        varargout{3} = v;
end;


