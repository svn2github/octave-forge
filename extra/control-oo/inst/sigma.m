## Copyright (C) 2009   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{sv}, @var{w}] =} sigma (@var{sys})
## @deftypefnx{Function File} {[@var{sv}, @var{w}] =} sigma (@var{sys}, @var{w})
## @deftypefnx{Function File} {[@var{sv}, @var{w}] =} sigma (@var{sys}, @var{[]}, @var{ptype})
## @deftypefnx{Function File} {[@var{sv}, @var{w}] =} sigma (@var{sys}, @var{w}, @var{ptype})
## If no output arguments are given, the singular value plot of a MIMO
## system is printed on the screen;
## otherwise, the singular values of the LTI system are
## computed and returned.
##
## @strong{Inputs}
## @table @var
## @item sys
## LTI system.
## @item w
## Optional vector of frequency values. If @var{w} is not specified, it
## will be calculated by the zeros and poles of the system.
## @item ptype = 0
## Singular values of the frequency response H of system sys. Default Value.
## @item ptype = 1
## Singular values of the frequency response inv(H); i.e. inversed system.
## @item ptype = 2
## Singular values of the frequency response I + H; i.e. inversed sensitivity
## (or return difference) if H = P * C.
## @item ptype = 3
## Singular values of the frequency response I + inv(H); i.e. inversed complementary
## sensitivity if H = P * C.
## @end table
##
## @strong{Outputs}
## @table @var
## @item sv
## Array of singular values. For a system with m inputs and p outputs, the array sv
## has min(m,p) columns and as many rows as frequency points (length of w).
## The singular values at the frequency w(k) are given by sv(:,k).
## @item w
## Vector of frequency values used.
## @end table
##
## @seealso{bode, svd}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2009
## Version: 0.3.0

function [sv_r, w_r] = sigma (sys, w = [], resptype = 0)

  if (nargin == 0 || nargin > 3)
    print_usage ();
  endif

  [H, w] = __getfreqresp__ (sys, w, true, resptype, "std");

  [p, m] = size (sys);
  l_w = length (w);
  sv = zeros (min (m, p), l_w);  # preallocate memory

  ## singular value decomposition
  for k = 1 : l_w
    sv(:, k) = svd (H(:, :, k));
  endfor

  if (! nargout)  # plot the information

    ## convert to dB for plotting
    sv_db = 20 * log10 (sv);

    ## determine axes
    ax_vec = __axis2dlim__ ([w(:), min(sv_db, [], 1)(:); w(:), max(sv_db, [], 1)(:)]);
    ax_vec(1:2) = [min(w), max(w)];

    ## determine xlabel
    if (isct (sys))
      xl_str = "Frequency [rad/s]";
    else
      xl_str = sprintf ("Frequency [rad/s]     w_N = %g", pi / get (sys, "tsam"));
    endif

    ## plot results
    semilogx (w, sv_db, "b")
    axis (ax_vec)
    title ("Singular Values")
    xlabel (xl_str)
    ylabel ("Singular Values [dB]")
    grid ("on")
  else  # return values
    sv_r = sv;
    w_r = w(:);
  endif

endfunction


%!shared sv_exp, w_exp, sv_obs, w_obs
%! A = [1, 2; 3, 4];
%! B = [5, 6; 7, 8];
%! C = [4, 3; 2, 1];
%! D = [8, 7; 6, 5];
%! w = [2, 3, 4];
%! sv_exp = [7.9176, 8.6275, 9.4393;
%!           0.6985, 0.6086, 0.5195];
%! w_exp = [2; 3; 4];
%! [sv_obs, w_obs] = sigma (ss (A, B, C, D), w);
%!assert (sv_obs, sv_exp, 1e-4);
%!assert (w_obs, w_exp, 1e-4);
