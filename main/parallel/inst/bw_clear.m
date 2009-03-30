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
## @deftypefn {Function File} {} bw_clear (@var{f}, @var{args})
## Terminates scheduler (if running) and removes statefile for function
## @var{f} and argument filename @var{args}. Results will be lost.
## @seealso {bw_start, bw_list, bw_retrieve}
## @end deftypefn

function bw_clear (f, args)

  if (nargin != 2)
    error ("bw_clear: incorrect number of arguments");
  endif
  if (! ischar (f) || size (f, 1) > 1)
    error ("bw_clear: first argument not a (single) string", id);
  endif
  if (! ischar (args) || size (args, 1) > 1)
    error ("bw_clear: second argument not a (single) string", id);
  endif

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

  st_path = fullfile (state_dir, sprintf ("%s-%s.state", f, args));
  l_path = fullfile (state_dir, sprintf ("%s-%s.lock", f, args));
  pid_path = fullfile (state_dir, sprintf ("%s-%s.pid", f, args));

  if (__bw_is_locked__ (l_path))
    pause (1); # pid should already be written
    try
      pid = load (pid_path);
    catch
      error ("bw_clear: pid could not be read from pidfile %s", \
	     pid_path);
    end_try_catch
    printf ("stopping scheduler for function %s and argumentfile %s\n", \
	    f, args)
    system (sprintf ("kill -9 %i", pid));
    if (unlink (l_path) < 0)
      printf ("could not remove lockfile %s\n", l_path);
    endif
    if (unlink (pid_path) < 0)
      printf ("could not remove pidfile %s\n", pid_path);
    endif
  else
    ## __bw_is_locked__() creates the file
    if (unlink (l_path) < 0)
      printf ("could not remove lockfile after temporarily creating it %s\n", l_path);
    endif
  endif

  if (isempty (stat (st_path)))
    printf ("no statefile for function %s and argumentfile %s\n", \
	    f, args);
  else
    if (unlink (st_path) < 0)
      printf ("could not remove statefile %s\n", st_path);
    else
      printf ("removed statefile for function %s and argumentfile %s\n", \
	      f, args);
    endif
  endif

endfunction