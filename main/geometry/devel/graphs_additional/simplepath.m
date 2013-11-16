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

function [P cycle]=simplepath(P)
  [n m]=size(P);
  cycle=cell(n,1);
  for i=1:n
      for j=1:m
          if i==j && (n~=1 && m~=1)
              cycle{i}=P{i,j};
              P{i,j}={''};
          else
              for k=1:numel(P{i,j});
                  path=cell2mat(P{i,j}(k));
                  ind=findstr(path,[' ' num2str(i) ' ']);
                  if ~isempty(ind)
                      P{i,j}(k)={''};
                  end
              end
          end
      end
  end
endfunction
