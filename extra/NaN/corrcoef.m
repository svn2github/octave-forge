function [R,sig,ci1,ci2] = corrcoef(X,Y,Mode);
% CORRCOEF calculates the correlation coefficient.
% X and Y can contain missing values encoded with NaN.
% NaN's are skipped, NaN do not result in a NaN output. 
% (Its assumed that the occurence of NaN's is uncorrelated) 
% The output gives NaN, only if there are insufficient input data.
%
% CORRCOEF(X [,Mode]);
%      calculates the (auto-)correlation matrix of X
% CORRCOEF(X,Y [,Mode]);
%      calculates the crosscorrelation between X and Y
%
% Mode='Pearson'  [default]
%	gives the correlation coefficient  
%	also known as the "product-moment coefficient of correlation" or "Pearson's correlation" [1]
% Mode='Spearman' or 'Rank'
%	gives "Spearman's Rank Correlation Coefficient"
%	This replaces RANKCORR.M or SPEARMAN.M
%	If the ranking is not unique, the correlation coefficient will depend on the sort order.  
%
% [R,p,ci1,ci2] = CORRCOEF(...);
% 	R is the correlation matrix
%	R(i,j) is the correlation coefficient r between X(:,i) and Y(:,j)
%  p    gives the significance of R
%	It tests the null hypothesis that the product moment correlation coefficient is zero 
%       using Student's t-test on the statistic t = r sqrt(N-2)/sqrt(1-r^2) 
%       where N is the number of samples (Statistics, M. Spiegel, Schaum series).
%  p>alpha: do not reject the Null hypothesis: "R is zero".
%  p<alpha: The alternative hypothesis "R2 is larger than zero" is true with probability (1-alpha).
%  ci1	lower 0.95 confidence interval 
%  ci2	upper 0.95 confidence interval 
%
% Further recommandation related to the correlation coefficient 
% + Correlation is not causation. The observed correlation between two variables 
%	might be due to the action of a third, unobserved variable.
% + Ensure that NaN's are unrelated; otherwise encode NaN's in an 
%		appropriate way e.g. with X(isnan(X))=max(X(:))+eps;
% + LOOK AT THE SCATTERPLOTS! [20]
%
% see also: SUMSKIPNAN, COVM, COV, COR
%
% REFERENCES:
% on the correlation coefficient 
% [ 1] http://mathworld.wolfram.com/CorrelationCoefficient.html
% [ 2] http://www.geography.btinternet.co.uk/spearman.htm
% on the significance test of the correlation coefficient
% [11] http://www.met.rdg.ac.uk/cag/STATS/corr.html
% [12] http://www.janda.org/c10/Lectures/topic06/L24-significanceR.htm
% [13] http://faculty.vassar.edu/lowry/ch4apx.html
% [14] http://davidmlane.com/hyperstat/B134689.html
% others
% [20] http://www.tufts.edu/~gdallal/corr.htm

%    Version 1.25  Date: 16 Aug 2002
%    Copyright (C) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>	

%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% .changelog
% V1.25	16082002	handling missing values (NaN) in Spearman's rank correlation	

% Features:
% - interprets NaN's as missing value
% - Pearson's correlation
% - Spearman's rank correlation
% - is fast, using an efficient algorithm O(n.log(n)) for the rank correlation
% - significance test included for null-hypthesis: r=0 
% - confidence interval (0.95) included
% - rank correlation works for cell arrays, too (no check for missing values).
% - compatible with Octave and Matlab


if nargin==1
        Y = [];
        Mode='Pearson';
elseif nargin==0
        fprintf(2,'Error CORRCOEF: Missing argument(s)\n');
elseif nargin==2
        if ~isnumeric(Y)
                Mode=Y;
                Y=[];
        else
                Mode='Pearson';
        end;
end;        

[r1,c1]=size(X);
if ~isempty(Y)
        [r2,c2]=size(Y);
        if r1~=r2,
                fprintf(2,'Error CORRCOEF: X and Y must have the same number of observations (rows).\n');
                return;
        end;
else
        [r2,c2]=size(X);
end;

if strcmp(lower(Mode),'pearson');
        if ~isempty(Y),
                [S1,N1,SSQ1] = sumskipnan(X,1);
                [S2,N2,SSQ2] = sumskipnan(Y,1);
                
                NN = (~isnan(X)')*(~isnan(Y));
                X(isnan(X)) = 0; % skip NaN's
                Y(isnan(Y)) = 0; % skip NaN's
                CC = X'*Y;
                
                M1 = S1./N1;
                M2 = S2./N2;
                cc = CC./NN - M1'*M2;
                R  = cc./sqrt((SSQ1./N1-M1.*M1)'*(SSQ2./N2-M2.*M2));
        else        
                [S,N,SSQ] = sumskipnan(X,1);
                
                NN = (~isnan(X)')*(~isnan(X));
                X(isnan(X)) = 0; % skip NaN's
                CC = X'*X;
                
                M  = S./N;
                cc = CC./NN - M'*M;
                v  = (SSQ./N- M.*M);  %max(N-1,0);
                R  = cc./sqrt(v'*v);
                R(logical(eye(size(R))))=1;  % prevent rounding errors 
        end;
        
elseif strcmp(lower(Mode),'spearman') | strcmp(lower(Mode),'rank');
        %%%%% generate combinations using indices
        M1 = size(X,2);
        if isempty(Y),
                M2 = M1;	        
                IX = ones(M1);
        else
                M2 = size(Y,2);
                IX = zeros(M1+M2);
                IX(1:M1,M1+(1:M2)) = 1;
        end;  
        [jx,jy] = find(IX);
        
        %[tmp,ix] = sort([X,Y]);     % sorts the data, ix indicates the position in the sorted list
        % but because sort does not work accordingly for cell arrays, 
        % and DIM argument not supported by Octave 
        % and DIM argument does not work for cell-arrays in Matlab
        % we sort each column separately:
        
        iy = zeros(size(X)+[0,size(Y,2)]);
        SW = 0;
        for k = 1:size(iy,2),
                if k>M1,
                        [sX,ix] = sort(Y(:,k-M1)); 
                else
                        [sX,ix] = sort(X(:,k)); 
                end;
                d = find(diff([find(diff(sX));sum(~isnan(sX))])>1)+1; % identify multiple occurences 
        	SW = SW | ~isempty(d);        
                [tmp,iy(:,k)] = sort(ix);	    % iy yields the rank of each element 	
        end;
        % Now, iy(:,jx)-iy(:,jy) are the rank differences (without correction for missing values)
        
        if SW,
	        fprintf(2,'Warning: multiple occurences of an element is non-deterministic!\n');
        end;
        
        tmp=zeros(size(iy));
        if isnumeric(X),
        	tmp(:,1:M1)=isnan(X);         
        end;
        if size(Y,2) & isnumeric(Y),
        	tmp(:,M1+(1:size(Y,2)))=isnan(Y);         
        end;
        iy(logical(tmp))=NaN;
        
        if isnumeric(X) & isnumeric(Y),
                % Here, we correct the rank for the missing values and calculate the rank differences
                ic = cumsum(isnan(iy(:,jx))-isnan(iy(:,jy))); 	% count missing values (NaN's)          
                iy = (iy(:,jx) - iy(:,jy)) + ic;		% correct rank difference 
        else 
                iy = (iy(:,jx) - iy(:,jy));		% calc rank difference 
        end;
        
        
        [R,NN] = sumskipnan(iy.^2,1);		% NN is the number of non-missing values
        R      = reshape(R,M1,M2);
        NN     = reshape(NN,M1,M2);
        R      = 1-6*R./(NN.*(NN.*NN-1));
        
        if isempty(Y),
                R(logical(eye(size(R))))=1;	% prevent rounding errors 
        end;
end;

if nargout<2, return, end;



% SIGNIFICANCE TEST

warning off; 	% prevent division-by-zero warnings in Matlab.
tmp = 1 - R.*R;
t   = R.*sqrt(max(NN-2,0)./tmp);

if exist('t_cdf')>1;
        sig = t_cdf(t,NN-2);
elseif exist('tcdf')>1;
        sig = tcdf(t,NN-2);
else
        fprintf('Warning CORRCOEF: significance test not completed because of missing TCDF-function\n')
        sig = repmat(nan,size(R));
end;
sig  = 2 * min(sig,1 - sig);

if nargout<3, return, end;



% CONFIDENCE INTERVAL

z   = log((1+R)./(1-R))/2; 	% Fisher's z-transform; 
%sz  = 1./sqrt(NN-3);		% standard error of z
sz  = 1.96./sqrt(NN-3);		% 0.95 confidence interval (i.e. 1.96*standard error) of z

ci1 = tanh(z-sz);
ci2 = tanh(z+sz);

return;
