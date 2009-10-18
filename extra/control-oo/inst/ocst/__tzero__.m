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
## @deftypefn {Function File} {[@var{zer}, @var{gain}] =} tzero (@var{a}, @var{b}, @var{c}, @var{d}, @var{opt})
## @deftypefnx {Function File} {[@var{zer}, @var{gain}] =} tzero (@var{sys}, @var{opt})
## Compute transmission zeros of a continuous system:
## @iftex
## @tex
## $$ \dot x = Ax + Bu $$
## $$ y = Cx + Du $$
## @end tex
## @end iftex
## @ifinfo
## @example
## .
## x = Ax + Bu
## y = Cx + Du
## @end example
## @end ifinfo
## or of a discrete one:
## @iftex
## @tex
## $$ x_{k+1} = Ax_k + Bu_k $$
## $$ y_k = Cx_k + Du_k $$
## @end tex
## @end iftex
## @ifinfo
## @example
## x(k+1) = A x(k) + B u(k)
## y(k)   = C x(k) + D u(k)
## @end example
## @end ifinfo
## 
## @strong{Outputs}
## @table @var
## @item zer
##  transmission zeros of the system
## @item gain
## leading coefficient (pole-zero form) of @acronym{SISO} transfer function
## returns gain=0 if system is multivariable
## @end table
## @strong{References}
## @enumerate
## @item Emami-Naeini and Van Dooren, Automatica, 1982.
## @item Hodel, @cite{Computation of Zeros with Balancing}, 1992 Lin. Alg. Appl.
## @end enumerate
## @end deftypefn

## Author: R. Bruce Tenison <btenison@eng.auburn.edu>
## Created: July 4, 1994
## A. S. Hodel Aug 1995: allow for MIMO and system data structures
## Lukas Reichlin Oct 2009: adapted for LTI Syncope

function [zer, gain] = __tzero__ (A, B, C, D)

  if (nargin != 4)
    print_usage ();
  endif

  Ao = A;  # save for leading coefficient
  Bo = B;
  Co = C;
  Do = D;

  [m, n, p] = __ssmatdim__ (A, B, C, D);

  if (m*p == 1)
    siso = 1;
  else
    siso = 0;
  endif

  ## see if it's a gain block
  if (isempty (A))
    zer = [];
    gain = D;
    return;
  endif

  ## First, balance the system via the zero computation generalized eigenvalue
  ## problem balancing method (Hodel and Tiller, Linear Alg. Appl., 1992)

  ## balance coefficients
  [A, B, C, D] = __zgpbal__ (A, B, C, D);

  if (isa ([A, B; C, D], "single"))
    meps = 2*eps("single")*norm ([A, B; C, D], "fro");
  else
    meps = 2*eps*norm ([A, B; C, D], "fro");
  endif

  ## ENVD algorithm
  [A, B, C, D] = __zgreduce__ (A, B, C, D, meps);

  if (! isempty (A))
    ## repeat with dual system
    [A, B, C, D] = __zgreduce__ (A', C', B', D', meps);

    ## transform back
    A = A';
    B2 = B;  # save for swap
    B = C';
    C = B2';
    D = D';
  endif

  zer = [];  # assume none
  
  if (! isempty (C))
    [W, r, Pi] = qr ([C, D]');
    [nonz, ztmp] = __zgrownorm__ (r, meps);

    if (nonz)
      ## We can now solve the generalized eigenvalue problem.
      [pp, mm] = size (D);
      nn = rows (A);
      Afm = [A, B ; C, D] * W';
      Bfm = [eye(nn), zeros(nn,mm); zeros(pp,nn+mm)]*W';

      jdx = (mm+1):(mm+nn);
      Af = Afm(1:nn,jdx);
      Bf = Bfm(1:nn,jdx);
      zer = qz (Af, Bf);
    endif
  endif

  mz = length (zer);

  ## compute leading coefficient
  if (nargout == 2 && siso)
    n = rows (Ao);
    if (mz == n)
      gain = Do;
    elseif (mz < n)
      gain = Co*(Ao^(n-1-mz))*Bo;
    endif
  else
    gain = [];
  endif

  zer = sort (zer);

endfunction

