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
## @deftypefn {Function File} {} bw_start ()
## @deftypefnx {Function File} {} bw_start (@var{f}, @var{argfile})
## Start parallel computation in a beowulf cluster.
##
## With no arguments, restart all unfinished jobs.
##
## With two arguments, (re)start job. String @var{f} names a function to
## be started multiple times in parallel. @var{argfile} names a data-file in
## the configured data directory containing a one-dimensional cell-array
## with arguments for @var{f}, one entry for each invocation of @var{f}. @var{f}
## must be of one of the following forms
##
## @example
## function @var{ret} = f (@var{args})
##
## function @var{ret} = f (@var{args}, @var{idx})
## @end example
##
## where @var{args} is an entry of the argument cell-array, @var{idx} is the
## index of this entry, and @var{ret} contains the result of computation.
##
## Users can put configuration commands into the file "~/.bwrc".
## Variable "data_dir" contains the configured data directory, default
## is "~/bw-data/". Directory given in variable "state_dir", default
## "~/.bw-state/", is used internally to read and write state
## information. If this directory does not exist it is created, which
## will fail if there would be more than one level to create.
## @seealso {bw_list, bw_retrieve, bw_clear}
## @end deftypefn

function bw_start (varargin)

  if ((nargs = length (varargin)) > 2 || nargs == 1)
    error "bw_start: incorrect number of arguments";
  endif
  for id = 1:nargs
    if (! ischar (varargin{id}) || size (varargin{id}, 1) > 1)
      error ("bw_start: argument %i not a (single) string", id);
    endif
  endfor

  ## default directories
  data_dir = tilde_expand ("~/bw-data/");
  state_dir = tilde_expand ("~/.bw-state/");

  ## configuration files
  systemrc = fullfile (OCTAVE_HOME (), "share/octave/site/m/startup/bwrc");
  userrc = "~/.bwrc";

  ## Read system-wide configuration, should provide
  ## "computing_machines", a cell-array with addresses, and
  ## "central_machine", a single address.
  source (systemrc);
  if (! exist ("central_machine"))
    error ("bw_start: system configuration file should give \"central_machine\"");
  endif

  ## Read per-user configuration.
  if (! isempty (stat (userrc)))
    source (userrc);
  endif
  data_dir = tilde_expand (data_dir);
  state_dir = tilde_expand (state_dir);

  if (isempty (stat (state_dir)))
    mkdir (state_dir);
  endif

  if (nargs == 2)
    job_tbl = {varargin{1}, varargin{2}};
    n_j = 1;
    state_files = {(sprintf ("%s-%s.state", job_tbl{1}, job_tbl{2}))};
  else
    n_j = length \
	((state_files = glob (fullfile (state_dir, "*.state"))));
    job_tbl = cell (n_j, 2);
    for id = 1:n_j
      [discarded, discarded, discarded, tp] = \
	  regexp (state_files{id}, "[^/]+$");
      state_files{id} = tp{1};
      job_tbl(id, :) = cellstr (split (state_files{id}, "-", 2))';
      job_tbl{id, 2} = regexprep (job_tbl{id, 2}, '\.state$', "");
    endfor
  endif

  n_s = 0;
  for id = 1:n_j
    if (nargs == 2 && \
	isempty (stat (fullfile (state_dir, state_files{1}))))
      ready = 0;
    elseif (all (__bw_load_variable__ \
		 (fullfile (state_dir, state_files{id})) . \
		 ready))
      ready = 1;
    else
      ready = 0;
    endif
    if (! ready)
      if ((tp = exist (job_tbl{id, 1})) < 2 || tp > 5)
	error ("bw_start: no function %s", job_tbl{id, 1});
      endif
      if (isempty (stat (fullfile (data_dir, job_tbl{id, 2}))))
	error ("bw_start: no such file %s", \
	       fullfile (data_dir, job_tb{id, 2}));
      endif
      n_s++;
      [estat, output] = \
	  system (sprintf ("ssh %s \"nohup octave -q --eval \\\"__bw_scheduler__ (\\\\\\\"%s\\\\\\\", \\\\\\\"%s\\\\\\\")\\\" &> /dev/null &\"", \
			   central_machine, \
			   job_tbl{id, 1}, \
			   job_tbl{id, 2}));
      if (estat == 0)
	printf ("function %s, datafile %s: job started\n", \
		job_tbl{id, 1}, job_tbl{id, 2});
      else
	error ("function %s, datafile %s: ssh returned exit status %i, output: %s", \
	       job_tbl{id, 1}, job_tbl{id, 2}, estat, output);
      endif
    endif
  endfor

  if (nargs == 2 && n_s == 0)
    printf ("bw_start: computation is ready\n");
  endif

endfunction