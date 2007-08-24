function Q=quantile(Y,q,DIM)
% QUANTILE calculates the quantiles of histograms and sample arrays.  
%
%  Q = quantile(Y,q)
%  Q = quantile(Y,q,DIM)
%     returns the q-th quantile along dimension DIM of sample array Y.
%     size(Q) is equal size(Y) except for dimension DIM which is size(Q,DIM)=length(Q)
%
%  Q = quantile(HIS,q)
%     returns the q-th quantile from the histogram HIS. 
%     HIS must be a HISTOGRAM struct as defined in HISTO2 or HISTO3.
%     If q is a vector, the each row of Q returns the q(i)-th quantile 
%
% see also: HISTO2, HISTO3, PERCENTILE

% QUANTILES demonstrates how to calculate quantiles 
%
% q-quantile Q of data series Y 
% (1) explicite form
%	tmp=sort(Y);
%	N = sum(~isnan(Y));
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
%	Copyright (C) 1996-2003,2005,2006 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/

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
%    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

if nargin<3,
        DIM = [];
end;
if isempty(DIM),
        DIM = min(find(size(Y)>1));
        if isempty(DIM), DIM = 1; end;
end;


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
			
			Q(xo:D1:xo+D1*length(q)-1) = flix(t, n*q' + 0.5);
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
                        Q(:,k1) = flix(Y(:,k1),N(k1)*q' + 0.5);
                end;
                sz(1) = length(q);
                Q  = ipermute(reshape(Q,sz),[DIM,1:DIM-1,DIM+1:length(sz)]);


        else
                fprintf(2,'Error QUANTILES: invalid input argument\n');
                return;
        end;
        
end;



