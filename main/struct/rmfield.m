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

##        t = rmfield(s,key1,...)
## 
## Removes key1, key2, ...  from structure s. 
## Return s if s is not a struct. Any better behavior?
## 
## Basically, does a 'filtering' copy of s.
##
## See also cmpstruct, fields, setfield, isstruct, getfield, isfield,
## catstruct and struct. 
##

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: January 2000
## November 2000: Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##     return error rather than trapping to keyboard

function t = rmfield(s,varargin)
if ! is_struct(s) ,			
  t = s ;
  return
end

rmf = ' ';
for arg=1:length(varargin)
  tmp = nth (varargin, arg) ;
  if ! isstr(tmp) ,
    error('rmfield: called with non-string key');
  else
    rmf = [rmf,tmp,' '] ;
  end
end
for [val, key] = s ,
  if ! index(rmf,[' ',key,' ']) ,	% Check if key is wanted
    eval(['t.',key,'=val;']) ;		% Copy
  end
end
