% NANINSTTEST checks whether the functions from NaN-toolbox have been
% correctly installed. 
%
% see also: NANTEST

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

%	$Revision$
%	$Id$
%	Copyright (c) 2000-2003 by  Alois Schloegl <a.schloegl@ieee.org>


r = zeros(25,2);

x = [5,NaN,0,1,nan];

% run test, k=1: with NaNs, k=2: all NaN's are removed
% the result of both should be the same. 

FLAG_WARNING = warning;
warning('off');

funlist = {'sumskipnan','mean','std','var','skewness','kurtosis','sem','median','mad','zscore','coefficient_of_variation','geomean','harmean','meansq','moment','rms','','corrcoef','rankcorr','spearman','ranks','center','trimean','min','max','nanmin','nanmax','','','','','','','','','','','','','','','','','',''};
for k=1:2,
        if k==2, x(isnan(x))=[]; end; 
        r(1,k) =sumskipnan(x(1));
        r(2,k) =mean(x);
        r(3,k) =std(x);
        r(4,k) =var(x);
        r(5,k) =skewness(x);
        r(6,k) =kurtosis(x);
        if exist('sem')==2,
                r(7,k) =sem(x);
        end;
        r(8,k) =median(x);
        r(9,k) =mad(x);
    		tmp = zscore(x); 
	r(10,k)=tmp(1);
        if exist('coefficient_of_variation')==2,
                r(11,k)=coefficient_of_variation(x);
        end;
        r(12,k)=geomean(x);
        r(13,k)=harmmean(x);
        if exist('meansq')==2,
        	r(14,k)=meansq(x);
        end;
        r(15,k)=moment(x,6);
        if exist('rms')==2,
                r(16,k)=rms(x);
        end;
        % r(17,k) is currently empty. 
        	tmp=corrcoef(x',(1:length(x))');
        r(18,k)=any(isnan(tmp(:)));
        if exist('rankcorr')==2,
        		tmp=rankcorr(x',(1:length(x))');
                r(19,k)=any(isnan(tmp(:)));
        end;
        if exist('spearman')==2,
        		tmp=spearman(x',(1:length(x))');
	        r(20,k)=any(isnan(tmp(:)));
        end;
        if exist('ranks')==2,
                r(21,k)=any(isnan(ranks(x')))+k;
        end;
        if exist('center')==2,
        	        tmp=center(x);
	        r(22,k)=tmp(1);
        end;
        if exist('center')==2,
        	r(23,k)=trimean(x);
        end;
    	r(24,k)=min(x);
    	r(25,k)=max(x);
end;

% check if result is correct
tmp = abs(r(:,1)-r(:,2))<eps;

q = zeros(1,5);

% output
if all(tmp) & all(~q),
        fprintf(1,'NANINSTTEST successful - your NaN-tools are correctly installed\n');
else
        fprintf(1,'NANINSTTEST %i not successful \n', find(~tmp));
	fprintf(1,'The following functions do not skip NaNs and should, therefore, be replaced:\n');
	funlist{find(~tmp)}
end;

warning(FLAG_WARNING);
