/*
 * Copyright (C) 2000 Paul Kienzle
 * This program is free software and may be used for any purpose.  This
 * copyright notice must be maintained.  Paul Kienzle is not responsible
 * for the consequences of using this software.
 */

/*
 * Laurent Mazet <mazet@crm.mot.com> (C) 2001
 *
 * - 1/4/01 -
 * Automatically choose the last figure and warp pointer on it.
 * Any key abort placement.
 * - 8/4/01 -
 * Use graphics library functions.
 */

#include <string>

#include <octave/oct.h>
#include <octave/toplev.h>
#include <octave/parse.h>

#include "graphics.h"
using namespace std;

DEFUN_DLD (gtext, args, ,
	   "-*- texinfo -*-\n"
	   "@deftypefn {Function File} {[@var{res}] =} gtext (@var{text})\n"
	   "\n"
           "Place @var{text} on the current graph at the position indicated by a mouse click.\n"
           "Use left button for left-justified text, middle button for centered\n"
           "text, or right button for right-justified text. Press any key to abort.\n"
           "\n"
           "@var{gtext} uses screen coordinates rather than graph\n"
           "coordinates to position the text, so expect it to shift from screen\n"
           "to print version.  If you want a good solution, get the mouse support\n"
           "patches for gnuplot.\n"
           "\n"
	   "res will be 1 if the operation is successful, otherwise it will be 0.\n"
	   "\n"
           "Warning: @var{gtext}() doesn't work with @var{multiplot}().\n"
	   "@end deftypefn") {
  int nargin = args.length ();
  if (nargin != 1) {
    print_usage ("gtext");
    return octave_value_list();
  }

  /* Ask gnuplot for current figure */
  string name = find_gnuplot_window ("gtext");
  if (name.length() == 0)
    return octave_value(0.0);

  /* Get window and initialize gwindow structure */ 
  gwindow gw;
  if (!init_gwindow (gw, name, "gtext"))
    return octave_value(0.0);

  /* Warp to window */
  warp_center (gw);

  /* Watch for key/button press (among others) */
  int x=0, y=0;
  int button = get_point (gw, x, y);

  close_gwindow (gw);

  if (!button)
    return octave_value(0.0);

  /* Determine click position */
  double rel_x = (double)x/double(gw.width);
  double rel_y = (double)(gw.height-y)/double(gw.height);

  /* do the text call */
  octave_value_list fargs;
  fargs(0) = rel_x;
  fargs(1) = rel_y;
  fargs(2) = args(0);
  fargs(3) = "Units";
  fargs(4) = "Screen";
  fargs(5) = "HorizontalAlignment";
  switch (button) {
  case 1:
  default:
    fargs(6) = "left";
    break;
  case 2:
    fargs(6) = "center";
    break;
  case 3:
    fargs(6) = "right";
    break;
  }
  feval ("text", fargs, 0);

  /* automatically replot */
  octave_value_list rargs;
  rargs(0) = "replot";
  feval ("eval", rargs, 0);

  return octave_value(1.0);
}
