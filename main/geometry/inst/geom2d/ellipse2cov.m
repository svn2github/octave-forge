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
%% @deftypefn {Function File} {@var{K} = } ellipse2cov (@var{elli})
%% @deftypefnx {Function File} {@var{K} = } ellipse2cov (@var{ra}, @var{rb})
%% @deftypefnx {Function File} {@var{K} = } ellipse2cov (@dots{}, @var{theta})
%% Calculates covariance matrix from ellipse.
%%
%% If only one input is given, @var{elli} must define an ellipse as described in
%% @command{ellipses2d}.
%% If two inputs are given, @var{ra} and @var{rb} define the half-lenght of the
%% axes.
%% If a third input is given, @var{theta} must be the angle of rotation of the
%% ellipse in radians, and in counter-clockwise direction.
%%
%% The output @var{K} contains the covariance matrix define by the ellipse.
%%
%% Run @code{demo ellipse2cov} to see an example.
%%
%% @seealso{ellipses2d, cov2ellipse, drawEllipse}
%% @end deftypefn

function K = ellipse2cov (elli, varargin);

  ra    = 1;
  rb    = 1;
  theta = 0;
  switch numel (varargin)
    case 0
    %% ellipse format
      if numel (elli) != 5
        print_usage ();
      end
      ra    = elli(1,3);
      rb    = elli(1,4);
      theta = elli(1,5)*pi/180;

    case 2
    %% ra,rb
      if numel (elli) != 1
        print_usage ();
      end
      ra = elli;
      rb = varargin{1};

    case 3
    %% ra,rb, theta
      if numel (elli) != 1
        print_usage ();
      end
      ra    = elli;
      rb    = varargin{1};
      theta = varargin{2};

    otherwise
      print_usage ();
  end

  T = createRotation (theta)(1:2,1:2);
  K = T*diag([ra rb])*T';

endfunction

%!demo
%! elli = [0 0 1 3 -45];
%!
%! % Create 2D normal random variables with covarinace defined by elli.
%! K = ellipse2cov (elli)
%! L = chol(K,'lower');
%! u = randn(1e3,2)*L';
%!
%! Kn = cov (u)
%!
%! figure(1)
%! plot(u(:,1),u(:,2),'.r');
%! hold on;
%! drawEllipse(elli,'linewidth',2);
%! hold off
%! axis tight
