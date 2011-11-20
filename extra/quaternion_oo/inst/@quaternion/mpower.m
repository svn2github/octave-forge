## Copyright (C) 2010   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Matrix power operator of quaternions.  Used by Octave for "q^x".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function a = mpower (a, b)

  if isa (a, "quaternion")

    if isscalar (a.w)                   # power takes care of checking type of b
      a = a .^ b;
    else

      if fix (b) == b                    # only integers are poorly implemented
        [n m] = size (a.w);
        w = ones (n,m);
        x = zeros (n,m);
        q = quaternion(w,x,x,x);
        while b--
          q *= a;
        end
        a = q;
      else
        error ("quaternion:devel", ...
                  "quaternion: power: implemented for scalar quaternions only");
      end

    end

  else
    error ("quaternion:invalidArgument", "base must be a quaternion.");
  end
  ## TODO: - q1 ^ q2
  ##       - arrays

endfunction
