## Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{ellipse} = } cov2ellipse (@var{K})
%% @deftypefnx {Function File} {[@var{ra} @var{rb} @var{theta}] = } cov2ellipse (@var{K})
%% @deftypefnx {Function File} {@dots{} = } cov2ellipse (@dots{}, @samp{tol},@var{tol})
%% Calculates ellipse parameters from covariance matrix.
%%
%% Run @code{demo cov2ellipse} to see an example.
%% 
%% @seealso{ellipses2d, cov2ellipse, drawEllipse}
%% @end deftypefn

function varargout = cov2ellipse (K, varargin);

  [R S W] = svd (K);
  theta = atan (R(1,1)/R(2,2));
  v     = sort (diag(S), 'ascend')';

  if nargout == 1
    varargout{1} = [0 0 v theta*180/pi];
  elseif nargout == 3
    varargout{1} = v(1);
    varargout{2} = v(2);
    varargout{3} = theta;
  end

endfunction

%!demo
%! K = [2 1; 1 2];
%! L = chol(K,'lower');
%! u = randn(1e3,2)*L';
%!
%! elli = cov2ellipse (K)
%!
%! figure(1)
%! plot(u(:,1),u(:,2),'.r');
%! hold on;
%! drawEllipse(elli,'linewidth',2);
%! hold off
%! axis tight
