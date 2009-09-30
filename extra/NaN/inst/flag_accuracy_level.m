function FLAG = flag_accuracy_level(i)
% FLAG_ACCURACY_LEVEL sets and gets accuracy level 
%   used in SUMSKIPNAN_MEX and COVM_MEX
%   The error margin of the naive summation is N*eps (N is the number of samples),
%   the error margin is only 2*eps if Kahan's summation is used [1].    
%
%	0: maximum speed and minimum accuracy (error = N*2^-52) 
%	   of double (64bit float) without Kahan summation  
%	1: {default] accuracy of extend double (80bit float) 
%	   without Kahan summation (error = N*2^-64) 
%	2: minimum speed and minimum accuracy (error = 2^-64) 
%	   of double with Kahan summation  
%	3: accuracy (error = 2^-52) 
%	   of double (64bit float) with Kahan summation  
%
%   First tests suggest that 1 is a good solution
% 
% FLAG = flag_accuracy_level()
% 	gets current level
%
% flag_accuracy_level(FLAG)% 	sets mode 
% 
% This function is experimental and might disappear without further notice, 
% so donot rely on it.
%
% Reference:
% [1] David Goldberg, 
%       What Every Computer Scientist Should Know About Floating-Point Arithmetic
%       ACM Computing Surveys, Vol 23, No 1, March 1991. 


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
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%	$Id$
% 	Copyright (C) 2009 by Alois Schloegl <a.schloegl@ieee.org>
%       This function is part of the NaN-toolbox
%       http://hci.tu-graz.ac.at/~schloegl/matlab/NaN/


persistent FLAG_ACCURACY_LEVEL;

%% if strcmp(version,'3.6'), FLAG_ACCURACY_LEVEL=1; end;	%% hack for the use with Freemat3.6

%%% set DEFAULT value of FLAG
if isempty(FLAG_ACCURACY_LEVEL),
	FLAG_ACCURACY_LEVEL = 1; 
end;

if nargin>0,
	if (i>3) i=3; end;
	if (i<0) i=0; end;
	FLAG_ACCURACY_LEVEL = double(i); 
end;
FLAG = FLAG_ACCURACY_LEVEL;

