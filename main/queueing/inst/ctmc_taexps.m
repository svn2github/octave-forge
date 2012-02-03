## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {@var{M} =} ctmc_taexps (@var{Q}, @var{tt}, @var{p})
##
## @cindex Markov chain, continuous time
## @cindex Time-alveraged sojourn time
##
## Compute the @emph{time-averaged sojourn time} @code{@var{M}(t,j)},
## defined as the fraction of the time interval @code{[0,@var{tt}(t))} spent in
## state @math{j}, assuming that at time 0 the state occupancy
## probability was @var{p}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## Infinitesimal generator matrix. @code{@var{Q}(i,j)} is the transition
## rate from state @math{i} to state @math{j},
## @math{1 @leq{} i \neq j @leq{} N}. The
## matrix @var{Q} must also satisfy the condition @code{sum(@var{Q},2) == 0}
##
## @item tt
## This parameter is a vector used for numerical integration of the
## sujourn time. The first element @code{@var{tt}(1)} must be slightly
## larger than 0, and the
## last element @code{@var{tt}(end)} must be the upper limit of the
## interval @math{[0,t)} of interest (@code{@var{tt}(end) == @math{t}}).
## This vector is used by the ODE solver to compute the solution
## @var{M}.
##
## @item p
## @code{@var{p}(i)} is the probability that, at time 0, the system was in
## state @math{i}, for all @math{i = 1, @dots{}, N}
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item M
## @code{@var{M}(t,j)} is the expected fraction of time spent in state
## @math{j} during the interval @math{[0,tt(t))} assuming that the state
## occupancy probability at time zero was @var{p}. @code{1 @leq{}
## @var{t} @leq{} length(@var{tt})}
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function M = ctmc_taexps( Q, t, p )

  persistent epsilon = 10*eps;

  if ( nargin != 3 )
    print_usage();
  endif

  issquare(Q) || \
      usage( "Q must be a square matrix" );

  N = rows(Q);

  ( norm( sum(Q,2), "inf" ) < epsilon ) || \
      usage( "Q is not an infinitesimal generator matrix" );

  ( isvector(p) && length(p) == N && all(p>=0) && abs(sum(p)-1.0)<epsilon ) || \
      usage( "p must be a probability vector" );
  t = t(:)'; # make t a row vector
  p = p(:)'; # make p a row vector
  ff = @(x,t) (((x')*(Q-eye(N)/t).+p/t)');
  fj = @(x,t) (Q-eye(N)/t);
  M = lsode( {ff, fj}, zeros(size(p)), t );
endfunction

%!demo
%! lambda = 0.5;
%! N = 4;
%! birth = lambda*linspace(1,N-1,N-1);
%! death = zeros(1,N-1);
%! Q = diag(birth,1)+diag(death,-1);
%! Q -= diag(sum(Q,2));
%! t = linspace(1e-3,50,500);
%! p = zeros(1,N); p(1)=1;
%! M = ctmc_taexps(Q,t,p);
%! plot(t, M(:,1), ";State 1;", "linewidth", 2, \
%!      t, M(:,2), ";State 2;", "linewidth", 2, \
%!      t, M(:,3), ";State 3;", "linewidth", 2, \
%!      t, M(:,4), ";State 4 (absorbing);", "linewidth", 2 );
%! legend("location","east");
%! xlabel("Time");
%! ylabel("Time-averaged Expected sojourn time");

## This example is from: David I. Heimann, Nitin Mittal, Kishor S. Trivedi,
## "Availability and Reliability Modeling for Computer Systems", sep 1989,
## section 2.5
%!demo
%! sec = 1;
%! min = sec*60;
%! hour = 60*min;
%! day = 24*hour;
%!
%! # state space enumeration {2, RC, RB, 1, 0}
%! a = 1/(10*min);    # 1/a = duration of reboot (10 min)
%! b = 1/(30*sec);    # 1/b = reconfiguration time (30 sec)
%! g = 1/(5000*hour); # 1/g = processor MTTF (5000 hours)
%! d = 1/(4*hour);    # 1/d = processor MTTR (4 hours)
%! c = 0.9;           # coverage
%! Q = [ -2*g 2*c*g 2*(1-c)*g      0  0; \
%!          0    -b         0      b  0; \
%!          0     0        -a      a  0; \
%!          d     0         0 -(g+d)  g; \
%!          0     0         0      d -d];
%! p = ctmc(Q);
%! printf("System availability: %f\n",p(1)+p(4));
%! TT = linspace(1e-5,1*day,101);
%! PP = ctmc_taexps(Q,TT,[1 0 0 0 0]);
%! A = At = Abart = zeros(size(TT));
%! A(:) = p(1) + p(4); # steady-state availability
%! for n=1:length(TT)
%!   t = TT(n);
%!   p = ctmc(Q,t,[1 0 0 0 0]);
%!   At(n) = p(1) + p(4); # instantaneous availability
%!   Abart(n) = PP(n,1) + PP(n,4); # interval base availability
%! endfor
%! semilogy(TT,A,";Steady-state;", \
%!      TT,At,";Instantaneous;", \
%!      TT,Abart,";Interval base;");
%! ax = axis();
%! ax(3) = 1-1e-5;
%! axis(ax);
