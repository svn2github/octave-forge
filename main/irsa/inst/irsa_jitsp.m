## Copyright (C) 2003 Joerg Huber 
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
## USA

## -*- texinfo -*-
## @deftypefn {Function File} {irsa_jitsp.m}
## @var{jitxp} = irsa_jitsp (@var{Tm}, @var{jit}, @var{N} [, @var{rfunc}])
##
## Generate @var{N} sampling points with a minimum distance @var{Tm} and
## an additional random distance @var{jit} with random distribution
## @var{rfunc}
## 
## Input:
##
## @var{Tm}   : Scalar -- mean sampling period
##
## @var{N}    : Scalar -- number of sampling points to generate
##
## @var{jit}  : Scalar -- factor in [0,1] describing the part of Tm
## which is jittered.
## 
## @var{rfunc}: String (i.e. in quotes) of a random distribution
## function. Has to take the number of rows as the first and the number of
## columns as the second argument. Default is 'rand'.
##
## @var{rmin} : Scalar -- Lower limit of random distribution function
## computed with @var{rfunc}
##
## @var{rmax} : Scalar -- Upper limit of random distribution function
##
## Output:
##
## @var{jitxp} : Columnvector -- sampling points with a jitter
##
## @emph{Note:}
## 
## 1) The first sampling point will be 0, the last (N-1)*Tm. No
## jitter is added to them.
##
## 2) If you use a random distribution function and dont give a upper
## or lower limit it's assumed to be limited by its present computed
## maximum or minimum values.
## @end deftypefn

function jitxp = irsa_jitsp( Tm, N, jit, rfunc, rmin, rmax )

  if( nargin < 2 || nargin > 6 )
    usage( "jitsp = irsa_jitsp( Tm, N, [jit], [rfunc], [rmin], [rmax] )" );
  endif

  if( nargin < 3 || isempty( jit ) )
    jit = 1;
  endif
  if( nargin < 4 || isempty( rfunc ) )
    rfunc = "rand";
    rmin = 0;
    rmax = 1;
    default = true;
  else
    default = false;
  endif
  r = feval( rfunc, N-2, 1 );
  if( !default )
    if( nargin < 5 || isempty( rmin ) )
      rmin = min(r);
    endif
    if( nargin < 4 || isempty( rmax ) )
      rmax = max(r);
    endif
  endif

  if( jit < 0 || jit > 1 )
    error( "The jitter has to be a factor in [0,1]" );
  endif

  if( any( r > rmax ) )
    error( "Upper limit for 'rfunc' violated." );
  endif
  if( any( r < rmin ) )
    error( "Lower limit for 'rfunc' violated." );
  endif
  ## Scale the distribution of r to [-jit/2,jit/2]
  r -= rmin;
  r /= rmax;			# r is now in [-1,1]
  r -= 0.5;			
  r *= jit;			# r is now in [-jit/2,jit/2]
  
  jitxp = linspace(0,N-1,N)' * Tm;
  jitxp(2:N-1) .+= r;	   
endfunction

## demo section
%!demo
%! N = 12;
%! eqxp = irsa_jitsp( 1 , N, 0 ) + 1;
%! jitxp = irsa_jitsp( 1 , N, 1 ) + 1;
%! o = ones(N,1);
%! ## Plot 
%! __gnuplot_set__ nokey
%! __gnuplot_set__ xrange [0:13]
%! __gnuplot_set__ yrange [0:1.5]
%! __gnuplot_set__ xtics 1
%! __gnuplot_set__ mxtics 2
%! __gnuplot_set__ grid mxtics
%! __gnuplot_set__ noytics
%! subplot( 211 );
%! title( "Jittered Sampling versus regular (equidistant) sampling" );
%! text( 2,1.25, 'regular sampling with distance = 1' );
%! plot( eqxp, o, '^3', eqxp, o, '@*3' ); text(); title("");
%! subplot( 212 );
%! xlabel( "Time" );
%! text( 2,1.25, 'jittered sampling with mean distance = 1 and i.i.d. jitter within a range of 1' ); 
%! plot( jitxp, o, '^1', jitxp, o, '@x1' ); text; 
%! oneplot();
%! ## Clean up gnuplot
%! __gnuplot_set__ key; __gnuplot_set__ autoscale; __gnuplot_set__ xtics autofreq; __gnuplot_set__ ytics autofreq;
%! __gnuplot_set__ nox2tics; __gnuplot_set__ nogrid; __gnuplot_set__ nomxtics; 
%! xlabel(""); title(""); ylabel("");

### Local Variables:
### mode: octave
### End:
