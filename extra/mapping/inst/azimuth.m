## Copyright (C) 2004 Andrew Collier <abcollier@users.sourceforge.net>
##
## This program is free software; it is distributed in the hope that it
## will be useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
## the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file; see the file COPYING.  If not, write to the
## Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{az} = azimuth(@var{pt1}, @var{pt2})
##
## Calculates the great circle azimuth from @var{pt1} to @var{pt2}.
##
## @var{pt1} and @var{pt2} are two-column matrices of the form
## [latitude longitude].
##
## @example
## >> azimuth([10,10], [10,40])
## ans = 87.336
## >> azimuth([0,10], [0,40])
## ans = 90
## @end example
##
## @seealso{elevation,distance}
## @end deftypefn

## Author: Andrew Collier <abcollier@users.sourceforge.net>

## Uses "four-parts" formula.

function az = azimuth(pt1, pt2)
  pt1 = deg2rad(pt1);
  pt2 = deg2rad(pt2);

  a = pi / 2 - pt1(1);
  b = pi / 2 - pt2(1);
  C = pt2(2) - pt1(2);

  if C == 0
	if b <= a
	  az = 0;
	else
	  az = 180;
	endif
  else
	az = rad2deg(acot((sin(a) * cot(b) - cos(a) * cos(C)) / sin(C)));
  endif
endfunction

## http://www.mathworks.com/access/helpdesk/help/toolbox/map/azimuth.shtml
