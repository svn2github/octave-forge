## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{parser} =} addOptional (@var{parser}, @var{argname}, @var{default})
## @deftypefnx {Function File} {@var{parser} =} @var{parser}.addOptional (@var{argname}, @var{default})
## @deftypefnx {Function File} {@var{parser} =} addOptional (@var{parser}, @var{argname}, @var{default}, @var{validator})
## @deftypefnx {Function File} {@var{parser} =} @var{parser}.addOptional (@var{argname}, @var{default}, @var{validator})
## Add new optional argument to the object @var{parser} of the class inputParser
## to implement an ordered arguments type of API 
##
## @var{argname} must be a string with the name of the new argument. The order
## in which new arguments are added with @command{addOptional}, represents the
## expected order of arguments.
##
## @var{default} will be the value used when the argument is not specified.
##
## @var{validator} is an optional anonymous function to validate the given values
## for the argument with name @var{argname}. Alternatively, a function name
## can be used.
##
## @emph{Note}: if @command{ParamValue} arguments are also specified, all @command{Optional}
## arguments will have to be specified before.
##
## @seealso{inputParser, @@inputParser/addParamValue
## @@inputParser/addParamValue, @@inputParser/addRequired, @@inputParser/parse}
## @end deftypefn

function inPar = addOptional (inPar, name, def, val)

  ## check @inputParser/subsref for the actual code
  if (nargin == 3)
    inPar = subsref (inPar, substruct(
                                      '.' , 'addOptional',
                                      '()', {name, def}
                                      ));
  elseif (nargin == 4)
    inPar = subsref (inPar, substruct(
                                      '.' , 'addOptional',
                                      '()', {name, def, val}
                                      ));
  else
    print_usage;
  endif

endfunction
