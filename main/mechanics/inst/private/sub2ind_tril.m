%% Copyright (c) 2010 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
%% @deftypefn {Function File} {ind = } sub2ind_tril (@var{N}, @var{r}, @var{c})
%% Not documented
%%
%% @seealse{vech, sub2ind}
%% @end deftypefn

function ind = sub2ind_tril(N,r,c)

  R = zeros(size(r));
  C = zeros(size(c));
  
  below = r >= c;
  above = !below;
  R(below) = r(below);
  C(below) = c(below);
  
  R(above) = c(above);
  C(above) = r(above);

  ind = sub2ind ([N N],R,C) - C.*(C-1)/2;

end

%!shared N, diagind
%! N = 2;
%! diagind = 1 + 0.5*(0:N-1).*( (2*N+1):-1:(N+2) );

%!assert (diagind, sub2ind_tril(N,1:N,1:N)) % diagonal indexes

%!test
%! A = - repmat (1:N, N, 1);
%! A += repmat (diagind, N, 1) - A.';
%! [r c] = ind2sub_tril (N, 1:N*(N+1)/2);
%! assert (sub2ind_tril (N,r',c'), vech (A)) % Full matrix

