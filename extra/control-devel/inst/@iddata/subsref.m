## Copyright (C) 2012   Lukas F. Reichlin
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
## Subscripted reference for LTI objects.
## Used by Octave for "sys = sys(2:4, :)" or "val = sys.prop".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: February 2012
## Version: 0.1

function a = subsref (a, s)

  if (isempty (s))
    error ("iddata: subsref: missing index");
  endif

  for k = 1 : numel (s)
    if (isa (a, "iddata"))
      switch (s(k).type)
        case "()"
          idx = s(k).subs;
          if (numel (idx) > 4)
            error ("iddata: subsref: need four or less indices");
          else
            a = __dat_prune__ (a, idx{:}); 
          endif
        case "."
          fld = s(k).subs;
          a = get (a, fld);
        otherwise
          error ("iddata: subsref: invalid subscript type");
      endswitch
    else  # not an iddata set
      a = subsref (a, s(k:end));
      return;
    endif
  endfor

endfunction


function dat = __dat_prune__ (dat, spl_idx = ":", out_idx = ":", in_idx = ":", exp_idx = ":")

  dat.y = dat.y(exp_idx);
  dat.y = cellfun (@(y) y(spl_idx, out_idx), dat.y, "uniformoutput", false);
  dat.outname = dat.outname(out_idx);
  dat.outunit = dat.outunit(out_idx);

  if (! isempty (dat.u))
    dat.u = dat.u(exp_idx);
    dat.u = cellfun (@(u) u(spl_idx, in_idx), dat.u, "uniformoutput", false);
    dat.inname = dat.inname(in_idx);
    dat.inunit = dat.inunit(in_idx);
  endif

  dat.expname = dat.expname(exp_idx);

endfunction