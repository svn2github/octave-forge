function Q=percentile(Y,q,DIM)
% PERCENTILE calculates the percentiles of histograms and sample arrays.  
%
%  Q = percentile(Y,q)      
%  Q = percentile(Y,q,DIM)      
%     returns the q-th percentile along dimension DIM of sample array Y.
%     size(Q) is equal size(Y) except for dimension DIM which is size(Q,DIM)=length(Q)
%
%  Q = percentile(HIS,q)
%     returns the q-th percentile from the histogram HIS. 
%     HIS must be a HISTOGRAM struct as defined in HISTO2 or HISTO3.
%     If q is a vector, the each row of Q returns the q(i)-th percentile 
%
% see also: HISTO2, HISTO3, QUANTILE

%	$Id$
%	Copyright (C) 1996-2003,2005,2006 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/


if nargin<3,
        DIM = [];
end;
if isempty(DIM),
        DIM = min(find(size(Y)>1));
        if isempty(DIM), DIM = 1; end;
end;


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
		sz = size(Y);
		if DIM>length(sz),
		        sz = [sz,ones(1,DIM-length(sz))];
		end;

		D1 = prod(sz(1:DIM-1));
		D3 = prod(sz(DIM+1:length(sz)));
		Q  = repmat(nan,[sz(1:DIM-1),length(q),sz(DIM+1:length(sz))]);
		for k = 0:D1-1,
		for l = 0:D3-1,
		        xi = k + l * D1*sz(DIM) + 1 ;
			xo = k + l * D1*length(q) + 1;
		        t  = Y(xi:D1:xi+D1*sz(DIM)-1);
		        t  = sort(t(~isnan(t)));
		        n  = length(t); 
			
			Q(xo:D1:xo+D1*length(q)-1) = flix(t, n*q'/100 + 0.5);
		end;
		end;


	elseif 0, 	% alternative implementation 
		sz = size(Y);
		sz = sz([DIM,1:DIM-1,DIM+1:length(sz)]);
		yr = prod(sz(2:end));
		Y  = reshape(permute(Y,[DIM,1:DIM-1,DIM+1:length(sz)]),sz(1),yr);
			
                N  = sum(~isnan(Y),1);
                Y(isnan(Y)) = inf;   % making sure NaN's are at the end;
    		Y  = sort(Y,1);
		
                Q  = repmat(nan,length(q),yr);
		for k1 = 1:yr,
                        Q(:,k1) = flix(Y(:,k1),N(k1)*q'/100 + 0.5);                	        
                end;
                sz(1) = length(q);
                Q  = ipermute(reshape(Q,sz),[DIM,1:DIM-1,DIM+1:length(sz)]);


        else
                fprintf(2,'Error PERCENTILE: invalid input argument\n');
                return;

        end;
        
end;



