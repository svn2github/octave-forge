## Copyright (C) 1999 Daniel Heiserer
##
## This program is free software.  It is distributed in the hope that it
## will be useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
## the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file; see the file COPYING.  If not, write to the
## Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## FILL creates a pseudo-shaded patch 
## USAGE: 
##     FILL(X,Y,C) 
##     X x-coordinates of the patch
##     Y y-coordinates of the patch
##     C colour code as given by plot
## 
##    See also PATCH.

## AUTHOR: Daniel Heiserer <Daniel.heiserer@physik.tu-muenchen.de>
## 2001-01-16 Paul Kienzle
## * reformatting, small speedup, unwind protect

function fill(x,y,c)

  if nargin!=3
    usage("fill (x,y,c)");
  end
  
  col = 'rgbcmy';
  c=[col(c(1)),';;'];
  
  xs=size(x);
  ys=size(y);
  
  if ys~=xs
    error('x and y have to have the same size');
  end
  
  ys=max(ys);
  xs=max(xs);
  
  
  ## What do we do, if we dont have a quad?

  if ys<3
    ##	error('Area only defined for at least 3 coordinates')
    ## should I care?
    x(2)=x(1);
    y(2)=y(1);
    x(3)=x(2);
    y(3)=y(2);
    x(4)=x(3);
    y(4)=y(3);
  elseif ys==3
    ## a triangle, merge node 4 to 1
    x(4)=x(1);
    y(4)=y(1);
  elseif ys>4
    ## ok we have to split it into multiple trias,  quads look ugly 
    held = ishold;
    unwind_protect
      for jj=3:ys
      	fill([x(1),x(jj-1),x(jj)],[y(1),y(jj-1),y(jj)],c);
      	hold on;
      end
    unwind_protect_cleanup
      if (!held), hold off; end;
    end_unwind_protect
  end


  ## well as long as gnuplot has no fill function ...
  ## we do it ourselves ....
  ## maybe this looks really ugly if we have to fill
  ## lots of triangles which should represent a polygon
  ## but this approach has an excellent effort/work relationship 
  ## (maybe we are a little to economic here ;-)) ...
  ## improveme!!!!
  ## ok we assume our patch looks like this:
  ##
  ##      2+-------------------+3
  ##       |                   |
  ##       |                   |
  ##       |                   |
  ##       |                   |
  ##       |                   |
  ##      1+-------------------+4
  ##
  ## and we want to have something like this:
  ##
  ##      2+-------------------+3
  ##       | | | | | | | | | | |
  ##       | | | | | | | | | | |
  ##       | | | | | | | | | | |
  ##       | | | | | | | | | | |
  ##      1+-------------------+4
  ##
  ## for triangles we want to have only the grids 1-2-3

  ## so we create a spacing from 1:4 and 2:3 using 1/increments
  increments=50;
  X_14=x(1):(x(4)-x(1))/increments:x(4);
  X_23=x(2):(x(3)-x(2))/increments:x(3);
  ## the same for Y
  Y_14=y(1):(y(4)-y(1))/increments:y(4);
  Y_23=y(2):(y(3)-y(2))/increments:y(3);
  ## ok now assume x(1)==x(4) then the :: wouldn't generate anything
  if (length(X_14)==0)
    X_14=x(1)*ones(1,increments+1);
  end
  if (length(X_23)==0)
    X_23=x(2)*ones(1,increments+1);
  end
  if (length(Y_14)==0)
    Y_14=y(1)*ones(1,increments+1);
  end
  if (length(Y_23)==0)
    Y_23=y(2)*ones(1,increments+1);
  end
  
  X=[X_23;X_14];
  Y=[Y_23;Y_14];
  idx=2:2:increments+1;
  X(:,idx) = flipud(X(:,idx));
  Y(:,idx) = flipud(Y(:,idx));
  X=X(:);
  Y=Y(:);
  
  plot(X,Y,c)
  
endfunction
