## Copyright (C) 2011, 2012   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{dat} =} iddata (@var{y}, @var{u})
## @deftypefnx{Function File} {@var{dat} =} iddata (@var{y}, @var{u}, @var{tsam})
## Fit frequency response data with a state-space system.
## If requested, the returned system is stable and minimum-phase.
##
## @strong{Inputs}
## @table @var
## @item dat
## LTI model containing frequency response data of a SISO system.
## @item n
## The desired order of the system to be fitted.  @code{n <= length(dat.w)}.
## @item flag
## The flag controls whether the returned system is stable and minimum-phase.
## @table @var
## @item 0
## The system zeros and poles are not constrained.  Default value.
## @item 1
## The system zeros and poles will have negative real parts in the
## continuous-time case, or moduli less than 1 in the discrete-time case.
## @end table
## @end table
##
## @strong{Outputs}
## @table @var
## @item sys
## State-space model of order @var{n}, fitted to frequency response data @var{dat}.
## @item n
## The order of the obtained system.  The value of @var{n}
## could only be modified if inputs @code{n > 0} and @code{flag = 1}.
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT SB10YD by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2011
## Version: 0.1

function dat = iddata (y = [], u = [], tsam = [], varargin)

  if (nargin == 1 && isa (y, "iddata"))
    dat = y;
    return;
  elseif (nargin < 1)
    print_usage ();
  endif

  [y, u] = __adjust_iddata__ (y, u);
  [p, m, e] = __iddata_dim__ (y, u);
  tsam = __adjust_iddata_tsam__ (tsam, e);

  outname = repmat ({""}, p, 1);
  inname = repmat ({""}, m, 1);
  expname = repmat ({""}, e, 1);

  dat = struct ("y", {y}, "outname", {outname}, "outunit", {outname},
                "u", {u}, "inname", {inname}, "inunit", {inname},
                "tsam", {tsam}, "timeunit", {""},
                "expname", {expname},
                "name", "", "notes", {{}}, "userdata", []);

  dat = class (dat, "iddata");
  
  if (nargin > 3)
    dat = set (dat, varargin{:});
  endif

endfunction


%!error (iddata);
%!error (iddata ((1:10).', (1:11).'));
%!warning (iddata (1:10));
%!warning (iddata (1:10, 1:10));


