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

## s = fullfile(dir1, dir2, ..., filename)
##
## Joins all the arguments with "/"s,  suppresses multiple "/"s and
## substrings like "/./".
##
## Example : 
## > fullfile ("main/","/plot/./","plot.m")
## ans = main/plot/plot.m


## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: January 2000

function s = fullfile(varargin)
  filesep = "/" ;		# Change this for non-unix
  va_arg_cnt = 1;
  if nargin--, 
    s = nth (varargin, va_arg_cnt++); 
  else 
    s=""; 
    return
  end
  while nargin--,
    s=[s,filesep,nth (varargin, va_arg_cnt++)];
  end 
  t='';
  while !strcmp(t,s), 
    t=s;
    s=strrep(t,"/./","/");
    s=strrep(s,"//","/");
  end
endfunction
