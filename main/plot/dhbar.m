## Copyright (C) 1999 Daniel Heiserer
##
## This program is free software.  It is distributed in the hope that it
## will be useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
## the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file; see the file COPYING.  If not, write to the
## Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## BAR create Bar graph
## USAGE: 
##     BAR(X) creates a bar plot using the colums of the m x n Matrix X
##     as columns of the bars. The rows of X will 
## 
##     BAR(...,'stack') creates a vertical bar chart. 
##     BAR(...,'group') creates a horizontal bar chart.
## 
## 
##     e.g.: bar(rand(3,5),'stack')
## 
##    See also FILL, PATCH.

## REMARK: fakes gnuplots unability of plotting shaded patches
## AUTHOR: Daniel Heiserer <Daniel.heiserer@physik.tu-muenchen.de>
## 2001-01-16 Paul Kienzle
## * reformatting, unwind protect, compatible style names

function dhbar(X,btype)

  if nargin<2
    btype='stack';
  end
  if isstr(btype)~=1
    error('second argument has to be a string!!!!');
  end

  barwidth=0.8;
  bw2=barwidth/2;

  ## uups. I did it the wrong way, this helps:
  X=X';

  held = ishold;
  unwind_protect

    if min(size(X))==1
      ## oh nice only single bars
      for jj=1:length(X)
      	patch(jj + [-bw2, -bw2, bw2, bw2], [ 0, X(jj), X(jj), 0 ], 'r');
    	hold on
      endfor
    else
      if btype=='group'
      	## we have to change the barwidth:
      	barwidth=0.8;
      	bw=barwidth;
      	for jj=1:size(X,1)
	  for kk=1:size(X,2)
	    patch(jj + ([-1,-1,0,0]+kk-size(X,2)/2)./size(X,2)*bw,...
		  [ 0, X(jj,kk),  X(jj,kk), 0 ], num2str(kk));
	    hold on
	  endfor
      	endfor
      elseif btype=='stack'
      	for jj=1:size(X,1)
	  for kk=1:size(X,2)
	    patch(jj + [-bw2, -bw2, bw2, bw2],...
		  sum(X(jj,1:kk-1)) + [0,X(jj,kk),X(jj,kk),0], num2str(kk));
	    hold on
	  endfor
      	endfor	
      else
      	error("patch: unknown type %s; use 'stack' or 'group'", btype);
      endif
    endif

  unwind_protect_cleanup
    if (!held) hold off; end;
  end_unwind_protect

endfunction
