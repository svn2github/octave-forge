## Copyright (C) 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Ql}, @var{Qu}] =} qnclosedgb (@var{N}, @var{D}, @var{Z})
##
## This function is deprecated. Please use @code{qncsgb} instead.
##
## @seealso{qncsgb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [X_lower X_upper Q_lower Q_upper] = qnclosedgb( N, D, Z )
  persistent warned = false;
  if (!warned)
    warned = true;
    warning("qn:deprecated-function",
	    "Function qnclosedgb is deprecated. Please use qncsgb instead");
  endif
  if ( nargin < 3 ) 
    [X_lower X_upper R_lower R_upper Q_lower Q_upper] = qncsgb( N, D );
  else
    [X_lower X_upper R_lower R_upper Q_lower Q_upper] = qncsgb( N, D, ones(size(D)), ones(size(D)), Z);
  endif
endfunction
