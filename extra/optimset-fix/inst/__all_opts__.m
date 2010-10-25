## Copyright (C) 2009 VZLU Prague
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{names} =} __all_opts__ (@dots{})
## Undocumented internal function.
## @end deftypefn

## Query all options from all known optimization functions and return a
## list of possible values.

## optimset/optimget/__all_opts__ in Octave-3.2.4 don't work
## correctly; a patch was submitted to development branch >3.3.53

function [lnames, names] = __all_opts__ (varargin)
  
  persistent saved_lnames = {};
  persistent saved_names = {};

  ## do not clear this function
  mlock ();

  ## guard against recursive calls.
  persistent recursive = false;

  if (recursive)
    lnames = names = {};
  elseif (nargin == 0)
    lnames = saved_lnames;
    names = saved_names;
  else
    ## query all options from all known functions. These will call optimset,
    ## which will in turn call us, but we won't answer.
    recursive = true;
    lnames = saved_lnames;
    names = saved_names;
    for i = 1:nargin
      try
        opts = optimset (varargin{i});
        fn = fieldnames (opts).';
        lnames = [lnames, tolower(fn)];
        names = [names, fn];
      catch
        # throw the error as a warning.
        warning (lasterr ());
      end_try_catch
    endfor
    [lnames, idx] = unique (lnames);
    if (length (lnames) < length (unique (names)))
      ## This is bad.
      error ("__all_opts__: duplicate options with inconsistent case");
    endif
    names = names(idx);
    saved_lnames = lnames;
    saved_names = names;
    recursive = false;
  endif

endfunction

