/*
 * Copyright (C) 2000 Laurent Mazet <mazet@crm.mot.com>
 *
 * This program is free software and may be used for any purpose.  This
 * copyright notice must be maintained.  Paul Kienzle is not responsible
 * for the consequences of using this software.
 */

/*
 * Graphics extention for hacking gnuplot on X11
 */

#include <string>

#include <octave/oct.h>
#include <octave/toplev.h>
#include <octave/parse.h>

extern "C" {
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
}

#include "graphics.h"

/*
 * Ask gnuplot for current figure
 */

string find_gnuplot_window (string func) 
{
  /* send gget command to get terminal */
  octave_value_list gget_args;
  gget_args(0) = "terminal";
  octave_value_list gget_ret = feval ("gget", gget_args, 0);

  /* get figure number */
  string st = gget_ret(0).string_value();
  int fig_nb = -1;
  if (st.length() > 2 && (st[0] == 'x' || st[0] == 'X') &&
      st[1] == '1' && st[2] == '1')
    fig_nb = strtol (st.substr(3, st.length()).c_str(), NULL, 10);

  /* check if there is a gnuplot figure */
  if (fig_nb < 0) {
    cerr << func << ": no figure." << endl;
    return ("");
  }

  /* Identify current figure window title */
  char win_name[11]; /* Big enough to hold "Gnuplot " + 2 digit number */
  if (fig_nb > 0)
    sprintf(win_name, "Gnuplot %2d", fig_nb);
  else
    strcpy(win_name, "Gnuplot");

  return (win_name);
}

/*
 * Recursively search the window heirarchy for a window of the given name
 */

Window find_x11_window(Display *display, Window top, string name)
{
  Window root, parent, *children, found;
  char *window_name;
  unsigned int N, i;

  /* Check if we've already got it */
  XFetchName(display, top, &window_name);
  if (!window_name==None && name.compare(window_name) == 0) {
    XFree(window_name);
    return top;
  }

  /* If not, recursively check all children */
  if (!XQueryTree(display, top, &root, &parent, &children, &N))
    return 0;
  found = 0;
  for (i=0; i < N; i++) {
    found = find_x11_window(display, children[i], name);
    if (found) break;
  }
  XFree(children);
  return found;
}

/*
 * Initialize gwindow structure
 */

int init_gwindow (gwindow &gw, string wname, string func)
{
  
  /* Find plot window from title */
  gw.display = XOpenDisplay(NULL);
  gw.screen = DefaultScreen(gw.display);
  gw.root = RootWindow(gw.display, gw.screen);
  gw.window = find_x11_window(gw.display, gw.root, wname);
  if (gw.window == 0) {
    cerr << func << ": plot window not found." << endl;
    XCloseDisplay (gw.display);
    return 0;
  }

  /* Make sure we can capture the clicks */
  XWindowAttributes wattr;
  XGetWindowAttributes(gw.display, gw.window, &wattr);
  if (wattr.all_event_masks & ButtonPressMask) {
    cerr << func << ": could not capture button events." << endl;
    XCloseDisplay (gw.display);
    return 0;
  }
  
  /* Set cross-hairs cursor */
  Cursor cursor;
  cursor = XCreateFontCursor (gw.display, XC_crosshair);
  XDefineCursor (gw.display, gw.window, cursor);

  /* Get width and height */
  Window wroot;
  int wx, wy;
  unsigned int bw;
  XGetGeometry(gw.display, gw.window,
	       &wroot, &wx, &wy, &gw.width, &gw.height, &bw, &gw.depth);

  /* Check scale and origin */
  octave_value_list gget_args, gget_ret;
  string st;
  char *second;

  gget_args(0) = "size";
  gget_ret = feval ("gget", gget_args, 0);
  st = gget_ret(0).string_value();
  gw.xscale = strtod (st.substr (st.rfind(" "), st.length()).c_str(), &second);
  gw.yscale = strtod (second+1, NULL);

  gget_args(0) = "origin";
  gget_ret = feval ("gget", gget_args, 0);
  st = gget_ret(0).string_value();
  gw.xorigin = strtod (st.c_str(), &second);
  gw.yorigin = strtod (second+1, NULL);

  return 1;
}

/*
 * close gwindow structure
 */

void close_gwindow (gwindow &gw)
{
  /* Stop watching for key/button press (among others) */
  XSelectInput (gw.display, gw.window, 0);

  /* Restore cursor */
  XUndefineCursor (gw.display, gw.window);
  XCloseDisplay (gw.display);
}

/*
 * warp on window center
 */

void warp_center (gwindow &gw)
{
  
  /* Warp to window center */
  XWarpPointer (gw.display, gw.root, gw.window, 0, 0,
		0, 0,
		int(gw.width*(gw.xorigin+gw.xscale/2)),
		int(gw.height*(1-gw.yorigin-gw.yscale/2)));

}

/*
 * Get one point or abort if any key. Return button number or 0 if abort.
 */

int get_point (gwindow &gw, int &x, int &y)
{

  /* Watch for key/button press (among others) */
  XSelectInput (gw.display, gw.window, ButtonPressMask|KeyPressMask);

  XEvent event;
  XNextEvent (gw.display, &event);
  if (event.type != ButtonPress)
    return 0;

  x = event.xbutton.x;
  y = event.xbutton.y;
  return event.xbutton.button;
}

/*
 * Get one area, one point or abort if any key. 
 * Return button number, 0  for a key, or -1 if abort.
 */

int get_area_point (gwindow &gw, MArray<int> &x, MArray<int> &y)
{

  /* Watch for key/button press (among others) */
  XSelectInput (gw.display, gw.window, ButtonPressMask|KeyPressMask);

  /* First point */
  XEvent event;
  XNextEvent (gw.display, &event);
  if (event.type != ButtonPress)
    return 0;

  if (x.length() != 2)
    x.resize(2);
  if (y.length() != 2)
    y.resize(2);
  
  x(0) = event.xbutton.x;
  y(0) = event.xbutton.y;
  if (event.xbutton.button != 1)
    return event.xbutton.button;

  XGCValues gcv;
  GC gc;
  
  // FIX ME! White is 0xffffff for TrueColor !
  gcv.function = GXxor;
  gcv.foreground = 0xffffff;
  gc = XCreateGC (gw.display, gw.window, GCForeground|GCFunction, &gcv);
  
  x(1) = x(0);
  y(1) = x(0);      
  
  XSelectInput (gw.display, gw.window,
		ButtonPressMask | PointerMotionMask | KeyPressMask);
  /* Loop to get second point */
  while (1) {
    XNextEvent (gw.display, &event);
    
    /* Erase old rectangle */
    if (x(1) != x(0) || y(1) != x(0))
      XDrawRectangle (gw.display, gw.window, gc,
		      (x(1) < x(0)) ? x(1) : x(0),
		      (y(1) < y(0)) ? y(1) : y(0),
		      abs (x(1) - x(0))+1,
		      abs (y(1) - y(0))+1);
    
    switch (event.type) {
    case ButtonPress:
      /* Check button and quit */
      x(1) = event.xbutton.x;
      y(1) = event.xbutton.y;
      return (event.xbutton.button == 1) ? 1 : -1;
      break;
      
    case MotionNotify:
      /* Draw new rectangle */
      x(1) = event.xmotion.x;
      y(1) = event.xmotion.y;
      if (x(1) != x(0) || y(1) != x(0))
	XDrawRectangle (gw.display, gw.window, gc,
			(x(1) < x(0)) ? x(1) : x(0),
			(y(1) < y(0)) ? y(1) : y(0),
			abs (x(1) - x(0))+1,
			abs (y(1) - y(0))+1);
      break;

    case KeyPress:
      /* Quit and send key code */
      return 0;
      break;
    }
  }

  return -1;
}


/*
 * Guess border from gnuplot image
 */

ColumnVector guess_border (gwindow &gw)
{

  // FIX ME! White is 0xffffffL for TrueColor !
  XImage *image = XGetImage (gw.display, gw.window,
			     int(gw.width*gw.xorigin),
			     int(gw.height*(1-gw.yorigin-gw.yscale)),
			     int(gw.width*gw.xscale),
			     int(gw.height*gw.yscale),
			     0xffffffL, ZPixmap);  
  int width = image->width;
  int height = image->height;
  
  /* compute line and column correlations */
  MArray<int> x_cor (width, 0);
  MArray<int> y_cor (height, 0);

  for (int i=0; i<width; i++)
    for (int j=0; j<height; j++)
      if (XGetPixel (image, i, j)) {
	x_cor (i) ++;
	y_cor (j) ++;
      }

  /* find two x minima */
  int x1=0;
  for (int i=1; i<width; i++)
    if (x_cor(i) < x_cor(x1))
      x1 = i;
  int x2 = (x1 == 0) ? 1 : 0;
  for (int i=0; i<width; i++)
    if (x_cor(i) < x_cor(x2) && i != x1 && i != x1-1 && i != x1+1)
      x2 = i;

  /* find two y minima */
  int y1=0;
  for (int j=0; j<height; j++)
    if (y_cor(j) < y_cor(y1))
      y1 = j;
  int y2 = (y1 == 0) ? 1 : 0;
  for (int j=0; j<height; j++)
    if (y_cor(j) < y_cor(y2) && j != y1 && j != y1-1 && j != y1+1)
      y2 = j;
  
  /* take multiplot into account */
  x1 += int(gw.width*gw.xorigin);
  x2 += int(gw.width*gw.xorigin);
  y1 += int(gw.height*(1-gw.yorigin-gw.yscale));
  y2 += int(gw.height*(1-gw.yorigin-gw.yscale));

  /* create axis vector */
  ColumnVector axis (4);

  axis(0) = (x1 < x2) ? x1 : x2;
  axis(1) = (x1 < x2) ? x2 : x1;
  axis(2) = (y1 < y2) ? y1 : y2;
  axis(3) = (y1 < y2) ? y2 : y1;
  
  // Freed image
  XFree (image);

  return axis;
}

/*
 * Guess axis
 */

ColumnVector guess_axis (string func)
{
  ColumnVector axis(4);
  octave_value_list gget_args, gget_ret;
  string st;

  /* Get xrange */
  gget_args(0) = "xrange";
  gget_ret = feval ("gget", gget_args, 0);
  st = gget_ret(0).string_value();

  /* Check if axis are set or if nowriteback option is not active */
  if (st.find("[ * : * ]") == 0 && st.find("nowriteback") < st.length()) {
    cerr << func << ": no axis set and `nowriteback' option active." << endl;
    return (ColumnVector (0));
  }

  if (st.find("[ * : * ]") == 0) {
    /* Writeback option is active */
    axis(0) =  strtod (st.substr(st.rfind("[")+1, st.length()).c_str(), NULL);
    axis(1) =  strtod (st.substr(st.rfind(":")+1, st.length()).c_str(), NULL);
  }
  else {
    /* Axis are set */
    axis(0) = strtod (st.substr(1, st.find(":")).c_str(), NULL);
    axis(1) = strtod (st.substr(st.find(":")+1, st.find("]")).c_str(), NULL);
  }

  /* Get yrange */
  gget_args(0) = "yrange";
  gget_ret = feval ("gget", gget_args, 0);
  st = gget_ret(0).string_value();

  /* Check if axis are set or if nowriteback option is not active */
  if (st.find("[ * : * ]") == 0 && st.find("nowriteback") < st.length()) {
    cerr << func << ": no axis set and `nowriteback' option active." << endl;
    return (ColumnVector (0));
  }

  if (st.find("[ * : * ]") == 0) {
    /* Writeback option is active */
    axis(2) =  strtod (st.substr(st.rfind("[")+1, st.length()).c_str(), NULL);
    axis(3) =  strtod (st.substr(st.rfind(":")+1, st.length()).c_str(), NULL);
  }
  else {    /* Axis are set */
    axis(2) = strtod (st.substr(1, st.find(":")).c_str(), NULL);
    axis(3) = strtod (st.substr(st.find(":")+1, st.find("]")).c_str(), NULL);
  }

  return axis;
}
