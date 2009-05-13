function [F,X,FLO,FUP]=ecdf(h,Y)
% ECDF empirical cumulative function  
%  Missing values (encoded as NaN) are ignored. 
%
%  [F,X] = ecdf(Y)
%	calculates empirical cumulative distribution functions (i.e Kaplan-Meier estimate)
%  ecdf(Y)
%  ecdf(gca,Y)
%	without output arguments plots the empirical cdf, in axis gca. 
%
% see also: HISTO2, HISTO3, PERCENTILE, QUANTILE


%	$Id$
%	Copyright (C) 2009 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/

%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; If not, see <http://www.gnu.org/licenses/>.

if ~isscalar(h) || ~ishandle(h) || isstruct(h),
	Y = h; 
	h = []; 
end; 	

DIM = [];

        SW = isstruct(Y);
        if SW, SW = isfield(Y,'datatype'); end;
        if SW, SW = strcmp(Y.datatype,'HISTOGRAM'); end;
        if SW,                 
                [yr,yc]=size(Y.H);
                if ~isfield(Y,'N');
                        Y.N = sum(Y.H,1);
                end;
                
                for k1 = 1:yc,
                        tmp = Y.H(:,k1)>0;
                        f = [0;cumsum(full(Y.H(tmp,k1)))];
                        t = Y.X(tmp,min(size(Y.X,2),k1));

			N = Y.N(k1);  
		end; 	

        elseif isnumeric(Y),
		sz = size(Y);
		if sum(sz>1)>1
			error('input argument is not a vector')
		end; 

	        t  = sort(Y(~isnan(Y)));
	        N  = length(t); 
		f  = [0:N]'/N;
	end; 
	
	
	if nargout<1, 
		if  ~isempty(h), axes(h); end; 
		%plot(t2,x);
		stairs([t(1);t(:)],f)
	else 
		F = f;
		X = [t(1),t]'; 	
	end; 			
