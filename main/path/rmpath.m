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

##       rmpath(dir1,...)
##
## Removes dir1,... from the current LOADPATH.
## 

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: January 2000

function rmpath(varargin)

  for arg=1:length(varargin)
    p = nth (varargin, arg) ;
    lp = length(p) 
    printf("removing %s\n",p);
				# Nothing like perl for strings!
    np = LOADPATH ;
    lo = 0 ;
    while lo != length(np),	# Loop while I can substitute
      lo = length(np) ;
      np = strrep(np,[":",p,":"],":") ;
    end
    if length(np)>=lp,

				# Check at beginning
      f = index(np,p) ;
      if f == 1 ,
	printf("rmpath : removing from beginning\n") ;
	if length(np) == lp , 
	      np = "" ;
	elseif length(np) > lp && strcmp( np(lp+1),":" ) ,	
	  np = np(lp+2:length(np)) ;
	end
      end
				# Check at end
      f = rindex(np,p) ;
      if f == length(np)-lp+1 && length(np)-lp>0 && \
	    strcmp(np(length(np)-lp),":") ,
	printf("rmpath : removing from end\n") ;
	np = np(1:length(np)-lp-1) ;
      end
    end
  end
  ## LOADPATH
  ## np
  ## keyboard
  if !strcmp(LOADPATH,np),
    printf("rmpath : loadpath is changed\n") ;
    LOADPATH = np 
  end
