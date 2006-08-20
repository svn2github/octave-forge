/*
 * Get graphical coordinates from screen
 * 
 * This contains bits of code hacked from the
 * X Consortium and from Octave. Please see the
 * appropriate licences. The rest is mine, and
 * you can do what you want with that part.
 * 
 * Copyright (C) 1997 Andy Adler <adler@ncf.ca>
 * 
 * Compile like this
 * mkoctfile -L/usr/X11R6/lib -lX11 -I/usr/X11R6/include/ gpick.cc 
 *
 * Please excuse the ugly code. I wrote while I was learning C.
 */

/*
 * Copyright (C) 2001 Laurent Mazet <mazet@crm.mot.com>
 *
 * - 28/3/01 -
 * Fix error handler to avoid octave core-dump.
 * Change to avoid the input limit.
 * Minimize the number of cliks for full x-y axis definitions.
 * Make the code a bit less ugly.
 * - 1/4/01 -
 * Guess border, no more need to click to define them.
 * - 8/4/01 -
 * Ask gnuplot to get axis if they're defined.
 * Take care of multiplot.
 * Use graphics library functions.
 */

/*
 * To do:
 *
 * Draw a flashing rectangle to insure that border are correct.
 * Fix XGetImage. Seems it's quite buggy !
 * Take care of logscale
 * Got some trouble when gnuplot does not split its window using equal size.
 */

#include <string>

#include <octave/oct.h>
#include <octave/toplev.h>
#include <octave/parse.h>

#include "graphics.h"

#define maxpoints 10

DEFUN_DLD (gpick, args, nargout,
	   "-*- texinfo -*-\n"
           "@deftypefn {Function File} {[@var{x}, [@var{y}]] =} gpick ()\n"
           "\n"
           "Gets points mouse clicks on Gnuplot figure. Select points with left mutton.\n"
	   "Middle button or right button quit. Press any key to abort.\n"
	   "`writeback' gnuplot option or axis limits  must be set.\n"
           "\n"
           "Warning: after using @var{gpick} axis are set.\n"
           "@end deftypefn") {

  /* Ask gnuplot for current figure */
  std::string name = find_gnuplot_window ("gpick");
  if (name.length() == 0)
    return octave_value();

  /* Ask gnuplot for axis limits */
  ColumnVector axis = guess_axis ("gpick");
  if (axis.length() == 0)
    return octave_value();

  octave_value_list axis_args;
  axis_args(0) = axis;
  feval ("axis", axis_args, 0);
  
  octave_value_list replot_args;
  replot_args(0) = "replot";
  feval ("eval", replot_args, 0);
  
  /* Get window and initialize gwindow structure */ 
  gwindow gw;
  if (!init_gwindow (gw, name, "gpick"))
    return octave_value();

  /* Warp to window */
  warp_center (gw);

  /* Guess border */
  ColumnVector guess_axis = guess_border (gw);
  
  /* Wait for a click */
  MArray<int> xc(maxpoints);
  MArray<int> yc(maxpoints);

  int nb_elements = 0;
  while (1) {

    int button = get_point (gw, xc (nb_elements), yc (nb_elements));
    
    // key pressed
    if (button == 0) {
      close_gwindow (gw);
      error("gpick: abort.");
      return octave_value ();
    }
    else if (button != 1)
      break;
    
    nb_elements++;
    
    if (nb_elements == xc.length()) {
      xc.resize (xc.length()+maxpoints);
      yc.resize (yc.length()+maxpoints);
    }
  }

  close_gwindow (gw);
  
  double xdiff = guess_axis(1) - guess_axis(0);
  double xm = -(axis(0)-axis(1)) / xdiff;
  double xb = (guess_axis(1)*axis(0)-guess_axis(0)*axis(1)) / xdiff;
  double ydiff = guess_axis(2) - guess_axis(3);
  double ym = -(axis(2)-axis(3)) / ydiff;
  double yb = (guess_axis(2)*axis(2)-guess_axis(3)*axis(3)) / ydiff;
  
  ColumnVector X(nb_elements), Y(nb_elements);
  for(int i=0; i<nb_elements; i++) {
    X(i) = xc(i)*xm + xb;
    Y(i) = yc(i)*ym + yb;
  };

  octave_value_list retval;
  retval(0) = X;
  if (nargout == 2) 
      retval(1) = Y;
  
  return retval;
}
