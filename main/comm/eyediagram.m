## Copyright (C) 2003 David Bateman
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} eyediagram (@var{x},@var{n})
## @deftypefnx {Function File} {} eyediagram (@var{x},@var{n},@var{per})
## @deftypefnx {Function File} {} eyediagram (@var{x},@var{n},@var{per},@var{off})
## @deftypefnx {Function File} {} eyediagram (@var{x},@var{n},@var{per},@var{off},@var{str})
## @deftypefnx {Function File} {} eyediagram (@var{x},@var{n},@var{per},@var{off},@var{str},@var{h})
## @deftypefnx {Function File} {@var{h} =} eyediagram (@var{...})
##
## Plot the eye-diagram of a signal. The signal @var{x} can be either in one
## of three forms
##
## @table @asis
## @item A real vector
## In this case the signal is assumed to be real and represented by the vector
## @var{x}. A single eye-diagram representing this signal is plotted.
## @item A complex vector
## In this case the in-phase and quadrature components of the signal are 
## plotted seperately.
## @item A matrix with two columns
## In this case the first column represents the in-phase and the second the
## quadrature components of a complex signal.
## @end table
##
## Each line of the eye-diagram has @var{n} elements and the period is assumed
## to be given by @var{per}. The time axis is then [-@var{per}/2 @var{per}/2].
## By default @var{per} is 1.
##
## By default the signal is assumed to start at -@var{per}/2. This can be
## overridden by the @var{off} variable, which gives the number of samples
## to delay the signal.
##
## The string @var{str} is a plot style string (example 'r+'),
## and by default is the default gnuplot line style.
##
## The figure handle to use can be defined by @var{h}. If @var{h} is not 
## given, then the next available figure handle is used. The figure handle
## used in returned on @var{hout}.
## @end deftypefn
## @seealso{scatterplot}

## 2005-04-23 Dmitri A. Sergatskov <dasergatskov@gmail.com>
##     * modified for new gnuplot interface (octave > 2.9.0)

function hout = eyediagram (x, n, _per, _off, str, h)

  if ((nargin < 2) || (nargin > 6))
    usage (" h = eyediagram (x, n [, per [, off [, str [, h]]]])");
  endif
  
  if (isreal(x))
    if (min(size(x)) == 1)
      signal = "real";
      xr = x(:);
    elseif (size(x,2) == 2)
      signal = "complex";
      xr = x(:,1);
      xr = x(:,2);
    else
      error ("eyediagram: real signal input must be a vector");
    endif
  else
    signal = "complex";
    if (min(size(x)) != 1)
      error ("eyediagram: complex signal input must be a vector");
    endif
    xr = real(x(:));
    xi = imag(x(:));
  endif
  
  if (!length(xr))
    error ("eyediagram: zero length signal");
  endif
  
  if (!isscalar(n) || !isreal(n) || (floor(n) != n) || (n < 1))
    error ("eyediagram: n must be a positive non-zero integer");
  endif

  if (nargin > 2)
    if (isempty(_per))
      per = 1;
    elseif (isscalar(_per) && isreal(_per))
      per = _per;
    else
      error ("eyediagram: period must be a real scalar");
    endif
  else
    per = 1;
  endif

  if (nargin > 3)
    if (isempty(_off))
      off = 0;
    elseif (!isscalar(_off) || !isreal(_off) || (floor(_off) != _off) || ...
	(_off < 0) || (_off > (n-1)))
      error ("eyediagram: offset must be an integer between 0 and n");
    else
      off = _off;
    endif
  else
    off = 0;
  endif

  if (nargin > 4)
    if (isempty(str))
      fmt = "w l 1";
    elseif (isstr(str))
      fmt = __pltopt__ ("eyediagram", str);
    else
      error ("eyediagram: plot format must be a string");
    endif
  else
    fmt = "w l 1";
  endif

  if (nargin > 5)
    if (isempty(h))
      if (!gnuplot_has_frames)
	hout = figure ();
      else
	hout = 0;
      endif
    elseif (!isscalar(h) || !isreal(h) || (floor(h) != h) || (h < 0))
      error ("eyediagram: figure handle must be a positive integer");
    else
      if (!gnuplot_has_frames)
	error ("eyediagram: gnuplot must have frames for figure handles");
      endif
      hout = figure (h);
    endif
  else
    if (!gnuplot_has_frames)
      hout = figure ();
    else
      hout = 0;
    endif
  endif

  neven = (2*floor(n/2) == n);
  if (neven)
    horiz = (per*[0:n]/n - per/2)';
  else
    horiz = (n-2)/(n-1)*(per*[0:n-1]/(n-1) - per/2)';
  endif
  lx = length(xr);
  off = mod(off+ceil(n/2),n);

  ## Need to save data to a temporary file, since we use line breaks
  ## in the file to specify a discontinous plot to gnuplot plot. This
  ## is much faster than multiple plot commands.....
  tmpfile = tmpnam();
  try mark_for_deletion(tmpfile);
  catch 
    warning("eyediagram: temporary file %s will not be deleted!\n",tmpfile)
  end
  fid = fopen(tmpfile,"w+");
  if (fid == -1)
    error ("eyediagram: error opening temporary file");
  endif
  if (strcmp(signal,"complex"))
    if (off != 0)
      fprintf(fid, "%10.3e %10.3e %10.3e\n", [horiz(n-off+1:n), xr(1:off), ...
					      xi(1:off)]');
      if (neven && (lx != off))
	fprintf(fid, "%10.3e %10.3e %10.3e\n", [horiz(n+1), xr(off+1), ...
						xi(off+1)]');
      endif
      fprintf(fid, "\n");
      indx = off;
    else
      indx = 0;
    endif

    while ((lx-indx) >= n)
      fprintf(fid, "%10.3e %10.3e %10.3e\n", [horiz(1:n), xr(indx+1:indx+n), ...
					      xi(indx+1:indx+n)]');
      if (neven && (lx != indx+n))
	fprintf(fid, "%10.3e %10.3e %10.3e\n", [horiz(n+1), xr(indx+n+1), ...
						xi(indx+n+1)]');
      endif
      fprintf(fid, "\n");
      indx = indx + n;
    endwhile

    if ((lx-indx) != 0)
      fprintf(fid, "%10.3e %10.3e %10.3e\n", [horiz(1:lx-indx), ...
					     xr(indx+1:lx), xi(indx+1:lx)]');
    endif
  else
    if (off != 0)
      fprintf(fid, "%10.3e %10.3e\n", [horiz(n-off+1:n), xr(1:off)]');
      if (neven && (lx != off))
	fprintf(fid, "%10.3e %10.3e\n", [horiz(n+1), xr(off+1)]');
      endif
      fprintf(fid, "\n");
      indx = off;
    else
      indx = 0;
    endif

    while ((lx-indx) >= n)
      fprintf(fid, "%10.3e %10.3e\n", [horiz(1:n), xr(indx+1:indx+n)]');
      if (neven && (lx != indx+n))
	fprintf(fid, "%10.3e %10.3e\n", [horiz(n+1), xr(indx+n+1)]');
      endif
      fprintf(fid, "\n");
      indx = indx + n;
    endwhile

    if ((lx-indx) != 0)
      fprintf(fid, "%10.3e %10.3e\n", [horiz(1:lx-indx), xr(indx+1:lx)]');
    endif
  endif
  fclose(fid);

  try ar = automatic_replot;
  catch ar = 0;
  end

  unwind_protect
    if (strcmp(signal,"complex"))
      subplot(2,1,1);
      title("Eye-diagram for in-phase signal");
    else
      oneplot();
      title("Eye-diagram for signal");
    endif
    xlabel("Time");
    ylabel("Amplitude");
    
    legend("off");
    hold off;
    __gnuplot_plot__  tmpfile ;
    if (strcmp(signal,"complex"))
      subplot(2,1,2);
      title("Eye-diagram for quadrature signal");
      __gnuplot_plot__ tmpfile using 1:3;
    endif

  unwind_protect_cleanup
    xlabel("");
    ylabel("");
    title("");
    if (strcmp(signal,"complex"))
      oneplot();
    endif
    automatic_replot = ar;
  end_unwind_protect

  ## XXX FIXME XXX
  ## Can't unlink the tmpfile now, since can't guarantee gnuplot finished
  ## with it!!!
  ## [u, msg] = unlink(tmpfile);

endfunction
