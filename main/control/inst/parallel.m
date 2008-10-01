## Copyright (C) 1996, 2000, 2002, 2004, 2005, 2006, 2007
##               Auburn University.  All rights reserved.
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{ksys} =} parallel (@var{asys}, @var{bsys})
## Forms the parallel connection of two systems.
##
## @example
## @group
##              --------------------
##              |      --------    |
##     u  ----->|----> | asys |--->|----> y1
##         |    |      --------    |
##         |    |      --------    |
##         |--->|----> | bsys |--->|----> y2
##              |      --------    |
##              --------------------
##                   ksys
## @end group
## @end example
## @end deftypefn

## Author: David Clem
## Created: August 15, 1994
## completely rewritten Oct 1996 a s hodel
## SYS_INTERNAL accesses members of system structure

function sysp = parallel (Asys, Bsys)

  if(nargin != 2)
    print_usage ();
  endif
  if (! isstruct(Asys) )
    error ("1st input argument is not a system data structure");
  elseif (! isstruct(Bsys) )
    error ("2nd input argument is not a system data structure");
  endif
  [Ann, Anz, mA] = sysdimensions(Asys);
  [Bnn, Bnz, mB] = sysdimensions(Bsys);
  if (mA != mB)
    error ("Asys has %d inputs, Bsys has %d inputs", mA, mB);
  endif

  ## save signal names
  Ain = sysgetsignals (Asys, "in");

  ## change signal names to avoid warning messages from sysgroup
  Asys = syssetsignals (Asys, "in", __sysdefioname__ (length (Ain), "Ain_u"));
  Bsys = syssetsignals (Bsys, "in", __sysdefioname__ (length (Ain), "Bin_u"));

  sysp = sysgroup (Asys, Bsys);
  sysD = ss ([], [], [], [eye(mA); eye(mA)]);

  sysp = sysmult (sysp, sysD);
  sysp = syssetsignals (sysp, "in", Ain);

endfunction
