%       Copyright(C) 2011 Gianvito Pio, Piero Molino
%  
%       Contact Email: pio.gianvito@gmail.com piero.molino@gmail.com
%       
%	fl-core - Fuzzy Logic Core functions for Octave
%       This file is part of fl-core.
%       
%       fl-core is free software: you can redistribute it and/or modify
%       it under the terms of the GNU Lesser General Public License as published by
%       the Free Software Foundation, either version 3 of the License, or
%       (at your option) any later version.
%       
%       fl-core is distributed in the hope that it will be useful,
%       but WITHOUT ANY WARRANTY; without even the implied warranty of
%       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%       GNU Lesser General Public License for more details.
%       
%       You should have received a copy of the GNU Lesser General Public License
%       along with fl-core.  If not, see <http://www.gnu.org/licenses/>.
%


function res = fl_complement(A)
## -*- texinfo -*-
## @deftypefn{Function File} {@var{res} = } fl_complement(@var{A})
##
## Returns the Fuzzy Logic complement (1 - @var{A}). @var{A} can be a row vector or a column vector.
## @end deftypefn
	
	% Check the argument number	
	if (nargin != 1)
		print_usage();
	endif

	% Check the argument type
	if (isvector(A))

		% Check if the input vector is row vector or column vector
		if ((rows(A) == 1) && (columns(A) >= 1))
			% Calculate the complement as row vector
			res = ones(1, length(A)) - A;
		else
			% Calculate the complement as column vector
			res = ones(length(A), 1) - A;
		endif
	else
		error ("fl_complement: expecting vector argument");
	endif

endfunction
