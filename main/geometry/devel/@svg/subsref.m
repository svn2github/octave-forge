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

# Error strings
  method4field = "Class %s has no field %s. Use %s() for the method.";
  typeNotImplemented = "%s no implemented for Class %s.";
  
  method = idx(1).subs;

  switch method
    case 'plot'
    
     if numel (idx) == 1 % obj.plot doesn't exists
       error (method4field, class (obj), method, method);
     elseif strcmp (idx(2).type, '()')
        out = plot (obj, idx(2).subs);
     else 
       error (typeNotImplemented,[method idx(2).type], class (obj));
     end
      
    case 'getpath'

     if numel (idx) == 1 % obj.getpath doesn't exists
       error (method4field, class (obj), method, method);
     elseif strcmp (idx(2).type, '()')
        out = getpath (obj, idx(2).subs);
     else 
       error (typeNotImplemented,[method idx(2).type], class (obj));
     end

    case 'pathid'
      out = fieldnames(obj.Path);

    otherwise
      error ("invalid index for reference of class %s", class (obj) );
  endswitch

endfunction
