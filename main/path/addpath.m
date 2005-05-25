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

## -*- texinfo -*-
## @deftypefn {Function File} {} addpath(dir1, ...)
##
## Prepends @code{dir1}, @code{...} to the current @code{LOADPATH}.
## 
## @example
## addpath(dir1,'-end',dir2,'-begin',dir3,'-END',dir4,'-BEGIN',dir5)
## @result{} Prepends dir1, dir3 and dir5 and appends dir2 and dir4. 
## @end example
##
## An error will be returned if the string is not a directory, the
## directory doesn't exist or you don't have read access to it.
##
## BUG : Can't add directories called @code{-end} or @code{-begin} (case
## insensitively)
##
## @end deftypefn

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Modified-By:   Bill Denney <bill@givebillmoney.com>
## Last modified: March 2005

function addpath(varargin)

  app = 0 ;			# Append? Default is 'no'.
  for arg=1:length(varargin)
    p = nth (varargin, arg) ;
    if strcmpi(p,"-end"),
      app = 1 ;
    elseif strcmpi(p,"-begin"),
      app = 0 ;
    else
      pp = p ;
      ## Not needed
      ## while rindex(pp,"/") == size(pp,2), pp = pp(1:size(pp,2)-1) ; end
      [s,err,m] = stat(pp) ;		# Check for existence
      if err,
	error("addpath %s : %s\n",pp,m);
      elseif index(s.modestr,"d")!=1,
	error("addpath %s : not a directory (mode=%s)\n",pp, s.modestr);

      elseif !((s.modestr(8) == 'r') || ...
	       ((getgid == s.gid) && (s.modestr(5) == 'r')) || ...
	       ((getuid == s.uid) && (s.modestr(2) == 'r')))
	error("addpath %s : not readable (mode=%s)\n", pp,s.modestr);
      elseif ! app,
	LOADPATH = [p,':',LOADPATH] ;
      else
	LOADPATH = [LOADPATH,':',p] ;
      end
    end
  end
    
