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
%% @deftypefn {Function File} {@var{h} = } plot (@var{obj})
%% Plots the timeseries object.
%%
%% @end deftypefn

function varargout = plot (obj, varargin)
%% TODO this is a placeholder function

  t = obj.Time;
  y = obj.Data;
  names = obj.Name;

  hplot = plot (t, y);
  axis tight
  grid on
  hleg = legend (hplot, names);

  h.plot = hplot;
  h.legend = hleg;
  if nargout == 1
    varargout{1} = h;
  end

endfunction
