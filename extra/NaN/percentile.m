function Q=percentile(Y,q)
% percentile calculates the quantiles of histograms or sample arrays.  
%
%  Q = percentile(Y,q)      
%     returns the q-th percentile of each column of sample array Y
%
%  Q = percentile(HIS,q)
%     returns the q-th percentile from the histogram HIS. 
%     HIS must be a HISTOGRAM struct as defined in HISTO2 or HISTO3.
%
% If q is a vector, the each row of Q returns the q(i)-th percentile 
%
% see also: FLIX, HISTO2, HISTO3, QUANTILE


%	$Revision$
%	$Id$
%	Copyright (C) 1996-2003 by Alois Schloegl
%	e-mail: a.schloegl@ieee.org	


if nargin<2,
	help percentile
        
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
                                tmp = cumsum(h)-Y.N(k1)*q(k2)/100;
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
		
		if flag_implicit_skip_nan,    % default 
	                N = sum(~isnan(Y),1);
	    	        Y(isnan(Y)) = inf;   % making sure NaN's are at the end;
		else   				% not supported
			N = size(Y,1)*ones(1,yc);
		end;
    		Y = sort(Y,1);
		
		for k1 = 1:yc,
	                for k2 = 1:length(q),
				Q(k2,k1) = flix(Y(:,k1),N(k1)*q(k2)/100 + 0.5);                	        
                	end;
                end;
                
        else
                fprintf(2,'Error PERCENTILE: invalid input argument\n');
                return;
        end;
        
end;



