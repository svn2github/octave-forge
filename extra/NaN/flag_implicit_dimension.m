function DIM=flag_implicit_dimension(i)
% The use of FLAG_IMPLICIT_DIMENSION is in experimental state. 
% FLAG_IMPLICIT_DIMENSION might even become obsolete.
% Do not use it. 

% FLAG_IMPLICIT_DIMENSION sets and gets default mode for handling NaNs
% The default DIM argument is stored in the global variable FLAG_implicit_dimension
% The idea is that the DIM-argument is not necessary. This might enable 
% more readable code. 
% 
%   flag_implicit_dimension(0) 
%	calculation along first non-singleton dimension
%   flag_implicit_dimension(1) 
%	calculation along columns
%   flag_implicit_dimension(2) 
%	calculation along rows
% 
% DIM = flag_implicit_dimension()
% 	gets default mode
%
% flag_implicit_dimension(DIM)
% 	sets default DIM
%
% DIM = flag_implicit_dimension(DIM)
%	gets and sets DIM 
%
% features:
% - compatible to Matlab and Octave
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

%	Version 1.17;	17 Mar 2002
%	Copyright (c) 2000-2002 by  Alois Schloegl
%	a.schloegl@ieee.org	

global FLAG_implicit_dimension; 

%%% check whether FLAG was already defined 
if exist('FLAG_implicit_dimension')~=1,
	FLAG_implicit_dimension = 0;
end;

if isempty(FLAG_implicit_dimension),
	FLAG_implicit_dimension = 0;
end;

if nargin>0,
        fprintf(2,'Warning: FLAG_IMPLICIT_DIMENSION is in an experimental state\n');
        fprintf(2,'It might become obsolete.\n');
        FLAG_implicit_dimension = i; 
end;    

DIM = FLAG_implicit_dimension;
