function FLAG=flag_implicit_unbiased_estim(i)
% In future FLAG_IMPLICIT_UNBIASED_ESTIM might become obsolete. 
% Do not use it. 
%

% IMPLICIT_UNBIASED_ESTIM sets and gets default estimation mode
%	1 gives unbiased estimates (the default mode if no mode is set)
% 	0 gives biased estimates
% 
% FLAG = flag_implicit_unbiased_estimation()
% 	gets default estimation mode
%
% flag_implicit_unbiased_estimation(FLAG)
% 	sets default estimation mode 
%
% prevFLAG = flag_implicit_unbiased_estimation(nextFLAG)
%	gets previous set FLAG and sets FLAG for the future
%
% The mode is stored in the global variable FLAG_implicit_unbiased_estimation
% It is recommended to use flag_implicit_unbiased_estim(1) as default and 
% flag_implicit_unbiased_estim(0) should be used for exceptional cases only. 
%
% features:
% - compatible to Matlab and Octave
% - global FLAG_implicit_unbiased_estim
%
% see also: STD, VAR, SKEWNESS, KURTOSIS, MOMENT, STATISTIC
%	MAD, ZSCORE, COEFFICIENT_OF_VARIATION

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

%	Version 1.16
%	14 Mar 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl
%	a.schloegl@ieee.org	



global FLAG_implicit_unbiased_estimation; 

%%% check whether FLAG was already defined 
if exist('FLAG_implicit_unbiased_estimation')~=1,
	FLAG_implicit_unbiased_estimation = [];
end;

%%% set DEFAULT value of FLAG
if isempty(FLAG_implicit_unbiased_estimation),
	FLAG_implicit_unbiased_estimation = (1==1); %logical(1);
end;

FLAG = FLAG_implicit_unbiased_estimation;
if nargin>0,
        fprintf(2,'Warning: FLAG_IMPLICIT_UNBIASED_ESTIM might become obsolete in future\n');
        
        FLAG_implicit_unbiased_estimation = (i~=0); %logical(i);
end;    
