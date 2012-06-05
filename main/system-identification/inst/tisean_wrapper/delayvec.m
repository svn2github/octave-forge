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
%% @deftypefn {Function File} {@var{delayed} = } delayvec (@var{data}, @var{edim})
%%  Produces delay vectors from @var{data}. This function calls @code{delay} @
%%  from the TISEAN package.
%%
%% @end deftypefn

function delayed = delayvec (data, edim=1, dformat=[], delays=[])


  [nT M] = size (data);
  flag.F = "";
  flag.D = "";
  %% Check arguments
  if (edim > M && mod (edim, M) && isempty (dformat) )

    print_usage ();

  elseif edim < M && isempty (dformat)

    print_usage ();

  elseif !isempty (dformat)

    flag.F = sprintf(["-F%d" repmat(',%d',1,length(dformat)-1)],dformat);

  end

  if !isempty (delays)

    flag.D = sprintf(["-D%d" repmat(',%d',1,length(delays)-1)],delays);

  end
  infile = tmpnam ();
  outfile = tmpnam ();

  %% Write data to file
  save ('-ascii',infile, 'data');

  %% Prepare format of the embedding vector
  func = file_in_loadpath ("delay");
  syscmd = sprintf("%s -M%d -m%d %s %s -o%s -V0 %s", ...
                      func, M, edim, flag.F, flag.D, outfile, infile);

  %% Function call
  system (syscmd);

  delayed = load (outfile);

endfunction
