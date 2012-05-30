%% Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {[@var{M} @var{i} @var{j}] = } recurrplt (@var{data})
%% @deftypefnx {Function File} {[@dots{}] = } recurrplt (@dots{},@var{property},@var{value})
%% Produces a recurrence plot of the, possibly multivariate, data set. That
%% means, for each point in the data set it looks for all points, such that the
%% distance between these two points is smaller than a given size in a given
%% embedding space. This function calls @code{recurr} from the TISEAN package.
%%
%% Returns a pairs of integers representing the indexes of the pairs of points
%% having a distance smaller than R.
%%
%% Optional arguments are:
%% @table @samp
%% @item Edim
%% A 1x2 vector with number of components, embedding dimension. Deafult [1,2].
%% @item Delay
%% Time delay. Default 1.
%% @item R
%% Size of the neighbourhood. Default data-interval/1000.
%% @item Decimate
%% Number between 0-1. Output only the percentage a of all points found
%% should help to keep the output size reasonably smal
%% @end table
%%
%% @seealso{delayvec}
%%
%% @end deftypefn

function [i j] = recurrplt (data, varargin)

  [nT nc] = size (data);
  amp     = abs((max(data(:))-min(data(:))));

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "recurrplt";
  parser = addParamValue (parser,'Edim', [1,2], @ismatrix);
  parser = addParamValue (parser,'Delay', 1, @(x)x>0);
  parser = addParamValue (parser,'R', amp*1e-3, @(x)x>0);
  parser = addParamValue (parser,'Decimate', 1, @(x)x>0 && x <=1);
  parser = parse(parser,varargin{:});

  edim      = parser.Results.Edim;
  delay     = parser.Results.Delay;
  radius    = parser.Results.R;
  percent   = parser.Results.Decimate;

  clear parser
  # ------ #

  flag.m = sprintf("-m%d,%d", edim);
  flag.d = sprintf("-d%d", delay);
  flag.r = sprintf("-r%f", radius);
  flag.P = sprintf("-%%%f", percent*100);
  flag.c = sprintf("-c%d", nc);

  infile = tmpnam ();
  outfile = tmpnam ();

  %% Write data to file
  save ('-ascii',infile, 'data');

  %% Prepare format of system call
  func = file_in_loadpath ("recurr");
  syscmd = sprintf("%s %s %s %s %s %s -V0 -o%s %s", ...
              func, flag.c, flag.m, flag.d, flag.r, flag.P, outfile, infile);

  %% Function call
  system (syscmd);

  %% Read results
  d = load(outfile);
  i = d(:,1);
  j = d(:,2);

endfunction
