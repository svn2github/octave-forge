% NANTEST checks whether the functions from NaN-toolbox have been
% installed correctly. 

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


%	Version 1.25 	Date: 15 Aug 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl <a.schloegl@ieee.org>


r = zeros(19,2);

x = [5,NaN,0,1,nan];

% run test, k=1: with NaNs, k=2: all NaN's are removed
% the result of both should be the same. 


for k=1:2,
        if k==2, x(isnan(x))=[]; end; 
        r(1,k) =sumskipnan(x(1));
        r(2,k) =mean(x);
        r(3,k) =std(x);
        r(4,k) =var(x);
        r(5,k) =skewness(x);
        r(6,k) =kurtosis(x);
        r(7,k) =sem(x);
        r(8,k) =median(x);
        r(9,k) =mad(x);
    		tmp = zscore(x); 
	r(10,k)=tmp(1);
        r(11,k)=coefficient_of_variation(x);
        r(12,k)=geomean(x);
        r(13,k)=harmmean(x);
        r(14,k)=meansq(x);
        r(15,k)=moment(x,6);
        r(16,k)=rms(x);
        r(17,k)=sem(x);
        	tmp=corrcoef([x',(1:length(x))']);
        r(18,k)=any(isnan(tmp(:)));
        r(19,k)=any(isnan(ranks(x')))+k;
end;

% check if result is correct
tmp = abs(r(:,1)-r(:,2))<eps;

% output
if all(tmp)
        fprintf(1,'NANTEST successful - your NaN-tools are correctely installed\n');
else
        fprintf(1,'NANTEST %i not successful \n', find(~tmp));
	fprintf(1,'Some functions must still be replaced\n');
end;

