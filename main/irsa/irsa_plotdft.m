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
    gset nokey;
    title( "Spectrum represented in amplitudes and phases" );
    subplot(2,1,1);
    ylabel( "Amplitude" )
    plot( fxps, abs( fyps ) ); title("");
    subplot(2,1,2);
    xlabel( "Frequency" );
    ylabel( "Phase [rad/(2*pi)]" );
    ## gset yrange [-0.5:0.5];
    gset ytics 0.25
    plot( fxps, arg( fyps )/(2*pi) );
    ## Clean up gnuplot
    oneplot(); title(""); xlabel(""); ylabel("");
    gset ytics autofreq; gset key; gset autoscale; gset nogrid;
  endif

endfunction
