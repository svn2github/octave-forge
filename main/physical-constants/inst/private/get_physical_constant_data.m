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
## @deftypefn {Function File} {} __run_test_suite__ (@var{fcndirs}, @var{fixedtestdirs})
## Undocumented internal function.
## @end deftypefn

function unit_data = get_physical_constant_data

  octave_physical_constants_data;

  name = toupper (strtrim (ccell(:, 1)));

  value = num2cell (str2double ...
                      (regexprep ...
                         (strtrim (ccell(:, 2)), 
                          {' ', '\.\.\.'}, '')), 2);

  uncertainty = num2cell ...
                  (str2double ...
                     (regexprep ...
                        (strtrim (ccell(:, 3)), 
                         {' ', '\.\.\.'}, '')), 2);

  units = strtrim (ccell(:, 4));

  unit_data = cell2struct ...
                ([name(:), value(:), uncertainty(:), units(:)],
                 {"name", "value", "uncertainty", "units"}, 2);
  
endfunction
