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
%% @deftypefn {Function File} {@var{S} = } pspec_bin (@var{data})
%% Computes a power spectrum by binning adjacent frequencies. This function @
%% calls @code{spectrum} from the TISEAN package.
%%
%% @var{S} contains the power spectrum, @var{f} the frequency vector.
%%
%% @seealso{pspec_mep}
%%
%% @end deftypefn

function [s f] = pspec_bin (data, varargin)

  data = data(:);
  [nT n] = size (data);
  if n !=1
    warning ('Tisian:InvalidInputFormat', ...
             'Only first column of data will be used');
  end

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "pspec_bin";
  parser = addParamValue (parser,'Res', 1/nT, @(x)x>0);
  parser = addParamValue (parser,'Sampling', 1, @(x)x>0);
  parser = parse(parser,varargin{:});

  res      = parser.Results.Res;
  sampl    = parser.Results.Sampling;

  clear parser
  # ------ #


  flag.w = sprintf("-w%d", res);
  flag.f = sprintf("-f%d", sampl);

  infile = tmpnam ();
  outfile = tmpnam ();

  %% Write data to file
  save ('-ascii',infile, 'data');

  %% Prepare format of system call
  func = file_in_loadpath ("spectrum");
  syscmd = sprintf("%s %s %s -o%s -V0 %s", ...
                 func, flag.f, flag.w, outfile, infile);

  %% Function call
  system (syscmd);

  s = load (outfile);
  f = s(:,1);
  s = s(:,2);

endfunction
