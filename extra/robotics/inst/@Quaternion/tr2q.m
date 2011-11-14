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
%% Convert homogeneous transform to a unit-quaternion.
%%
%%   Return a unit quaternion corresponding to the rotational part of the
%%   homogeneous transform T.
%%
%% @seealso{q2tr}
%% @end deftypefn

%% Adapted-By: Juan Pablo Carbajal <carbajal@ifi.uzh.ch> 2011

function q = tr2q(t)

    qs = sqrt(trace(t)+1)/2.0;
    kx = t(3,2) - t(2,3);   % Oz - Ay
    ky = t(1,3) - t(3,1);   % Ax - Nz
    kz = t(2,1) - t(1,2);   % Ny - Ox

    if (t(1,1) >= t(2,2)) & (t(1,1) >= t(3,3))
        kx1 = t(1,1) - t(2,2) - t(3,3) + 1; % Nx - Oy - Az + 1
        ky1 = t(2,1) + t(1,2);          % Ny + Ox
        kz1 = t(3,1) + t(1,3);          % Nz + Ax
        add = (kx >= 0);
    elseif (t(2,2) >= t(3,3))
        kx1 = t(2,1) + t(1,2);          % Ny + Ox
        ky1 = t(2,2) - t(1,1) - t(3,3) + 1; % Oy - Nx - Az + 1
        kz1 = t(3,2) + t(2,3);          % Oz + Ay
        add = (ky >= 0);
    else
        kx1 = t(3,1) + t(1,3);          % Nz + Ax
        ky1 = t(3,2) + t(2,3);          % Oz + Ay
        kz1 = t(3,3) - t(1,1) - t(2,2) + 1; % Az - Nx - Oy + 1
        add = (kz >= 0);
    end

    if add
        kx = kx + kx1;
        ky = ky + ky1;
        kz = kz + kz1;
    else
        kx = kx - kx1;
        ky = ky - ky1;
        kz = kz - kz1;
    end
    nm = norm([kx ky kz]);
    if nm == 0
        q = Quaternion([1 0 0 0]);
    else
        s = sqrt(1 - qs^2) / nm;
        qv = s*[kx ky kz];

        q = Quaternion([qs qv]);

    end

endfunction
