function FLAG=flag_implicit_skip_nan(i)
% In future FLAG_IMPLICIT__SKIP_NAN might become obsolete. 
% Do not use it. 

% FLAG_IMPLICIT_SKIP_NAN sets and gets default mode for handling NaNs
%	1 skips NaN's (the default mode if no mode is set)
% 	0 NaNs are propagated; input NaN's give NaN's at the output
% 
% FLAG = flag_implicit_skip_nan()
% 	gets default mode
%
% flag_implicit_skip_nan(FLAG)
% 	sets default mode 
%
% prevFLAG = flag_implicit_unbiased_estimation(nextFLAG)
%	gets previous set FLAG and sets FLAG for the future
%
% The mode is stored in the global variable FLAG_implicit_skip_nan
% It is recommended to use flag_implicit_skip_nan(1) as default and 
% flag_implicit_skip_nan(0) should be used for exceptional cases only. 
% 
% features:
% - compatible to Matlab and Octave
% - global FLAG_implicit_skip_nan
%
% see also: SUMSKIPNAN, MEAN, STD, VAR, SKEWNESS, KURTOSIS, MOMENT, STATISTIC
%	MEDIAN, GEOMEAN, HARMMEAN, MAD, ZSCORE, MEANSQ, RMS, SUMSQ, SEM, 
% 	COEFFICIENT_OF_VARIATION

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

%	Version 1.15
%	12 Mar 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl
%	a.schloegl@ieee.org	

global FLAG_implicit_skip_nan; 

%%% check whether FLAG was already defined 
if exist('FLAG_implicit_skip_nan')~=1,
	FLAG_implicit_skip_nan = [];
end;

%%% set DEFAULT value of FLAG
if isempty(FLAG_implicit_skip_nan),
	FLAG_implicit_skip_nan = (1==1); %logical(1); % logical.m not available on 2.0.16
end;

FLAG = FLAG_implicit_skip_nan;
if nargin>0,
        fprintf(2,'Warning: FLAG_IMPLICIT_SKIP_NAN might become obsolete in future\n');
        
        FLAG_implicit_skip_nan = (i~=0); %logical(i); %logical.m not available in 2.0.16 
end;    
