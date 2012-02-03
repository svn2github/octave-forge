## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{p} =} ctmc_bd_solve (@var{birth}, @var{death})
##
## This function is deprecated and will be removed from future versions
## of the @code{queueing} toolbox. Please use @code{ctmc_bd()} instead.
##
## @seealso{ctmc_bd}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function p = ctmc_bd_solve( birth, death )
  warning("Function ctmc_db_solve() is deprecated and will be removed in the future. Please use ctmc_bd() instead.");
  p = ctmc_bd(birth, death);
endfunction
