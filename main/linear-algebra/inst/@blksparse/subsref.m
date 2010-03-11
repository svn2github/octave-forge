## Copyright (C) 2010 VZLU Prague
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

function ss = subsref (s, subs)
  if (length (subs) != 1)
    error ("blksparse: invalid index chain");
  endif
  if (strcmp (subs(1).type, "()"))
    nbl = size (s.sv, 3);
    ind = subs(1).subs;
    nind = length (ind);
    ## Specialize scalar indexing.
    is_numeric_scalar = @(x) numel (x) == 1 && isnumeric (x);
    if (is_numeric_scalar (ind{1}) && (nind == 1 || is_numeric_scalar (ind{2})))
      if (nind == 1)
        ind = (1:prod (s.siz))(ind{1}); # validate index
        k = find (sub2ind (s.siz, s.i, s.j) == ind);
      else
        ind1 = (1:s.siz(1))(ind{1}); # validate index
        ind2 = (1:s.siz(2))(ind{2}); # validate index
        k = find (s.i == ind{1} & s.j == ind{2}, 1);
      endif
      if (! isempty (k))
        ss = s.sv(:,:,k);
      else
        ss = zeros (s.bsiz, class (s.sv));
      endif
    else
      ## Do everything else via sparse indexing.
      sn = sparse (s.i, s.j, 1:nbl, s.siz(1), s.siz (2));
      sn = sn(ind{:});
      [i, j, k] = find (sn);
      ss = s;
      ss.i = i;
      ss.j = j;
      ss.sv = s.sv(:,:,k);
      ss.siz = size (sn);
    endif
  else
    error ("blksparse: only supports () indexing");
  endif

endfunction



