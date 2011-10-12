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
%% @deftypefn {Function File} {[ @var{r}, @var{c} ] = } ind2sub_tril (@var{N}, @var{idx})
%% Not documented
%%
%% @seealse{vech, ind2sub, sub2ind_tril}
%% @end deftypefn

function [r c] = ind2sub_tril(N,idx)

  endofrow = 0.5*(1:N) .* (2*N:-1:N + 1);
  c = lookup(endofrow, idx-1)+1;

  r = N - endofrow(c) + idx ;

end

%!shared N, diagind
%! N=4;
%! diagind = 1 + 0.5*(0:N-1).*( (2*N+1):-1:(N+2) );

%!test
%! A = -repmat (1:N,N,1);
%! A += A.' + repmat (diagind, N,1));
%! [r c] = ind2sub_tril (rows(A),1:10);
%! A_shouldbe = accumarray([r; c]',1:10);
%! assert (A,A_shouldbe)

