function [o,count,SSQ,S4M] = sumskipnan(i,DIM)
% SUMSKIPNAN adds all non-NaN values. 
%
% All NaN's are skipped; NaN's are considered as missing values. 
% SUMSKIPNAN of NaN's only  gives O; and the number of valid elements is return. 
% SUMSKIPNAN is also the elementary function for calculating 
% various statistics (e.g. MEAN, STD, VAR, RMS, MEANSQ, SKEWNESS, 
% KURTOSIS, MOMENT, STATISTIC etc.) from data with missing values.  
% SUMSKIPNAN implements the DIMENSION-argument for data with missing values.
% Also the second output argument return the number of valid elements (not NaNs) 
% 
% Y = sumskipnan(x [,DIM])
% [Y,N,SSQ] = sumskipnan(x [,DIM])
% 
% DIM	dimension
%	1 sum of columns
%	2 sum of rows
%	default or []: first DIMENSION with more than 1 element
%
% Y	resulting sum
% N	number of valid (not missing) elements
% SSQ	sum of squares
%
% The mean & standard error of the mean and 
%	Y./N & sqrt((SSQ-Y.*Y./N)./(N.*max(N-1,0))); 
% the mean square & the standard error of the mean square and
% 	SSQ./N & sqrt((S4M-SSQ.^2./N)./(N.*max(N-1,0)))
%
% features:
% - can deal with NaN's (missing values)
% - implements dimension argument. 
% - compatible with Matlab and Octave
%
% see also: SUM, NANSUM, MEAN, STD, VAR, RMS, MEANSQ, 
%      SSQ, MOMENT, SKEWNESS, KURTOSIS, SEM


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
%    Copyright (C) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>	


if nargin<2,
        DIM=min(find(size(i)>1));
        if isempty(DIM), DIM=1; end;
end;




if (DIM<=2) & (length(size(i))<3) & flag_implicit_skip_nan & (exist('sumskipnan2')==3) & isreal(i);
                
	% an efficient implementation in C of the following lines 
        % could significantly increase performance 
        % only one loop and only one check for isnan is needed
        %
        % Outline of the algorithm: 
        % for { k=1,o=0,count=0; k++; k<N} 
        % 	if ~isnan(i(k)) 
        % 	{ 	o     += i(k);
        %               count += 1;
        %		tmp    = i(k)*i(k)
        %		o2    += tmp;
        %		o3    += tmp.*tmp;
        %       }; 
        
	% explicit type conversion
	if islogical(i) | ischar(i),
		i = real(i);
	end;	

        % use MEX-file SUMSKIPNAN2 from Patrick Houweling <phouweling@yahoo.com>
        switch nargout,
        case {0,1,2}
                [o, count] = sumskipnan2(i, DIM);
        case 3
                [o, count, SSQ] = sumskipnan2(i, DIM);
        case 4
                [o, count, SSQ, S4M] = sumskipnan2(i, DIM);
        end              
                
else  
        if nargout>1
                count = sum(~isnan(i),DIM); 
        end;
        if flag_implicit_skip_nan, %%% skip always NaN's
                i(isnan(i)) = 0;
        end;
        o = sum(i,DIM);
        if nargout>2,
                i = i.^2;
                SSQ = sum(i,DIM);
                if nargout>3,
                        S4M = sum(i.^2,DIM);
                end;
        end;
end;

