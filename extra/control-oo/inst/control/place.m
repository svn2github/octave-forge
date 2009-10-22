## Copyright (C) 1997, 2000, 2002, 2003, 2004, 2005, 2007
##               Jose Daniel Munoz Frias
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
## @deftypefn {Function File} {@var{K} =} place (@var{sys}, @var{p})
## @deftypefnx {Function File} {@var{K} =} place (@var{a}, @var{b}, @var{p})
## Computes the matrix @var{K} such that if the state
## is feedback with gain @var{K}, then the eigenvalues  of the closed loop
## system (i.e. @math{A-BK}) are those specified in the vector @var{p}.
##
## Version: Beta (May-1997): If you have any comments, please let me know.
## (see the file place.m for my address)
## @end deftypefn

## Author: Jose Daniel Munoz Frias

## Universidad Pontificia Comillas
## ICAIdea
## Alberto Aguilera, 23
## 28015 Madrid, Spain
##
## E-Mail: daniel@dea.icai.upco.es
##
## Phone: 34-1-5422800   Fax: 34-1-5596569
##
## Algorithm taken from "The Control Handbook", IEEE press pp. 209-212
##
## code adaped by A.S.Hodel (a.s.hodel@eng.auburn.edu) for use in controls
## toolbox

## Adapted-By: Lukas Reichlin <lukas.reichlin@gmail.com>
## Date: October 2009
## Version: 0.1

function K = place (argin1, argin2, argin3)

  if (nargin == 3)
    A = argin1;
    B = argin2;
    P = argin3;
  elseif (nargin == 2)
    [A, B] = ssdata (argin1);
    P = argin2;
  else
    print_usage ();
  endif

  ## check arguments - values of C and D matrices don't matter
  [m, nx, p] = __ssmatdim__ (A, B, zeros (1, columns (A)), zeros (1, columns (B)));

  if (m != 1)
    error ("place: system has %d inputs; need only 1", m);
  endif

  if (! isctrb (A, B))
    error ("place: system is not controllable");
  elseif (! isvector (P))
    error ("place: P must be a vector")
  else
    P = P(:);  # make P a column vector
  endif

  sp = length (P);

  if (nx == 0)
    error ("place: A matrix is empty (0x0)");
  elseif (nx != length (P))
    error ("place: A=(%dx%d), P has %d entries", nx, nx, length (P))
  endif

  ## arguments appear to be compatible; let's give it a try!
  ## The second step is the calculation of the characteristic polynomial ofA
  PC = poly (A);

  ## Third step: Calculate the transformation matrix T that transforms the state
  ## equation in the controllable canonical form.

  ## first we must calculate the controllability matrix M:
  M = ctrb (A, B);

  ## second, construct the matrix W
  PCO = PC(nx:-1:1);
  PC1 = PCO;      # Matrix to shift and create W row by row

  for n = 1:nx
    W(n,:) = PC1;
    PC1 = [PCO(n+1:nx), zeros(1,n)];
  endfor

  T = M*W;

  ## finaly the matrix K is calculated
  PD = poly (P); # The desired characteristic polynomial
  PD = PD(nx+1:-1:2);
  PC = PC(nx+1:-1:2);

  K = (PD-PC)/T;

  ## Check if the eigenvalues of (A-BK) are the same specified in P
  Pcalc = eig (A-B*K);

  Pcalc = sort (Pcalc);
  P = sort (P);

  if (max ((abs(Pcalc)-abs(P))./abs(P) ) > 0.1)
    warning ("place: pole placed at more than 10% relative error from specified");
  endif

endfunction


%!shared A, B, C, P, Kexpected
%! A = [0 1; 3 2];
%! B = [0; 1];
%! C = [2 1]; # C is useful to use ss; it doesn't matter what the value of C is
%! P = [-1 -0.5];
%! Kexpected = [3.5 3.5];
%!assert (place (ss (A, B, C), P), Kexpected, 2*eps);
%!assert (place (A, B, P), Kexpected, 2*eps);