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
## @deftypefn {Function File} {} bw_retrieve (@var{f}, @var{args}, @var{fn}, [@var{matlab}])
## Retrieve results of computations started with @code{bw_start ()}.
## Computation need not be finished for all arguments. @var{f}, @var{args}:
## function name and filename of arguments given to @code{bw_start ()}. @var{fn}:
## path to file to save results in. @var{matlab}: if given and true, results
## are stored in Matlab compatible binary format; otherwise the binary
## format of Octave is used.
##
## Three variables are saved, "results" is a cell-array of results (empty
## entry if no result), one for each argument set, "errors" a vector
## with non-zero elements for each argument set which caused an error,
## and "messages" is a cell-array of the respective error messages, or
## empty values if there was none.
## @seealso {bw_start, bw_list, bw_clear}
## @end deftypefn

function bw_retrieve (varargin)

  if ((nargs = length (varargin)) < 3 || nargs > 4)
    error ("bw_retrieve: incorrect number of arguments");
  endif
  for id = 1:3
    if (! ischar (varargin{id}) || size (varargin{id}, 1) > 1)
      error ("bw_retrieve: argument %i not a (single) string", id);
    endif
  endfor
  if (nargs == 4 && varargin{4})
    matlab = true;
  else
    matlab = false;
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

  path = fullfile (state_dir, \
		   sprintf ("%s-%s.state", \
			    varargin{1}, varargin{2}));
  if (isempty (stat (path)))
    error ("bw_retrieve: no state-file found for function %s and argumentfile %s", \
	   varargin{1}, varargin{2});
  endif
  tp = __bw_load_variable__ (path);
  results = tp.results;
  errors = tp.error;
  messages = tp.msg;

  if (matlab)
    save ("-matl", varargin{3}, "results", "errors", "messages");
  else
    save ("-binary", varargin{3}, "results", "errors", "messages");
  endif

endfunction