function Q=quantile(Y,q)
% QUANTILE calculates the quantiles of histograms or sample arrays.  
%
%  Q = quantile(Y,q)      
%     returns the q-th quantile of each column of sample array Y
%
%  Q = quantile(HIS,q)
%     returns the q-th quantile from the histogram HIS. 
%     HIS must be a HISTOGRAM struct as defined in HISTO2 or HISTO3.
%
% If q is a vector, the each row of Q returns the q(i)-th quantile 
%
% see also: HISTO2, HISTO3, PERCENTILE

% QUANTILES demonstrates how to calculate quantiles 
%
% q-quantile Q of data series Y 
% (1) explicite form
%	tmp=sort(Y);
%	N=sum(~isnan(Y));
%	Q = flix(tmp,N*q + 0.5);
%
% (2) in 1 line
%	Q = flix(sort(Y),sum(~isnan(Y))*q + 0.5);
%
% (3) q-quantile Q of histogram H with bins t
%	tmp=HISTOG>0;
%	HISTOG=full(HISTOG(tmp));
%	t = t(tmp);
%	N = sum(HISTOG);
%	tmp = cumsum(HISTOG)-N*q;
%
%	if ~any(~tmp), 
%		Q(k) = t(find(diff(sign(tmp)))+1);
%	else
%		Q(k) = mean(t(find(~tmp)+(0:1)));
%	end;	

%	$Id$
%	Copyright (C) 1996-2003,2005 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/


if nargin<2,
	help quantile
        
else
        SW = isstruct(Y);
        if SW, SW = isfield(Y,'datatype'); end;
        if SW, SW = strcmp(Y.datatype,'HISTOGRAM'); end;
        if SW,                 
                [yr,yc]=size(Y.H);
                Q = repmat(nan,length(q),yc);
                if ~isfield(Y,'N');
                        Y.N = sum(Y.H,1);
                end;
                
                for k1=1:yc,
                        tmp=Y.H(:,k1)>0;
                        h=full(Y.H(tmp,k1));
                        t = Y.X(tmp,min(size(Y.X,2),k1));
                        for k2 = 1:length(q),
                                tmp = cumsum(h)-Y.N(k1)*q(k2);
                                if ~any(~tmp), 
                                        Q(k2,k1) = t(find(diff(sign(tmp)))+1);
                                else
                                        Q(k2,k1) = mean(t(find(~tmp)+(0:1)));
                                end;	        
                        end
                end;
                
        elseif isnumeric(Y),
                [yr,yc] = size(Y);
                Q = repmat(nan,length(q),yc);
		
                N = sum(~isnan(Y),1);
                Y(isnan(Y)) = inf;   % making sure NaN's are at the end;
                
                Y = sort(Y,1);
                
		for k1 = 1:yc,
                        Q(:,k1) = flix(Y(1:N,k1),N(k1)*q + 0.5);                	        
                end;
                
        else
                fprintf(2,'Error QUANTILES: invalid input argument\n');
                return;
        end;
        
end;



