(k)function [R,sig,ci1,ci2] = corrcoef(X,Y,Mode);
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
% Mode='Pearson' or 'parametric' [default]
%	gives the correlation coefficient  
%	also known as the "product-moment coefficient of correlation" or "Pearson's correlation" [1]
% Mode='Spearman' 	gives "Spearman's Rank Correlation Coefficient"
%	This replaces SPEARMAN.M
% Mode='Rank' 		gives a nonparametric Rank Correlation Coefficient
%	This replaces RANKCORR.M
%
% [R,p,ci1,ci2] = CORRCOEF(...);
% 	R is the correlation matrix
%	R(i,j) is the correlation coefficient r between X(:,i) and Y(:,j)
%  p    gives the significance of R
%	It tests the null hypothesis that the product moment correlation coefficient is zero 
%       using Student's t-test on the statistic t = r sqrt(N-2)/sqrt(1-r^2) 
%       where N is the number of samples (Statistics, M. Spiegel, Schaum series).
%  p > alpha: do not reject the Null hypothesis: "R is zero".
%  p < alpha: The alternative hypothesis "R2 is larger than zero" is true with probability (1-alpha).
%  ci1	lower 0.95 confidence interval 
%  ci2	upper 0.95 confidence interval 
%
% Further recommandation related to the correlation coefficient 
% + LOOK AT THE SCATTERPLOTS!
% + Correlation is not causation. The observed correlation between two variables 
%	might be due to the action of other, unobserved variables.
%
% see also: SUMSKIPNAN, COVM, COV, COR, SPEARMAN, RANKCORR, RANKS
%
% REFERENCES:
% on the correlation coefficient 
% [ 1] http://mathworld.wolfram.com/CorrelationCoefficient.html
% [ 2] http://www.geography.btinternet.co.uk/spearman.htm
% [ 3] Hogg, R. V. and Craig, A. T. Introduction to Mathematical Statistics, 5th ed.  New York: Macmillan, pp. 338 and 400, 1995.
% [ 4] Lehmann, E. L. and D'Abrera, H. J. M. Nonparametrics: Statistical Methods Based on Ranks, rev. ed. Englewood Cliffs, NJ: Prentice-Hall, pp. 292, 300, and 323, 1998.
% [ 5] Press, W. H.; Flannery, B. P.; Teukolsky, S. A.; and Vetterling, W. T. Numerical Recipes in FORTRAN: The Art of Scientific Computing, 2nd ed. Cambridge, England: Cambridge University Press, pp. 634-637, 1992
% [ 6] http://mathworld.wolfram.com/SpearmanRankCorrelationCoefficient.html
% on the significance test of the correlation coefficient
% [11] http://www.met.rdg.ac.uk/cag/STATS/corr.html
% [12] http://www.janda.org/c10/Lectures/topic06/L24-significanceR.htm
% [13] http://faculty.vassar.edu/lowry/ch4apx.html
% [14] http://davidmlane.com/hyperstat/B134689.html
% others
% [20] http://www.tufts.edu/~gdallal/corr.htm

%    Version 1.26  Date: 20 Aug 2002
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
%       20082002	all glitches fixed.

% Features:
% + interprets NaN's as missing value
% + Pearson's correlation
% + Spearman's rank correlation
% + Rank correlation (non-parametric, non-Spearman)
% + is fast, using an efficient algorithm O(n.log(n)) for calculating the ranks
% + significance test for null-hypthesis: r=0 
% + confidence interval included
% - rank correlation works for cell arrays, too (no check for missing values).
% + compatible with Octave and Matlab


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
Mode=[Mode,'        '];

[r1,c1]=size(X);
if ~isempty(Y)
        [r2,c2]=size(Y);
        if r1~=r2,
                fprintf(2,'Error CORRCOEF: X and Y must have the same number of observations (rows).\n');
                return;
        end;
        NN = (~isnan(X)')*(~isnan(Y));
else
        [r2,c2]=size(X);
        NN = (~isnan(X)')*(~isnan(X));  
end;

%%%%% generate combinations using indices for pairwise calculation of the correlation
YESNAN = any(isnan(X(:))) | any(isnan(Y(:)));
if isempty(Y),
        IX = ones(c1)-diag(ones(c1,1));
else
        IX = zeros(c1+c2);
        IX(1:c1,c1+(1:c2)) = 1;
%        X = [X,Y];
end;  
[jx,jy] = find(IX);
R = repmat(nan,size(IX));

if strcmp(lower(Mode(1:7)),'pearson');
        % see http://mathworld.wolfram.com/CorrelationCoefficient.html
	if ~YESNAN,
                [S,N,SSQ] = sumskipnan(X,1);
                if ~isempty(Y),
	                [S2,N2,SSQ2] = sumskipnan(Y,1);
                        CC = X'*Y;
                        M1 = S./N;
                        M2 = S2./N2;
                        cc = CC./NN - M1'*M2;
                        R  = cc./sqrt((SSQ./N-M1.*M1)'*(SSQ2./N2-M2.*M2));
                else        
                        CC = X'*X;
                        M  = S./N;
                        cc = CC./NN - M'*M;
                        v  = (SSQ./N- M.*M); %max(N-1,0);
                        R  = cc./sqrt(v'*v);
                end;
                r = []; % mark that R is calculated
        else
                if ~isempty(Y),
                        X  = [X,Y];
                end;  
                for k = 1:length(jx),
                        ik = ~any(isnan(X(:,[jx(k),jy(k)])),2);
                        [s,n,s2] = sumskipnan(X(ik,[jx(k),jy(k)]),1);
                        v  = (s2-s.*s./n)./n;
                        cc = X(ik,jx(k))'*X(ik,jy(k));
                        cc = cc/n(1) - prod(s./n);
                        r(k) = cc./sqrt(prod(v));
                end;
        end
        
elseif strcmp(lower(Mode(1:4)),'rank');
        % see [ 6] http://mathworld.wolfram.com/SpearmanRankCorrelationCoefficient.html
	if ~YESNAN,
                if isempty(Y)
	                R = corrcoef(ranks(X));
                else
                        R = corrcoef(ranks(X),ranks(Y));
                end;
                r = []; % mark that R is calculated
        else
                if ~isempty(Y),
                        X = [X,Y];
                end;  
                for k = 1:length(jx),
                        ik = ~any(isnan(X(:,[jx(k),jy(k)])),2);
                        il = ranks(X(ik,[jx(k),jy(k)]));
                        r(k) = corrcoef(il(:,1),il(:,2));
                end;
        end;
        
elseif strcmp(lower(Mode(1:8)),'spearman');
        % see [ 6] http://mathworld.wolfram.com/SpearmanRankCorrelationCoefficient.html
        if ~isempty(Y),
                X = [X,Y];
        end;  
        if ~YESNAN,
                iy = ranks(X);	%  calculates ranks;
                
                [r,n] = sumskipnan((iy(:,jx) - iy(:,jy)).^2,1);		% NN is the number of non-missing values
        else
                for k = 1:length(jx),
                        ik = ~any(isnan(X(:,[jx(k),jy(k)])),2);
                        il = ranks(X(ik,[jx(k),jy(k)]));
                        % NN is the number of non-missing values
                        [r(k),n(k)] = sumskipnan((il(:,1) - il(:,2)).^2);
                end;
        end;
        r = 1-6*r./(n.*(n.*n-1));
        
elseif strcmp(lower(Mode(1:7)),'partial');
        fprintf(2,'Error CORRCOEF: use PARTCORRCOEF \n',Mode);
        
        return;
        
elseif strcmp(lower(Mode(1:7)),'kendall');
        fprintf(2,'Error CORRCOEF: mode ''%s'' not implemented yet.\n',Mode);
        
        return;
else
        fprintf(2,'Error CORRCOEF: unknown mode ''%s''\n',Mode);
end;

if ~isempty(r), % bring r(k) into position
        if ~isempty(Y),
                R     = reshape(r,c1,c2);
        else
                for k = 1:length(jx),
                        R(jx(k),jy(k)) = r(k);
                end;
        end;
end;
if isempty(Y),   % in this case, diagonal must be 1
        R(logical(eye(size(R)))) = 1;	% prevent rounding errors 
end;
if nargout<2, 
        return, 
end;



% SIGNIFICANCE TEST

%warning off; 	% prevent division-by-zero warnings in Matlab.

tmp = 1 - R.*R;
%ix1 =(tmp==0);
%tmp(ix1)=nan;		% avoid division-by-zero warning	
t   = R.*sqrt(max(NN-2,0)./tmp);

%ix2 = (t<0)|(t>1);	% mark abs(r)==1
if 0,any(ix2(:));
        warning('CORRCOEF: t-value out of range - probably due to some rounding error') 
        t(ix2)=nan;
end;

if exist('t_cdf')>1;
        sig = t_cdf(t,NN-2);
elseif exist('tcdf')>1;
        sig = tcdf(t,NN-2);
else
        fprintf('Warning CORRCOEF: significance test not completed because of missing TCDF-function\n')
        sig = repmat(nan,size(R));
end;
sig  = 2 * min(sig,1 - sig);

if nargout<3, 
        return, 
end;



% CONFIDENCE INTERVAL
if exist('flag_implicit_significance')==1,
        alpha = flag_implicit_significance;
else
	alpha = 0.01;        
end;

fprintf(1,'CORRCOEF: confidence interval is based on alpha=%f\n',alpha);

tmp = R;
%tmp(ix1 | ix2) = nan;		% avoid division-by-zero warning
z   = log((1+tmp)./(1-tmp))/2; 	% Fisher's z-transform; 
%sz  = 1./sqrt(NN-3);		% standard error of z
sz  = sqrt(2)*erfinv(1-2*alpha)./sqrt(NN-3);		% confidence interval for alpha of z

ci1 = tanh(z-sz);
ci2 = tanh(z+sz);

%ci1(isnan(ci1))=R(isnan(ci1));	% in case of isnan(ci), the interval limits are exactly the R value 
%ci2(isnan(ci2))=R(isnan(ci2));
return;
