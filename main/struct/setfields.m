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

##        s = setfields(s,'key1',value1,...)
## 
## Sets s.key1 = value1,  s.key2 = value2, ... and returns s.
## 
## For some compatibility and flexibility.
## 
## See also cmpstruct, fields, rmfield, isstruct, getfields, isfield,
## struct. 
## 

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: January 2000
## November 2000: Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##     return error rather than trapping to keyboard

function s = setfields(s,varargin)
if nargin == 0
  s= struct; % doesn't work on older versions of octave
elseif rem(nargin,2) != 1,
  error('setfields: expected struct, key1, val1, key2, val2, ...\n') ; 
endif
	
for i=1:2:nargin-1
  if ! ischar(varargin{i}) ,
    error('setfields: called with non-string key') ; 
  else
    s.(varargin{i}) = varargin{i+1};
  end
end
