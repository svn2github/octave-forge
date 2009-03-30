## Copyright (C) 2009 Olaf Till <olaf.till@uni-jena.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} bw_list ()
## Display state of jobs started with @code{bw_start ()}.
## @seealso {bw_start, bw_retrieve, bw_clear}
## @end deftypefn

function bw_list ()

  ## default directories
  data_dir = tilde_expand ("~/bw-data/");
  state_dir = tilde_expand ("~/.bw-state/");

  ## configuration files
  systemrc = fullfile (OCTAVE_HOME (), "share/octave/site/m/startup/bwrc");
  userrc = "~/.bwrc";

  ## Read system-wide configuration.
  source (systemrc);

  ## Read per-user configuration.
  if (! isempty (stat (userrc)))
    source (userrc);
  endif
  data_dir = tilde_expand (data_dir);
  state_dir = tilde_expand (state_dir);

  if (isempty (stat (state_dir)))
    error ("bw_list: configured state directory %s does not exist", \
	   state_dir);
  endif

  printf ("function, argumentfile, ready/all, n machines, (active?)\n");
  for id = 1:length (fns = glob (fullfile (state_dir, "*.state")))
    [discarded, discarded, discarded, tp] = \
	regexp (fns{id}, "[^/]+$");
    tp = cellstr (split (tp{1}, "-", 2))';
    tp{2} = regexprep (tp{2}, '\.state$', "");
    printf ("%s,   %s,   ", tp{1}, tp{2});
    state = __bw_load_variable__ (fns{id});
    n = length (state.ready);
    nr = length (find (state.ready));
    printf ("%i/%i,   ", nr, n);
    if (isfield (state, "machines"))
      printf ("%i", length (find (! state.machines.unresponsive)))
    else
      printf ("0");
    endif
    if (nr < n)
      if (__bw_is_locked__ \
	  (fullfile (state_dir, \
		     sprintf ("%s-%s.lock", tp{1}, tp{2}))))
	printf (",   active\n");
      else
	printf (",   inactive\n");
      endif
    else
      printf ("\n");
    endif
  endfor

endfunction