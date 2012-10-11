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

function C=cellmatprod(A,B)
  [nA mA]=size(A);
  [nB mB]=size(B);
  if mA~=nB
      disp('Internal Matrix dimension must agree')
  else
      C=cell(nA,mB);
      for i=1:nA
          for j=1:mB
              C{i,j}=cellstr('');
              for k=1:nB
                  X=cellprod(A{i,k},B{k,j});
                  C{i,j}=cellsum(C{i,j},X);
              end
          end
      end
  end
endfunction
