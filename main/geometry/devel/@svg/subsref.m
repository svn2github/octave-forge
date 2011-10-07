## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
## @deftypefn {Function File} {} function_name ()
## @end deftypefn

function out = subsref (obj, idx)
  if ( !strcmp (class (obj), 'svg') )
    error ("object must be of the svg class but '%s' was used", class (obj) );
  elseif ( idx(1).type != '.' )
    error ("invalid index for class %s", class (obj) );
  endif

  ## the following at the end may allow to use the obj.method notation one day
#  ori = inputname(1);
#  assignin('caller', ori, inPar);

  method = idx(1).subs;

  switch method
    case 'plot'
      out = plot(obj);
    otherwise
      error ("invalid index for reference of class %s", class (obj) );
  endswitch

endfunction
