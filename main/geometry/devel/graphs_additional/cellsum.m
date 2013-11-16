## Copyright (C) 2012 Juan Pablo Carbajal
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

function s=cellsum(s1,s2)
  # if ~iscellstr(s1)
  #     disp('Error. Argument 1 must be cell string.')
  #     return
  # end
  # if ~iscellstr(s2)
  #     disp('Error. Argument 2 must be cell string.')
  #     return
  # end

  ind1=~strcmp(s1,'');
  ind2=~strcmp(s2,'');
  if ~any(ind1)
      if ~any(ind2)
          s={''};
      else
          s=s2(ind2);
      end
  else
      if ~any(ind2)
          s=s1(ind1);
      else
          s=[s1(ind1) s2(ind2)];
      end
  end

endfunction
