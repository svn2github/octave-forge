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
## @deftypefn {Function File} {} @var{anglout} = deg2rad(@var{anglin})
##
## Converts angles input in degrees to the equivalent in radians.
## @end deftypefn

## Author: Andrew Collier <abcollier@users.sourceforge.net>

function anglout = deg2rad(anglin)
  anglout = anglin * pi / 180;
endfunction

## http://www.mathworks.com/access/helpdesk/help/toolbox/map/functionlist.shtml
