function [w, MAR, C, sbc, fpe, th]=arfit(Y, pmin, pmax, selector, no_const)
% ARFIT2 estimates multivariate autoregressive parameters
%   using MDURLEV with the Nuttall-Strand method [1,2]. 
% ARFIT2 is included for combatibility reasons to ARFIT [3]
%  
%  [w, A, C, sbc, fpe] = arfit2(v, pmin, pmax, selector, no_const)
%
% see also: ARFIT, MVAR
%
% REFERENCES:
%  [1] M.S. Kay "Modern Spectral Estimation" Prentice Hall, 1988. 
%  [2] S.L. Marple "Digital Spectral Analysis with Applications" Prentice Hall, 1987.
%  [3] T. Schneider and A. Neumaier, A. 2001. 
%	Algorithm 808: ARFIT-a Matlab package for the estimation of parameters and eigenmodes 
%	of multivariate autoregressive models. ACM-Transactions on Mathematical Software. 27, (Mar.), 58-65.
%  

%	Version 2.86
%	last revision 21.03.2002
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


if (pmin ~= round(pmin) | pmax ~= round(pmax))
        error('Order must be integer.');
end
if (pmax < pmin)
        error('PMAX must be greater than or equal to PMIN.')
end

% set defaults and check for optional arguments
if (nargin == 3)              	% no optional arguments => set default values
        mcor       = 1;         % fit intercept vector
        selector   = 'sbc';	% use SBC as order selection criterion
elseif (nargin == 4)          	% one optional argument
        if strcmp(selector, 'zero')
                mcor     = 0;   % no intercept vector to be fitted
                selector = 'sbc';	% default order selection 
        else
                mcor     = 1;	% fit intercept vector
        end
elseif (nargin == 5)		% two optional arguments
        if strcmp(no_const, 'zero')
                mcor     = 0;   	% no intercept vector to be fitted
        else
                error(['Bad argument. Usage: ', '[w,A,C,SBC,FPE,th]=AR(v,pmin,pmax,SELECTOR,''zero'')'])
        end
end

[N,M]=size(Y);

if mcor,
        m = mean(Y);
        Y = Y - repmat(m,size(Y)./size(m));        
end;

[MAR,RCF,PE] = mvar(Y, pmax, 2);

%if 1;nargout>3;
ne = N-mcor-(pmin:pmax);
for p=pmin:pmax, 
        % Get downdated logarithm of determinant
        logdp(p-pmin+1) = log(det(PE{p+1}*(N-p-mcor))); 
end;

% Schwarz's Bayesian Criterion
sbc = logdp/M - log(ne) .* (1-(M*(pmin:pmax)+mcor)./ne);

% logarithm of Akaike's Final Prediction Error
fpe = logdp/M - log(ne.*(ne-M*(pmin:pmax)-mcor)./(ne+M*(pmin:pmax)+mcor));

% Modified Schwarz criterion (MSC):
% msc(i) = logdp(i)/m - (log(ne) - 2.5) * (1 - 2.5*np(i)/(ne-np(i)));

% get index iopt of order that minimizes the order selection 
% criterion specified by the variable selector
[val, iopt]  = min(eval(selector)); 

% select order of model
popt = pmin + iopt-1; % estimated optimum order 

if popt<pmax, 
        pmax=popt; 
        [MAR, RCF, PE] = mvar(Y, pmax, 2);
end;
%end

C = PE{end};

if mcor,
        I = eye(M);        
        for k = 1:pmax,
                I = I - MAR(:,k*M+(1-M:0));
        end;
        w = I*m';
else
        w = zeros(M,1);
end;

if nargout>5,	th=[];	fprintf(2,'Warning ARFIT2: output TH not defined\n'); end;