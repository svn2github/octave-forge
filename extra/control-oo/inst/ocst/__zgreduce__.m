## Copyright (C) 1996, 2000, 2005, 2007
##               Auburn University.  All rights reserved.
## Copyright (C) 2009   Lukas F. Reichlin
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
## @deftypefn {Function File} {} zgreduce (@var{sys}, @var{meps})
## Implementation of procedure REDUCE in (Emami-Naeini and Van Dooren,
## Automatica, # 1982).
## @end deftypefn

function [A, B, C, D] = __zgreduce__ (A, B, C, D, meps)

  if (nargin != 5)
    print_usage ();
  endif  

  exit_1 = 0;  # exit_1 = 1 or 2 on exit of loop

  [m, n, p] = __ssmatdim__ (A, B, C, D);

  if (n == 0)
    exit_1 = 2;  # there are no finite zeros
  endif

  while (! exit_1)
    [Q, R, Pi] = qr (D);  # compress rows of D
    D = Q'*D;
    C = Q'*C;

    ## check row norms of D
    [sig, tau] = __zgrownorm__ (D, meps);

    if (tau == 0)
      exit_1 = 1;               # exit_1 - reduction complete and correct
    else
      Cb = Db = [];
      if (sig)
        Cb = C(1:sig,:);
        Db = D(1:sig,:);
      endif
      Ct = C(sig+(1:tau),:);

      ## compress columns of Ct
      [pp, nn] = size (Ct);
      rvec = nn:-1:1;
      [V, Sj, Pi] = qr (Ct');
      V = V(:,rvec);
      [rho, gnu] = __zgrownorm__ (Sj, meps);

      if (rho == 0)
        exit_1 = 1;     # exit_1 - reduction complete and correct
      elseif (gnu == 0)
        exit_1 = 2;     # there are no zeros at all
      else
        mu = rho + sig;

        ## update system with Q
        M = [A, B];
        [nn, mm] = size (B);

        pp = rows (D);
        Vm = [V, zeros(nn,mm); zeros(mm,nn), eye(mm)];
        if (sig)
          M = [M; Cb, Db];
          Vs = [V', zeros(nn,sig); zeros(sig,nn), eye(sig)];
        else
          Vs = V';
        endif

        M = Vs*M*Vm;

        idx = 1:gnu;
        jdx = nn + (1:mm);
        sdx = gnu + (1:mu);

        A = M(idx,idx);
        B = M(idx,jdx);
        C = M(sdx,idx);
        D = M(sdx,jdx);

      endif
    endif
  endwhile

  if (exit_1 == 2)
    ## there are no zeros at all!
    A = B = C = [];
  endif

endfunction
