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
%% @deftypefn {Function File} {[@var{dim} @var{frac} @var{avgsize} @var{avg2size}] = } falseneigh (@var{data})
%% @deftypefnx {Function File} {[@dots{}] = } pspec_mep (@dots{},@var{property},@var{value})
%% Looks for the nearest neighbors of all data points in m dimensions and @
%% iterates these neighbors one step (more precisely delay steps) into the future. @
%% If the ratio of the distance of the iteration and that of the nearest neighbor @
%% exceeds a given threshold the point is marked as a wrong neighbor. The output is @
%% the fraction of false neighbors for the specified embedding dimensions. @
%% This function calls @code{false_nearest} from the TISEAN package.
%%
%%  @var{dim} is the dimension.
%%  @var{frac} is the fraction of false nearest neighbors.
%%  @var{avgsize}  is  the average size of the neighborhood.
%%  @var{avg2size} is the average of the squared size of the neighborhood.
%%
%% Optional arguments are:
%% @table @samp
%% @item MinEdim
%% Minimal embedding dimensions of the vectors. Deafault 1.
%% @item MaxEdim
%% Maximal embedding dimensions of the vectors. Defualt 5.
%% @item Delay
%% Delay of the vectors. Default 1.
%% @item Ratio
%% Ratio factor. Default 2.0.
%% @item Theiler
%% Theiler window. Default 0.
%% @end table
%%
%% @end deftypefn

function [dim frac avgsize avg2size] = falseneigh (data, varargin)

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "falseneigh";
  parser = addParamValue (parser,'MinEdim', 1, @(x)x>0);
  parser = addParamValue (parser,'MaxEdim', 5, @(x)x>0);
  parser = addParamValue (parser,'Delay', 1, @(x)x>0);
  parser = addParamValue (parser,'Ratio', 2, @(x)x>0);
  parser = addParamValue (parser,'Theiler', 0, @(x)x>=0);
  parser = parse(parser,varargin{:});

  medim      = parser.Results.MinEdim;
  Medim      = parser.Results.MaxEdim;
  delay      = parser.Results.Delay;
  ratio      = parser.Results.Ratio;
  thei       = parser.Results.Theiler;

  clear parser
  # ------ #

  [nT n] = size (data);

  flag.m = sprintf("-m%d", medim);
  flag.M = sprintf("-M%d,%d", n,Medim);
  flag.d = sprintf("-d%d", delay);
  flag.f = sprintf("-f%f", ratio);
  flag.t = sprintf("-t%d", thei);

  infile = tmpnam ();
  outfile = tmpnam ();

  %% Write data to file
  save ('-ascii',infile, 'data');

  %% Prepare format of system call
  func = file_in_loadpath ("false_nearest");
  syscmd = sprintf("%s %s %s %s %s %s -o%s %s", ...
                 func, flag.m, flag.M, flag.d, flag.f, flag.t, outfile, infile);

  %% Function call
  system (syscmd);

  %% Read results
  s = load (outfile);

  dim      = s(:,1); % the dimension (counted like shown above)
  frac     = s(:,2); % the fraction of false nearest neighbors
  avgsize  = s(:,3); % the average size of the neighborhood
  avg2size = s(:,4); % the average of the squared size of the neighborhood

endfunction
