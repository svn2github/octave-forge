## Copyright (C) 1999 Daniel Heiserer
##
## This program is free software. It is distributed in the hope that it
## will be useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
## the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file; see the file COPYING.  If not, write to the
## Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## patch creates a pseudo-shaded patch with a black boundary
## USAGE: 
##     PATCH(X,Y,Z,C) 
##     X x-coordinates of the patch
##     Y y-coordinates of the patch
##     Z z-coordinates of the patch
## 
##    See also FILL, FILL3.

## AUTHOR: Daniel Heiserer <Daniel.heiserer@physik.tu-muenchen.de>
## 2001-01-16 Paul Kienzle
## * handle 2d and 3d, reformatting, unwind protect

function patch(x,y,z,c)

  if nargin==3
    c=z;
  end

  if nargin<3 || nargin>4
    usage("patch (x, y [, z], c)");
  end
  c=[c(1),';;'];
  borderc=['k;;'];

  if nargin == 3
    if any (size(x) != size(y))
      error('x and y must have the same size');
    end

    fill(x,y,c);
    held = ishold;
    unwind_protect
      hold on
      X=[x,x(1)];
      Y=[y,y(1)];
      plot(X,Y,borderc);
    unwind_protect_cleanup
      if (!held) hold off; endif
    end_unwind_protect
  else
    if any (size(x) != size(y)) || any (size(x) != size(z))
      error('x, y and z must have the same size');
    end
      
    fill3(x,y,z,c);
    held = ishold;
    unwind_protect
      hold on
      X=[x,x(1)];
      Y=[y,y(1)];
      Z=[z,z(1)];
      plot3(X,Y,Z,borderc);
    unwind_protect_cleanup
      if (!held) hold off; endif
    end_unwind_protect
  endif

endfunction
