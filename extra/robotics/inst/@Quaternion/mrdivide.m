%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
%% @deftypefn {Function File} {@var{c} = } mrdivide (@var{a}, @var{b})
%% Matrix right division for quaternions. Used by Octave for "a / b"
%%
%% @end deftypefn

function a = mrdivide (a, b)

  if strcmp (class (b), "Quaternion")

    a.q_wrap = a.q_wrap * inv (b.q_wrap);

  elseif isreal (b)

    a.q_wrap = a.q_wrap / b;

  end

endfunction
