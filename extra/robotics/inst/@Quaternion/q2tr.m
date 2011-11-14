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
%% @deftypefn {Function File} {@var{t} = } q2tr (@var{q})
%% Convert unit-quaternion to homogeneous transform.
%%
%%   Return the rotational homogeneous transform corresponding to the unit
%%   quaternion Q.
%%
%% @seealso{tr2q}
%% @end deftypefn

%% Adapted-By: Juan Pablo Carbajal <carbajal@ifi.uzh.ch> 2011

function t = q2tr(Q)

    if abs (Q.q_wrap) != 1
      warning('Quaternion:InvalidArgument',...
              'Input argumet should be a unit quaternion.');
    end

    s = Q.q_wrap(0);
    x = Q.q_wrap(1);
    y = Q.q_wrap(2);
    z = Q.q_wrap(3);

    r = [   1-2*(y^2+z^2)   2*(x*y-s*z) 2*(x*z+s*y)
        2*(x*y+s*z) 1-2*(x^2+z^2)   2*(y*z-s*x)
        2*(x*z-s*y) 2*(y*z+s*x) 1-2*(x^2+y^2)   ];

    t = eye(4,4);
    t(1:3,1:3) = r;
    t(4,4) = 1;
end
