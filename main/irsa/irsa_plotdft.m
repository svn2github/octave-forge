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

## usage:  [fxps, fyps] = irsa_plotdft (fxp, fyp)
##

function [fxps, fyps] = irsa_plotdft (fxp, fyp)

  if( nargin < 2 || nargin > 2 ) 
    usage( "[fxps, fyps] = irsa_plotdft (fxp, fyp)" );
  endif
  
  fxp(:); fyp(:);
  N = length( fxp );
  if( N != rows( fyp ) )
    error( "The rows of \'fyp\' and the length of \'fxp\' have to be equal." );
  endif
  lpfi = floor(N/2) + 1;		# last positive frequency index
  fxps = shift( fxp, -lpfi );
  fyps = shift( fyp, -lpfi );
  
  if( nargout > 0 )		# Exit function
    return;
  else				# Plot
    __gnuplot_set__ nokey;
    title( "Spectrum represented in amplitudes and phases" );
    subplot(2,1,1);
    ylabel( "Amplitude" )
    plot( fxps, abs( fyps ) ); title("");
    subplot(2,1,2);
    xlabel( "Frequency" );
    ylabel( "Phase [rad/(2*pi)]" );
    ## __gnuplot_set__ yrange [-0.5:0.5];
    __gnuplot_set__ ytics 0.25
    plot( fxps, arg( fyps )/(2*pi) );
    ## Clean up gnuplot
    oneplot(); title(""); xlabel(""); ylabel("");
    __gnuplot_set__ ytics autofreq; __gnuplot_set__ key; __gnuplot_set__ autoscale; __gnuplot_set__ nogrid;
  endif

endfunction
