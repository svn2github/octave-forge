%% Copyright (C) 1993-2011, by Peter I. Corke
%%
%% This file is part of The Robotics Toolbox (RTB).
%%
%% RTB is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
%% RTB is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Lesser General Public License for more details.
%%
%% You should have received a copy of the GNU Leser General Public License
%% along with RTB.  If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} display (@var{q})
%% Quaternion.display Display the value of a quaternion object
%%
%%  Q.display() displays a compact string representation of the quaternion's value
%%  as a 4-tuple.
%%
%%  Notes::
%%  - this method is invoked implicitly at the command line when the result
%%    of an expression is a Quaternion object and the command has no trailing
%%    semicolon.
%% @end deftypefn

%% Adapted-By: Juan Pablo Carbajal <carbajal@ifi.uzh.ch> 2011

function display(q)

  loose = strcmp( get(0, 'FormatSpacing'), 'loose');
  if loose
      disp(' ');
  end
  disp([inputname(1), ' = '])
  if loose
      disp(' ');
  end
  disp(char(q))
  if loose
      disp(' ');
  end

endfunction

function s = char(Q)
  %Quaternion.char Create string representation of quaternion object
  %
  % S = Q.char() is a compact string representation of the quaternion's value
  % as a 4-tuple.

      if length(Q) > 1
          s = '';
          for qq = Q;
              s = strvcat(s, char(qq));
          end
          return
      end
      s = [num2str(Q.q_wrap.w), ' < ' ...
          num2str(Q.q_wrap(1)) ', ' num2str(Q.q_wrap(2)) ', '   num2str(Q.q_wrap(3)) ' >'];
endfunction
