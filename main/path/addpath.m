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

##       addpath(dir1,...)
##
## Prepends dir1,... to the current LOADPATH.
## 
##       addpath(dir1,'-end',dir2,'-begin',dir3,'-END',dir4,'-BEGIN',dir5)
## 
## Prepends dir1, dir3 and dir5 and appends dir2 and dir4. 
##
## For m****b compat.
## 
## BUG : Can't add directories called '-END', '-end', '-BEGIN' or '-begin'
##       Can't add directories that are not readable by their owner
##
## FEATURE : Won't add a string that is not a dir. 

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: January 2000

function addpath(varargin)

  app = 0 ;			# Append? Default is 'no'.
  for arg=1:length(varargin)
    p = nth (varargin, arg) ;
    if strcmp(p,"-end") | strcmp(p,"-END") ,
      app = 1 ;
    elseif strcmp(p,"-begin") | strcmp(p,"-BEGIN") ,
      app = 0 ;
    else
      pp = p ;
      ## Not needed
      ## while rindex(pp,"/") == size(pp,2), pp = pp(1:size(pp,2)-1) ; end
      [s,err,m] = stat(pp) ;		# Check for existence
      if err,
	printf("addpath : Stat on %s returns\n %s\n",pp,m);
      elseif index(s.modestr,"d")!=1,
	printf("addpath : >%s< is not a dir (mode=%s)\n",pp, s.modestr);

      elseif  index(s.modestr,"r")!=2, # Asume I'm owner. That's a bug

	printf("addpath : >%s< is not a readable (mode=%s)\n",...
	       pp,s.modestr);
      elseif ! app,
	LOADPATH = [p,':',LOADPATH] ;
      else
	LOADPATH = [LOADPATH,':',p] ;
      end
    end
  end
    
