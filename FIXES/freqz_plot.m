## -*- texinfo -*-
## @deftypefn {Function File} freqz_plot (@var{w}, @var{h})
## Plot the pass band, stop band and phase response of @var{h}.
##
## @end deftypefn

function freqz_plot(w,h)
    n = length(w);
    ## ## exclude zero-frequency
    ## h = h(2:length(h));
    ## w = w(2:length(w));
    ## n = n-1;
    mag = 20*log10(abs(h));
    phase = unwrap(arg(h));
    maxmag = max(mag);

    unwind_protect # protect graph state
      if gnuplot_has_multiplot
      	subplot(311);
      	gset lmargin 10;
	axis("labely");
	xlabel("");
      endif
      grid("on");
      axis([w(1), w(n), maxmag-3, maxmag]);
      plot(w, mag, ";Pass band (dB);");

      if gnuplot_has_multiplot
      	subplot(312);
	axis("labely");
	title("");
	xlabel("");
      	gset tmargin 0;
      else
	input("press any key for the next plot: ");
      endif
      grid("on");
      if (maxmag - min(mag) > 100)
      	axis([w(1), w(n), maxmag-100, maxmag]);
      else
      	axis("autoy");
      endif
      plot(w, mag, ";Stop band (dB);");
      
      if gnuplot_has_multiplot
      	subplot(313);
	axis("label");
	title("");
      else
	input("press any key for the next plot: ");
      endif
      grid("on");
      axis("autoy");
      xlabel("Frequency");
      axis([w(1), w(n)]);
      plot(w, phase/(2*pi), ";Phase (radians/2pi);");
      
    unwind_protect_cleanup # restore graph state
      grid("off");
      axis("auto","label");
      gset lmargin;
      gset tmargin;
      oneplot();
    end_unwind_protect

endfunction
