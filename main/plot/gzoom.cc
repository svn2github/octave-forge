/*
 * Copyright (C) 2001 Laurent Mazet
 * This program is free software and may be used for any purpose.  This
 * copyright notice must be maintained.  Paul Kienzle is not responsible
 * for the consequences of using this software.
 */

/*
 * Laurent Mazet <mazet@crm.mot.com> (C) 2001
 *
 * - 10/4/01 -
 * Initial release
 */


#include <string>

#include <octave/oct.h>
#include <octave/toplev.h>
#include <octave/parse.h>

#include "graphics.h"
using namespace std;

DEFUN_DLD (gzoom, args, ,
	   "usage: gzoom()\n"
	   "\n"
	   "Controls are:\n"
	   " * Use left button to zoom on an area.\n"
	   " * Use right button to zoom back on a point.\n"
	   " * Use middle button to quit and keep current axis settings.\n"
	   " * Press any key to quit and recover old axis setting") {

  /* Ask gnuplot for current figure */
  string name = find_gnuplot_window ("gzoom");
  if (name.length() == 0)
    return octave_value();

  /* Ask gnuplot for axis limits */
  ColumnVector initial_axis = guess_axis ("gzoom");
  if (initial_axis.length() == 0)
    return octave_value();
  ColumnVector axis = initial_axis;

  octave_value_list axis_args;
  axis_args(0) = initial_axis;
  feval ("axis", axis_args, 0);
  
  octave_value_list replot_args;
  replot_args(0) = "replot";
  feval ("eval", replot_args, 0);
  
  /* Get window and initialize gwindow structure */ 
  gwindow gw;
  if (!init_gwindow (gw, name, "gzoom"))
    return octave_value();

  /* Warp to window */
  warp_center (gw);

  /* Guess border */
  ColumnVector guess_axis = guess_border (gw);
  
  MArray<int> x(2);
  MArray<int> y(2);
  
 /* Watch for key/button press (among others) */
  while (1) {

    /* Compute real coordonnates */
    double xdiff = guess_axis(1) - guess_axis(0);
    double xm = -(axis(0)-axis(1)) / xdiff;
    double xb = (guess_axis(1)*axis(0)-guess_axis(0)*axis(1)) / xdiff;
    double ydiff = guess_axis(2) - guess_axis(3);
    double ym = -(axis(2)-axis(3)) / ydiff;
    double yb = (guess_axis(2)*axis(2)-guess_axis(3)*axis(3)) / ydiff;
    
    switch (get_area_point (gw, x, y)) {
    case 0:
      /* Key pressed */
      axis_args(0) = initial_axis;
      feval ("axis", axis_args, 0);
      feval ("eval", replot_args, 0);
      close_gwindow (gw);
      return octave_value();
      break;

    case 1:
      /* Left button */

      /* Choice axis */
      axis(0) = ((x(0) > x(1)) ? x(1) : x(0))*xm + xb;
      axis(1) = ((x(0) > x(1)) ? x(0) : x(1))*xm + xb;
      axis(2) = ((y(0) < y(1)) ? y(1) : y(0))*ym + yb;
      axis(3) = ((y(0) < y(1)) ? y(0) : y(1))*ym + yb;

      /* Send gnuplot commands */
      axis_args(0) = axis;
      feval ("axis", axis_args, 0);
      feval ("eval", replot_args, 0);
      break;
      
    case 2:
      /* Middle button */
      close_gwindow (gw);
      return octave_value();
      break;

    case 3:
      /* Right button */

      xdiff = axis(1)-axis(0);
      ydiff = axis(3)-axis(2);

      /* Choice axis */
      axis(0) = x(0)*xm + xb - xdiff;
      axis(1) = x(0)*xm + xb + xdiff;
      axis(2) = y(0)*ym + yb - ydiff;
      axis(3) = y(0)*ym + yb + ydiff;

      /* Send gnuplot commands */
      axis_args(0) = axis;
      feval ("axis", axis_args, 0);
      feval ("eval", replot_args, 0);
      break;
    }
  }
}
