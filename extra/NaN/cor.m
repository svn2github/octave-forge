function [r2] = cor(X,Y);
% COR calculates the correlation matrix
% X and Y can contain missing values encoded with NaN.
% NaN's are skipped, NaN do not result in a NaN output. 
% (Its assumed that the occurence of NaN's is uncorrelated) 
% The output gives NaN only if there are insufficient input data
%
% COR(X);
%      calculates the (auto-)correlation matrix of X
% COR(X,Y);
%      calculates the crosscorrelation between X and Y
%
% c = COR(...);
% 	c is the correlation matrix
%
% see also: SUMSKIPNAN, COVM, COV, CORRCOEF
%
% REFERENCES:
% http://mathworld.wolfram.com/CorrelationCoefficient.html


%	Copyright (C) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>	


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


if nargin==1
        Y = [];
elseif nargin==0
        fprintf(2,'Error COr: Missing argument(s)\n');
end;        

[r1,c1]=size(X);
if (c1>r1),
        fprintf(2,'Warning COR: Covariance is ill-defined, because of too less observations (rows).\n');
end;

[r1,c1]=size(X);
if ~isempty(Y)
        [r2,c2]=size(Y);
        if r1~=r2,
                fprintf(2,'Error COR: X and Y must have the same number of observations (rows).\n');
                return;
        end;
else
        [r2,c2]=size(X);
end;

if (c1>r1) | (c2>r2),
        fprintf(2,'Warning COR: Covariance is ill-defined, because of too less observations (rows).\n');
end;

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
        r2 = cc./sqrt((SSQ1./N1-M1.*M1)'*(SSQ2./N2-M2.*M2));
		
else        
        [S,N,SSQ] = sumskipnan(X,1);

        NN = (~isnan(X)')*(~isnan(X));
        X(isnan(X)) = 0; % skip NaN's
        CC = X'*X;
                
	M  = S./N;
	cc = CC./NN - M'*M;
        v  = (SSQ./N- M.*M);  %max(N-1,0);
	r2 = cc./sqrt(v'*v);
end;
