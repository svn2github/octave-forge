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
%% @deftypefn {Function File} {[ @var{r}, @var{c} ] = } vech2mat (@var{v}, @var{symm})
%% Transforms a 1D array to a symmetric or antisymmetric matrix.
%%
%% Given a Nx1 array @var{v} describing the lower triangular part of a
%% matrix (as obtained from @code{vech}), it returns the full matrix with the
%% symmetry specified by @var{symm}. If @var{symm} is 1 the function returns
%% a symmetric matrix. It returns an antisymmetric when @var{symm} is -1.
%% If @var{symm} is omitted a symmetric matrix is returned.
%% 
%%
%% @seealso{vech, ind2sub, sub2ind_tril}
%% @end deftypefn

function M = vech2mat(v, symm=1)

    N = length (v);
    dim = (sqrt ( 1 + 8*N ) - 1)/2;
    [r c] = ind2sub_tril (dim, 1:N);
    M = accumarray ([r; c].', v);
    M += symm*tril (M, -1).';

endfunction

%!test %symmetric
%! dim = 10;
%! A = tril( floor ( 5*(2*rand(dim)-1) ) );
%! A += A.';
%! M = vech(A);
%! M = vech2mat(M, 1);
%! assert (A, M);

%!test %antisymmetric
%! dim = 10;
%! A = tril( floor ( 5*(2*rand(dim)-1) ) );
%! A -= A.';
%! M = vech(A);
%! M = vech2mat(M, -1);
%! assert (A, M);

