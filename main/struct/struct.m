## Copyright (C) 2000  Etienne Grossman
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

##       s = struct(key1,val1,...)
## 
## Returns a struct such that s.key1 = val1 , s.key2 = val2 ...
##    
## For m****b compatibility.
##
## See also fields, getfield, setfield, rmfield, isfield, isstruct,
## cmpstruct, struct_size. 

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: January 2000
## November 2000: Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##     return error rather than trapping to keyboard

function s = struct(...)
va_start() ; 
while nargin-- ,
  tmp = va_arg() ;
  if ! isstr(tmp) ,
    error('struct: called with non-string key') ; 
  else
    if ! nargin-- ,
      error('struct: called with odd number of arguments') ; 
    else
      value = va_arg() ;
      eval(['s.',tmp,'=value;']) ;
    end
  end
end