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
%% @deftypefn {Function File} {[@var{c} @var{d} @var{h}] = } corrdim (@var{data})
%% @deftypefnx {Function File} {[@dots{}] = } corrdim (@dots{},@var{property},@var{value})
%%  Correlation dimension from @var{data}. This function calls @code{d2} @
%%  from the TISEAN package.
%%
%% @end deftypefn

function [c d h] = corrdim (data, varargin)


  [nT M] = size (data);
  amp = max(max(data)-min(data));
  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "corrdim";
  parser = addParamValue (parser,'Components', 1, @(x)x>0);
  parser = addParamValue (parser,'MaxEdim', 10, @(x)x>0);
  parser = addParamValue (parser,'Delay', 1, @(x)x>0);
  parser = addParamValue (parser,'TheilerWindow', 0, @(x)x>=0);
  parser = addParamValue (parser,'ScaleSpan', amp*[1e-3 1], @(x)all(x>0));
  parser = addParamValue (parser,'EpsilonCount', 100, @(x)x>0);
  parser = addParamValue (parser,'PairCount', 1000, @(x)x>=0);
  parser = addSwitch (parser,'Normalize');
  parser = addSwitch (parser,'Verbose');
  parser = parse(parser,varargin{:});

  flag.E = "";
  if parser.Results.Normalize
    flag.E = "-E";
  end

  infile = tmpnam ();
  outfile = tmpnam ();

  %% Write data to file
  save ('-ascii',infile, 'data');

  %% Prepare format of system call
  func = file_in_loadpath ("d2");

  %% Prepare format of the embedding vector
  syscmd = sprintf ("%s -d%d -M%d,%d -t%d -r%f -R%f -#%d -N%d %s -o%s -V0 %s", func, ...
                        parser.Results.Delay, ...
                        parser.Results.Components, ...
                        parser.Results.MaxEdim, ...
                        parser.Results.TheilerWindow, ...
                        parser.Results.ScaleSpan, ...
                        parser.Results.EpsilonCount, ...
                        parser.Results.PairCount, ...
                        flag.E, outfile, infile);

  %% Function call
  system (syscmd);

  c = load ([outfile ".c2"]);
  d = load ([outfile ".d2"]);
  h = load ([outfile ".h2"]);


endfunction
