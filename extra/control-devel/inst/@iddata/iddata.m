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
## @deftypefn{Function File} {@var{dat} =} iddata (@var{y})
## @deftypefnx{Function File} {@var{dat} =} iddata (@var{y}, @var{u})
## @deftypefnx{Function File} {@var{dat} =} iddata (@var{y}, @var{u}, @var{tsam}, @dots{})
## @deftypefnx{Function File} {@var{dat} =} iddata (@var{y}, @var{u}, @var{[]}, @dots{})
## Create identification dataset of output and input signals.
##
## @strong{Inputs}
## @table @var
## @item y
## Real matrix containing the output signal in time-domain.
## For a system with @var{p} outputs and @var{n} samples,
## @var{y} is a n-by-p matrix.
## For data from multiple experiments, @var{y} becomes a
## e-by-1 or 1-by-e cell vector of n(i)-by-p matrices,
## where @var{e} denotes the number of experiments
## and n(i) the individual number of samples for each experiment.
## @item u
## Real matrix containing the input signal in time-domain.
## For a system with @var{m} inputs and @var{n} samples,
## @var{u} is a n-by-m matrix.
## For data from multiple experiments, @var{u} becomes a
## e-by-1 or 1-by-e cell vector of n(i)-by-m matrices,
## where @var{e} denotes the number of experiments
## and n(i) the individual number of samples for each experiment.
## @item tsam
## Sampling time.  If not specified, default value -1 (unspecified) is taken.
## @item @dots{}
## Optional pairs of properties and values.
## @end table
##
## @strong{Outputs}
## @table @var
## @item dat
## iddata identification dataset.
## @end table
##
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2011
## Version: 0.1

function dat = iddata (y = {}, u = {}, tsam = {}, varargin)

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
                "timedomain", true, "w", {{}},
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


