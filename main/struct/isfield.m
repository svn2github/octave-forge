## Copyright (C) 2000  Etienne Grossmann
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

##       y = isfield(x,k) == struct_contains (x, k)
##
## Returns 1 if x is a struct and k a string, and x.k exists.
## Returns 0 otherwise. 
##
## For m****b compat and flexibility.
##
## See also struct_contains, cmpstruct, fields, setfield, rmfield, getfield,
## isstruct, struct. 

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: January 2000

function y = isfield(x,k)
  if isstruct(x)
    y = struct_contains (x, k);
    ## eval(sprintf('x.%s;y=1;',k),'y=0;');
  else
    y = 0 ;
  end
end
