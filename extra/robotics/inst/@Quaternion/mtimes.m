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
%% @deftypefn {Function File} {@var{c} = } mtimes (@var{a}, @var{b})
%%
%% @end deftypefn


function q = mtimes (a, b)

  q = Quaternion();

  if strcmp (class (a), "Quaternion") && strcmp (class (b), "Quaternion")
    q.q_wrap = a.q_wrap * b.q_wrap;

  elseif strcmp (class (a), "double") && strcmp (class (b), "Quaternion")

    if length(a) == 3
      q.q_wrap = b.q_wrap * Quaternion([0 a(:)']).q_wrap * conj (b.q_wrap);
    elseif length(a) == 1
      q.q_wrap = b.q_wrap * a;
    else
      error('Quaternion:InvalidArgument','Quaternion times vector: must be a 3-vector or scalar');
    end

  elseif strcmp (class (b), "double") && strcmp (class (a), "Quaternion")

    if length(b) == 3
      q.q_wrap = a.q_wrap * Quaternion([0 b(:)']).q_wrap * conj (a.q_wrap);
    elseif length(b) == 1
      q.q_wrap = a.q_wrap*b;
    else
      error('Quaternion:InvalidArgument','Quaternion times vector: must be a 3-vector or scalar');
    end

  end

endfunction
