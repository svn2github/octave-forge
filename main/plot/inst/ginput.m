## Copyright (C) 2008 David Bateman
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## THis program distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{x}, @var{y}, @var{buttons}] =} ginput (@var{n})
## Return which mouse buttons were pressed and keys were hit on the current
## figure. If @var{n} is defined, then wait for @var{n} mouse clicks
## before returning. If @var{n} is not defined, then @code{ginput} will
## loop until the return key is pressed.
## @end deftypefn

## This is ginput.m implementation for gnuplot and X11.
## It requires gnuplot 4.1 and later.

## This file initially bore the copyright statement
## Petr Mikulik
## History: June 2006; August 2005; June 2004; April 2004
## License: public domain

function [x, y, button] = ginput (n)
  persistent have_mkfifo = ! ispc ();

  if (nargin > 1)
    print_usage ();
  endif

  f = gcf ();
  drawnow ();

  stream = get (f, "__plot_stream__");

  if (compare_versions (__gnuplot_version__ (), "4.0", "<="))
    error ("ginput: version %s of gnuplot not supported", gnuplot_version ());
  endif

  if (nargin == 0)
    x = zeros (100, 1);
    y = zeros (100, 1);
    button = zeros (100, 1);
  else
    x = zeros (n, 1);
    y = zeros (n, 1);
    button = zeros (n, 1);
  endif

  gpin_name = tmpnam ();

  if (have_mkfifo)
    ## Use pipes if not on Windows. Mode: 6*8*8 ==  0600
    [err, msg] = mkfifo(gpin_name, 6*8*8);

    if (err != 0)
      error ("ginput: Can not open fifo (%s)", msg);
    endif
  endif

  unwind_protect

    k = 0;
    while (true)
      k++;
      fprintf (stream, "set print \"%s\";\n", gpin_name);
      fflush (stream);
      if (have_mkfifo)
	[gpin, err] = fopen (gpin_name, "r");
	if (err != 0)
	  error ("ginput: Can not open fifo (%s)", msg);
	endif
      endif
      fputs (stream, "pause mouse any;\n\n");

      ## Notes: MOUSE_* can be undefined if user closes gnuplot by "q"
      ## or Alt-F4. Further, this abrupt close also requires the leading
      ## "\n" on the next line.
      fputs (stream, "\nif (exists(\"MOUSE_KEY\") && exists(\"MOUSE_X\")) print MOUSE_X, MOUSE_Y, MOUSE_KEY; else print \"0 0 -1\"\n");

      ## Close output file, otherwise all blocks (why?!).
      fputs (stream, "set print;\n");
      fflush (stream);

      if (! have_mkfifo)
	while (exist (gpin_name, "file") == 0)
	endwhile
	[gpin, msg] = fopen (gpin_name, "r");

	if (gpin < 0)
	  error ("ginput: Can not open file (%s)", msg);
	endif

	## Now read from file
	count = 0;
	while (count == 0)
	  [xk, yk, buttonk, count] = fscanf (gpin, "%f %f %d", "C");
	endwhile
	x(k) = xk;
	y(k) = yk;
	button (k) = buttonk;
      else
	## Now read from fifo.
	[x(k), y(k), button(k), count] = fscanf (gpin, "%f %f %d", "C");
      endif
      fclose (gpin);

      if ([x(k), y(k), button(k)] == [0, 0, -1])
	## Mousing not active (no plot yet).
	break;
      endif

      if (nargin > 0)
	## Input argument n was given => stop when k == n.
	if (k == n) 
	  break; 
	endif
      else
	## Input argument n not given => stop when hitting a return key.
	## if (button(k) == 0x0D || button(k) == 0x0A) 
	##   ## hit Return or Enter
	if (button(k) == 0x0D)
	  ## hit Return
	  x(k:end) = [];
	  y(k:end) = [];
	  button(k:end) = [];
	  break;
	endif
      endif
    endwhile

  unwind_protect_cleanup
    unlink (gpin_name);
  end_unwind_protect

endfunction
