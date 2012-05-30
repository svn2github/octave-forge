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
%% @deftypefn {Function File} {[@var{S} @var{f} @var{AR} @var{ARerr}] = } pspec_mep (@var{data})
%% @deftypefnx {Function File} {[@dots{}] = } pspec_mep (@dots{},@var{property},@var{value})
%% Estimates the power spectrum of a scalar data set on the basis of the maximum @
%% entropy principle. This function calls @code{mem_spec} from the TISEAN package.
%%
%% @var{S} contains the power spectrum, @var{f} the frequency vector.
%%
%% Optional arguments are:
%% @table @samp
%% @item Poles
%% Number of poles of the AR model. Deafault 128.
%% @item Freqs
%% Number of frequencies to use. Defualt 2000 Hz.
%% @item Sampling
%% Sampling frequency of the data. Default 1 Hz
%% @item AR
%% This is just a swtich, it doesn't need to be followed by a value. If present
%% the coefficients of the AR model are returned in @var{AR} and the estimation
%% error in @var{ARerr}.
%% @end table
%%
%% @seealso{pspec_bin}
%%
%% @end deftypefn

function [s f AR ARerr] = pspec_mep (data, varargin)

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "pspec_mep";
  parser = addParamValue (parser,'Poles', 128, @(x)x>0);
  parser = addParamValue (parser,'Freqs', 2e3, @(x)x>0);
  parser = addParamValue (parser,'Sampling', 1, @(x)x>0);
  parser = addSwitch (parser,'AR');
  parser = parse(parser,varargin{:});

  poles      = parser.Results.Poles;
  freqs      = parser.Results.Freqs;
  sampl      = parser.Results.Sampling;
  ar         = parser.Results.AR;

  clear parser
  # ------ #

  data = data(:);
  [nT n] = size (data);
  if n !=1
    warning ('Tisian:InvalidInputFormat', ...
             'Only first column of data will be used');
  end

  flag.p = sprintf("-p%d", poles);
  flag.P = sprintf("-P%d", freqs);
  flag.f = sprintf("-f%d", sampl);
  flag.V = sprintf("-V%d", 2*ar);

  infile = tmpnam ();
  outfile = tmpnam ();

  %% Write data to file
  save ('-ascii',infile, 'data');

  %% Prepare format of system call
  func = file_in_loadpath ("mem_spec");
  syscmd = sprintf("%s %s %s %s %s -o%s %s", ...
                 func, flag.p, flag.P, flag.f, flag.V, outfile, infile);

  %% Function call
  system (syscmd);

  %% Read results
  if ar
    ARerrtxt   = textread (outfile, "%s", 1){1};
    [~, AR] = textread (outfile, "%s%f", poles, "headerlines", 1);
    [f,s]  = textread (outfile, "%f%f", freqs, "headerlines", 1+poles);

    %% Parse AR error
    ARerr = str2num (strsplit (ARerrtxt, "="){2});
  else
    s = load (outfile);
    f = s(:,1);
    s = s(:,2);
    AR    = [];
    ARerr = [];
  end



endfunction
