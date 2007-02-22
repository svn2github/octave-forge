## Copyright (C) 2006 David Bateman
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{s} =} svds (@var{a})
## @deftypefnx {Function File} {@var{s} =} svds (@var{a}, @var{k})
## @deftypefnx {Function File} {@var{s} =} svds (@var{a}, @var{k}, @var{sigma})
## @deftypefnx {Function File} {@var{s} =} svds (@var{a}, @var{k}, @var{sigma}, @var{opts})
## @deftypefnx {Function File} {[@var{u}, @var{s}, @var{v}, @var{flag}] =} svds (@dots{})
##
## Find a few singular values of the matrix @var{a}. The singular values
## are calculated using 
##
## @example
## @group
## [@var{m}, @var{n}] = size(@var{a})
## @var{s} = eigs([sparse(@var{m}, @var{m}), @var{a}; @dots{}
##                 @var{a}', sparse(@var{n}, @var{n})])
## @end group
## @end example
##
## The eigenvalues returned by @code{eigs} correspond to the singular
## values of @var{a}. The number of singular values to calculate is given
## by @var{k}, whose default value is 6.
## 
## The argument @var{sigma} can be used to specify which singular values
## to find. @var{sigma} can be either the string 'L', the default, in 
## which case the largest singular values of @var{a} are found. Otherwise
## @var{sigma} should be a real scalar, in which case the singular values
## closest to @var{sigma} are found. Note that for relatively small values
## of @var{sigma}, there is the chance that the requested number of singular
## values are not returned. In that case @var{sigma} should be increased.
##
## If @var{opts} is given, then it is a structure that defines options
## that @code{svds} will pass to @var{eigs}. The possible fields of this
## structure are therefore determined by @code{eigs}. By default three
## fields of this structure are set by @code{svds}.
##
## @table @code
## @item tol
## The required convergence tolerance for the singular values. @code{eigs}
## is passed @var{tol} divided by @code{sqrt(2)}. The default value is 
## 1e-10.
##
## @item maxit
## The maximum number of iterations. The defaut is 300.
##
## @item disp
## The level of diagnostic printout. If @code{disp} is 0 then there is no
## printout. The default value is 0.
## @end table
##
## If more than one output argument is given, then @code{svds} also
## calculates the left and right singular vectors of @var{a}. @var{flag}
## is used to signal the convergence of @code{svds}. If @code{svds} 
## converges to the desired tolerance, then @var{flag} given by
##
## @example
## @group
## norm (@var{a} * @var{v} - @var{u} * @var{s}, 1) <= @dots{}
##         @var{tol} * norm (@var{a}, 1)
## @end group
## @end example
##
## will be zero.
## @end deftypefn
## @seealso{eigs}

function [u, s, v, flag] = svds (a, k, sigma, opts)

  if (nargin < 1 || nargin > 4)
    error ("Incorrect number of arguments");
  endif

  if (nargin < 4)
    opts.tol = 1e-10 / sqrt(2);
    opts.disp = 0;
    opts.maxit = 300;
  else
    if (!isstruct(opts))
      error("opts must be a structure");
    endif
    if (!isfield(opts,"tol"))
      opts.tol = 1e-10 / sqrt(2);
    endif
  endif

  if (nargin < 3 || strcmp(sigma,"L"))
    if (isreal(a))
      sigma = "LA";
    else
      sigma = "LR";
    endif
  elseif (isscalar(sigma) && isreal(sigma))
    if ((sigma < 0))
      error ("sigma must be a positive real value");
    endif
  else
    error ("sigma must be a positive real value or the string 'L'");
  endif

  maxA = max(max(abs(a)));
  if (maxA == 0)
    u = eye(m, k);
    s = zeros(k, k);
    v = eye(n, k);
  else
    [m, n] = size(a);
    if (nargin < 2)
      k = min([6, m, n]);
    else
      k = min([k, m, n]);
    endif

    ## Scale everything by the 1-norm to make things more stable.
    B = a / maxA;
    Bopts = opts;
    Bopts.tol = opts.tol / maxA;
    Bsigma = sigma;
    if (!ischar(Bsigma))
      Bsigma = Bsigma / maxA;
    endif

    if (!ischar(Bsigma) && Bsigma == 0)
      ## The eigenvalues returns by eigs are symmetric about 0. As we 
      ## are only interested in the positive eigenvalues, we have to
      ## double k. If sigma is smaller than the smallest singular value
      ## this can also be an issue. However, we'd like to avoid double
      ## k for all scalar value of sigma...
      [V, s, flag] = eigs ([sparse(m,m), B; B', sparse(n,n)], 
			   2 * k, Bsigma, Bopts);
    else
      [V, s, flag] = eigs ([sparse(m,m), B; B', sparse(n,n)],
			   k, Bsigma, Bopts);
    endif
    s = diag(s);

    if (isstr(sigma))
      norma = max(s);
    else
      norma = normest(a);
    endif
    V = sqrt(2) * V;
    u = V(1:m,:);
    v = V(m+1:end,:);

    ## We wish to exclude all eigenvalues that are less than zero as these
    ## are artifacts of the way the matrix passed to eigs is formed. There 
    ## is also the possibility that the value of sigma chosen is exactly 
    ## a singular value, and in that case we're dead!! So have to rely on 
    ## the warning from eigs. We exclude the singular values which are
    ## less than or equal to zero to within some tolerance scaled by the
    ## norm since if we don't we might end up with too many singular
    ## values. What is appropriate for the tolerance?
    tol = norma * opts.tol;
    ind = find(s > tol);
    if (length(ind) < k)
      ## Find the zero eigenvalues of B, Ignore the eigenvalues that are 
      ## nominally negative.
      zind = find(abs(s) <= tol);
      p = min(length(zind), k-length(ind));
      ind = [ind;zind(1:p)];
    elseif (length(ind) > k)
      ind = ind(1:k);
    endif
    u = u(:,ind);
    s = s(ind);
    v = v(:,ind);

    if (length(s) < k)
      warning("returning fewer singular values than requested.");
      if (!ischar(sigma))
	warning("try increasing the value of sigma");
      endif
    endif

    s = s * maxA;
  endif

  if (nargout < 2)
    u = s;
  else
    s = diag(s);
    if (nargout > 3)
      flag = norm(a*v - u*s, 1) > sqrt(2) * opts.tol * norm(a, 1);
    endif
  endif
endfunction

%!shared n, k, a, u, s, v, opts
%! n = 100;
%! k = 7;
%! a = sparse([3:n,1:n,1:(n-2)],[1:(n-2),1:n,3:n],[ones(1,n-2),0.4*n*ones(1,n),ones(1,n-2)]);
%! %%a = sparse([3:n,1:n,1:(n-2)],[1:(n-2),1:n,3:n],[ones(1,n-2),1:n,-ones(1,n-2)]);
%! [u,s,v] = svd(full(a));
%! s = diag(s);
%! [dum, idx] = sort(abs(s));
%! s = s(idx);
%! u = u(:,idx);
%! v = v(:,idx);
%! randn('state',42)
%!test
%! [u2,s2,v2,flag] = svds(a,k);
%! s2 = diag(s2);
%! assert(flag,!1);
%! assert(s(end:-1:end-k+1), s2, 1e-10); 
%!test
%! [u2,s2,v2,flag] = svds(a,k,0);
%! s2 = diag(s2);
%! assert(flag,!1);
%! assert(s(k:-1:1), s2, 1e-10); 
%!test
%! idx = floor(n/2);
%! % Don't put sigma right on a singular value or there are convergence 
%! sigma = 0.99*s(idx) + 0.01*s(idx+1); 
%! [u2,s2,v2,flag] = svds(a,k,sigma);
%! s2 = diag(s2);
%! assert(flag,!1);
%! assert(s((idx+floor(k/2)):-1:(idx-floor(k/2))), s2, 1e-10); 
