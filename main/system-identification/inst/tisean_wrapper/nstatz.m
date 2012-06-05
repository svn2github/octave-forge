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
%% @deftypefn {Function File} {@var{m} = } nstatz (@var{data}, @var{n})
%% @deftypefn {Function File} {[@var{f} @var{p} @var{ferr}] = } nstatz (@dots{})
%% @deftypefnx {Function File} {@dots{} = } nststz (@dots{},@var{property},@var{value})
%% Seeks for nonstationarity in a time series by dividing it into a number of @
%% segments and calculating the cross-forecast errors between the different @
%% segments. The model used for the forecast is zeroth order model as proposed by @
%% Schreiber. This function calls @code{nstat_z}  from the TISEAN package.
%%
%% @end deftypefn

function varargout = nstatz (data, n, varargin)

  data = data(:);
  [nT nc] = size (data);
  if nc !=1
    warning ('Tisian:InvalidInputFormat', ...
             'Only first column of data will be used');
  end
  amp     = abs((max(data)-min(data)));

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "nstatz";
  parser = addParamValue (parser,'Edim', 3, @(x)x>0);
  parser = addParamValue (parser,'Delay', 1, @(x)x>0);
  parser = addParamValue (parser,'Points', Inf, @(x)x>0);
  parser = addParamValue (parser,'minNeigh', 30, @(x)x>0);
  parser = addParamValue (parser,'Rini', amp*1e-3, @(x)x>0);
  parser = addParamValue (parser,'Rslope', 1.2, @(x)x>0);
  parser = addParamValue (parser,'Fstep', 1, @(x)x>0);
  parser = addParamValue (parser,'CausW', 1, @(x)x>0);
  parser = parse(parser,varargin{:});

  edim      = parser.Results.Edim;
  delay     = parser.Results.Delay;
  points    = parser.Results.Points;
  minN      = parser.Results.minNeigh;
  rini      = parser.Results.Rini;
  rslope    = parser.Results.Rslope;
  fstep     = parser.Results.Fstep;
  causw     = parser.Results.CausW;
  if ismember("CausW", parser.UsingDefaults)
    causw = fstep;
  end
  clear parser
  # ------ #

  flag.num = sprintf("-#%d", n);

  flag.m = sprintf("-m%d", edim);
  flag.d = sprintf("-d%d", delay);
  if isinf (points)
    flag.n = "";
  else
    flag.n = sprintf("-d%d", points);
  end
  flag.k = sprintf("-k%d", minN);
  flag.r = sprintf("-r%f", rini);
  flag.f = sprintf("-f%f", rslope);
  flag.s = sprintf("-s%d", fstep);
  flag.C = sprintf("-C%d", causw);

  infile = tmpnam ();
  outfile = tmpnam ();

  %% Write data to file
  save ('-ascii',infile, 'data');

  %% Prepare format of system call
  func = file_in_loadpath ("nstat_z");
  syscmd = sprintf("%s %s %s %s %s %s %s %s %s %s -o%s -V0 %s", func, flag.num, ...
   flag.m, flag.d, flag.n, flag.k, flag.r, flag.f, flag.s, flag.C, ...
   outfile, infile);

  %% Function call
  system (syscmd);
  s    = load (outfile);
  f    = s(:,1);
  p    = s(:,2);
  ferr = s(:,3);

  if nargout == 1
    m   = NA (n);
    idx = sub2ind ([n,n], f, p);
    m(idx) = ferr;
    varargout{1} = m;
  elseif nargout == 3
    varargout = {f,p,ferr};
  else
    print_usage ();
  end

endfunction
