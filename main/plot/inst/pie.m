## Copyright (C) 1999 Daniel Heiserer
##
## This program is free software.
##
## This file is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02110-1301, USA.

## pie(Y)
##    Produce pie graph 
##
## pie(Y,['label1';'label2';...;'labeln']);
##    Produce labelled pie graph

## AUTHOR: Daniel Heiserer <Daniel.heiserer@physik.tu-muenchen.de>
function pie(Y,desc)

  refinement=20;
  ##refinement=5;
  phi=0:refinement:360;
  Yphi=abs(Y)/sum(abs(Y))*360;
  Yphi=cumsum(Yphi);
  
  Yn=0:360/refinement:Yphi(1);
  if Yn(length(Yn))~=Yphi(1)
    Yn=[Yn,Yphi(1)];
  end

  held = ishold;
  unwind_protect
    patch([0,cos(Yn*2*pi/360)],[0,sin(Yn*2*pi/360)],num2str(1));
    hold on;
    for jj=2:length(Y)
      ## find how many degrees are inside the jj-th pie
      ## which degrees
      Yn=Yphi(jj-1):360/refinement:Yphi(jj);
      if length(Yn)>0
      	if Yn(length(Yn))~=Yphi(jj)
    	  Yn=[Yn,Yphi(jj)];
      	end
      	patch([0,cos(Yn*2*pi/360)],[0,sin(Yn*2*pi/360)],num2str(jj));
      else
      	
      end
    end
  
    ## reserve some place for a legend
    axis([-1 2 -1 1])
  
    ## ok assume we have some text here:
    if nargin==2
      if length(Y)~=size(desc,1)
      	error('pie-data and pie-string mismatch');
      end
      for jj=1:size(desc,1)
      	plot(0,0,[num2str(jj),';',desc(jj,:),';']);
      end
    end
  unwind_protect_cleanup
    if !held, hold off; end
  end_unwind_protect
end
  