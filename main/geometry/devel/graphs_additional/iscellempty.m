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

function out=iscellempty(P)
  itiscellstr=0;
  if iscell(P)
      itiscell=1;
      if iscellstr(P{1})
          itiscellstr=1;
      end
  else
      disp('Implemented only for cells.')
      return
  end

  [n m]=size(P);
  if itiscellstr==1
      for i=1:n
          for j=1:m
              out(i,j)=all(strcmp({''},P{i,j}));
          end
      end
  elseif itiscell==1
      for i=1:n
          for j=1:m
              out(i,j)=isempty(P{i,j});
          end
      end
  end

endfunction

