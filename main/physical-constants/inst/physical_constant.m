## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
## Copyright (C) 2014 Carlo de Falco 
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{names}] =} physical_constant
## @deftypefnx {Function File} {[@var{val}, @var{uncertainty}, @var{unit}] =} physical_constant (@var{name})
## @deftypefnx {Function File} {[@var{constants}] =} physical_constant ("all")
## Get physical constant @var{arg}.
##
## If no arguments are given, returns a cell array with all possible @var{name}s.
## Alternatively, @var{name} can be `all' in which case @var{val} is a structure
## array with 4 fields (name, value, uncertainty, units).
##
## Since the long list of values needs to be parsed on each call to this function
## it is much more efficient to store the values in a variable rather make multiple
## calls to this function with the same argument
##
## The values are the ones recommended by CODATA retrieved on 22-Jan-2014
## from NIST database at @uref{http://physics.nist.gov/constants}
## @end deftypefn

function [rval, uncert, unit] = physical_constant (arg)

  persistent unit_data;
  if (isempty (unit_data))
    unit_data = get_physical_constant_data;
  endif

  if (nargin > 1 || (nargin == 1 && ! ischar (arg)))
    print_usage;
  elseif (nargin == 0)
    rval = reshape ({unit_data(:).name}, size (unit_data));
    return
  elseif (nargin == 1 && strcmpi (arg, "all"))
    rval = unit_data;
    return
  endif

  val = reshape ({unit_data(:).name}, size (unit_data));
  map = strcmpi (val, arg);
  if (any (map))
    val     = unit_data(map);
    rval    = val.value;
    uncert  = val.uncertainty;
    unit    = val.units;
  else
    error ("No constant with name '%s' found", arg)
  endif
endfunction


