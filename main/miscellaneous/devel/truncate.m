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
%% @deftypefn {Function File} {@var{y} = } truncate (@var{x}, @var{order})
%% Truncates @var{X} to @var{order} of magnitude.
%%
%% Example
%% @example
%%    format long
%%    x = 987654321.123456789;
%%    order = [3:-1:0 -(1:3)]';
%%    y = truncate(x,order)
%% y =
%%   987654000.000000
%%   987654300.000000
%%   987654320.000000
%%   987654321.000000
%%   987654321.100000
%%   987654321.120000
%%   987654321.123000
%% @end example
%%
%% @seealso{round,fix,ceil,floor}
%% @end deftypefn

function y = truncate (x,order)
  ino = 0.1.^order;
  o = 10.^order;
  y = round (x.*ino).*o;
end
