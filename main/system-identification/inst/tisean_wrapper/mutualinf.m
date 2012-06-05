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
%% @deftypefn {Function File} {[@var{d} @var{minf} @var{shinf}] = } mutualinf (@var{data})
%% @deftypefnx {Function File} {@dots{} = } nststz (@dots{},@var{property},@var{value})
%% Estimates the time delayed mutual information of the data. It is the simplest
%% possible realization. It uses a fixed mesh of boxes. This function calls
%% @code{mutual} from the TISEAN package.
%%
%% @var{shinf} contains the Shannon entropy (normalized to the number of
%% occupied boxes). @var{d} contains the delays and @var{minf} the mutual information.
%%
%% Optional arguments are:
%% @table @samp
%% @item Nboxes
%% Number of boxes for the partition. Default 16.
%% @item MaxDelay
%% Maximal time delay. Default 20.
%% @end table
%%
%% @end deftypefn

function [d minf shinf] = mutualinf (data, varargin)

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "nstatz";
  parser = addParamValue (parser,'Nboxes', 16, @(x)x>0);
  parser = addParamValue (parser,'MaxDelay', 20, @(x)x>0);
  parser = parse(parser,varargin{:});

  nbox      = parser.Results.Nboxes;
  delay     = parser.Results.MaxDelay;
  clear parser
  # ------ #

  flag.b = sprintf("-b%d", nbox);
  flag.D = sprintf("-D%d", delay);

  infile = tmpnam ();
  outfile = tmpnam ();

  [nT nc] = size (data);
  shinf = zeros (1, nc);
  minf  = zeros (delay, nc);

  for i =1:nc
    datac = data(:,i);

    %% Write data to file
    save ('-ascii',infile, 'datac');

    %% Prepare format of system call
    func = file_in_loadpath ("mutual");
    syscmd = sprintf("%s %s %s -o%s -V0 %s", func, ...
     flag.b, flag.D, outfile, infile);

    %% Function call
    system (syscmd);

    [inftxt tmp] = textread (outfile, "%s%f", 1);
    shinf(i)  = tmp;%str2num (strsplit (inftxt, "="){2})

    [d, tmp]  = textread (outfile, "%f%f", delay, "headerlines", 1);
    minf(:,i) = tmp;
  end

endfunction
