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

#ifndef __GRAPHICS_H__
#define __GRAPHICS_H__

#include <string>

extern "C" {
#include <X11/Xlib.h>
}

typedef struct {
  Display *display;
  int screen;
  Window root;
  Window window;
  unsigned int width;
  unsigned int height;
  unsigned int depth;
  double xscale;
  double yscale;
  double xorigin;
  double yorigin;
} gwindow;

string find_gnuplot_window (string func);

Window find_x11_window(Display *display, Window top, string name);

int init_gwindow (gwindow &gw, string wname, string func);

void close_gwindow (gwindow &gw);

void warp_center (gwindow &gw);

int get_point (gwindow &gw, int &x, int &y);

int get_area_point (gwindow &gw, MArray<int> &x, MArray<int> &y);

ColumnVector guess_border (gwindow &gw);

ColumnVector guess_axis (string func);

#endif /* __GRAPHICS_H__ */
