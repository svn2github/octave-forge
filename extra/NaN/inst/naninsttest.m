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
%    along with this program; If not, see <http://www.gnu.org/licenses/>.

%	$Revision$
%	$Id$
%	Copyright (C) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>


r = zeros(25,2);

x = [5,NaN,0,1,nan];

% run test, k=1: with NaNs, k=2: all NaN's are removed
% the result of both should be the same. 

%FLAG_WARNING = warning;
warning('off');

funlist = {'sumskipnan','mean','std','var','skewness','kurtosis','sem','median','mad','zscore','coefficient_of_variation','geomean','harmmean','meansq','moment','rms','','corrcoef','rankcorr','spearman','ranks','center','trimean','min','max','tpdf','tcdf','tinv','normpdf','normcdf','norminv','nansum','nanstd','','','','','','','','','','','',''};
for k=1:2,
        if k==2, x(isnan(x))=[]; end; 
        r(1,k) =sumskipnan(x(1));
        r(2,k) =mean(x);
        r(3,k) =std(x);
        r(4,k) =var(x);
	        r(5,k) = skewness(x);
	        r(6,k) =kurtosis(x);
                r(7,k) =sem(x);
        r(8,k) =median(x);
	        r(9,k) =mad(x);
    		tmp = zscore(x); 
		r(10,k)=tmp(1);
        if exist('coefficient_of_variation','file'),
                r(11,k)=coefficient_of_variation(x);
        end;
                r(12,k)=geomean(x);
                r(13,k)=harmmean(x);
        if exist('meansq','file'),
        	r(14,k)=meansq(x);
        end;
        if exist('moment','file'),
                r(15,k)=moment(x,6);
        end;
        if exist('rms','file'),
                r(16,k)=rms(x);
        end;
        % r(17,k) is currently empty. 
        	tmp=corrcoef(x',(1:length(x))');
        r(18,k)=any(isnan(tmp(:)));
        if exist('rankcorr','file'),
                tmp=rankcorr(x',(1:length(x))');
                r(19,k)=any(isnan(tmp(:)));
        end;
        if exist('spearman','file'),
                tmp=spearman(x',(1:length(x))');
	        r(20,k)=any(isnan(tmp(:)));
        end;
        if exist('ranks','file'),
                r(21,k)=any(isnan(ranks(x')))+k;
        end;
        if exist('center','file'),
        	tmp=center(x);
	        r(22,k)=tmp(1);
        end;
        if exist('trimean','file'),
        	r(23,k)=trimean(x);
        end;
        r(24,k)=min(x);
        r(25,k)=max(x);
        
        if exist('tpdf','file'), 
                fun='tpdf'; 
        elseif exist('t_pdf')==2,
                fun='t_pdf';
        end;
        r(26,k) = k+isnan(feval(fun,x(2),4));	        
        
        if exist('tcdf','file'), 
                fun='tcdf'; 
        elseif exist('t_cdf','file'),
                fun='t_cdf';
        end;
        try
                r(27,k) = k*(~isnan(feval(fun,nan,4)));	        
        catch
                r(27,k) = k;	
        end;
        
        if exist('tinv','file'), 
                fun='tinv'; 
        elseif exist('t_inv','file'),
                fun='t_inv';
        end;
        r(28,k) = k*(~isnan(feval(fun,NaN,4)));	        
        
        if exist('normpdf','file'), 
                fun='normpdf'; 
        elseif exist('normal_pdf','file'),
                fun='normal_pdf';
        end;
        r(29,k) = (feval(fun,k,k,0)~=Inf)*k;	        
        if exist('normcdf','file'), 
                fun='normcdf'; 
        elseif exist('normal_cdf','file'),
                fun='normal_cdf';
        end;
        r(30,k) = feval(fun,4,4,0);	        
        if exist('norminv','file'), 
                fun='norminv'; 
        elseif exist('normal_inv','file'),
                fun='normal_inv';
        end;
        r(31,k) = k*any(isnan(feval(fun,[0,1],4,0)));	        
        if exist('nansum','file'),
        	r(32,k)=k*isnan(nansum(nan));
        end;
        if exist('nanstd','file'),
        	r(33,k)=k*(~isnan(nanstd(0)));
        end;
end;

% check if result is correct
tmp = abs(r(:,1)-r(:,2))<eps;

q = zeros(1,5);

% output
if all(tmp) && all(~q),
        fprintf(1,'NANINSTTEST successful - your NaN-tools are correctly installed\n');
else
        fprintf(1,'NANINSTTEST %i not successful \n', find(~tmp));
	fprintf(1,'The following functions contain a NaN-related bug:\n');
	fprintf(1,'  - %s\n',funlist{find(~tmp)});
	fprintf(1,'Its recommended to install the NaN-toolbox.\n');
end;

%warning(FLAG_WARNING);


