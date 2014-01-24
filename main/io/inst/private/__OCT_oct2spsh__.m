## Copyright (C) 2014 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} __OCT_oct2spsh__ (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuiS at users dot sf dot net>
## Created: 2014-01-24

function [ ods, rstatus ] = __OCT_oct2spsh__ (c_arr, ods, wsh, crange, spsh_opts)

  if (strcmpi (ods.app, "ods"))
    ## Write to .ods
    [ ods, rstatus ] = __OCT_oct2ods__  (c_arr, ods, wsh, crange, spsh_opts);

  elseif (strcmpi (ods.app, "xlsx"))
    ## Write to .xlsx
    [ ods, rstatus ] = __OCT_oct2xlsx__ (c_arr, ods, wsh, crange, spsh_opts);

  elseif (strcmpi (ods.app, "gnumeric"))
    ## Write to .gnumeric
    [ ods, rstatus ] = __OCT_oct2gnm__  (c_arr, ods, wsh, crange, spsh_opts);

  else
    error ("writing to file type %s not supported by OCT", xls.app);

  endif

endfunction
