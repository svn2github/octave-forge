/*
 * Get graphical coordinates from screen
 * 
 * This contains bits of code hacked from the
 * X Consortium and from Octave. Please see the
 * appropriate licences. The rest is mine, and
 * you can do what you want with that part.
 * 
 * Andy Adler <adlera@ncf.ca> (C) 1997
 * 
 * Compile like this
 * mkoctfile -L/usr/X11R6/lib -lX11 -I/usr/X11R6/include/ ginput.cc 
 *
 * Please excuse the ugly code. I wrote while I was learning C.
 */

#include <octave/config.h>
#include <iostream.h>

#include <octave/pager.h>

#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/help.h>
#include <octave/symtab.h>
#include <octave/oct-obj.h>
#include <octave/utils.h>

#include <X11/Xlib.h>
#include <X11/cursorfont.h>

#define maxpoints 100

DEFUN_DLD (ginput, args, nargout ,
  "[...] = ginput (...)\n\
\n\
GINPUT: gets points mouse clicks on the screen\n\
 \n\
[x,y]= ginput(axis)\n\
 x -> x coordinates of the points\n\
 y -> y coordinates of the points\n\
\n\
 axis -> if specified then the first 2 (or 4) clicks\n\
      must be on the appropriate axes. x and y (or just x\n\
      if only 2 points specified ) will then be normalised.\n\
\n\
for example: x=ginput([1 10]) \n\
   the first two clicks should correspond to x=1 and x=10 \n\
   subsequent clicks will then be normalized to graph units.  \n\
\n\
for example: [x,y]=ginput; \n\
   gives x and y in screen pixel units (upper left = 0,0 ) \n\
\n\
select points with button #1. Buttons 2 and 3 quit. ")
{
  XEvent event;
  XButtonEvent *e;
  Cursor  cursor;
  Display *dpy;
  int     xc[maxpoints],yc[maxpoints],nc=0;
  octave_value_list retval;

  int nargin = args.length();

  if (nargin > 1) {
    print_usage ("ginput");
    return retval;
  }
  else if (nargin == 1) {
    Matrix axis= args(0).matrix_value();

    nc= args(0).columns();
    
    if (nc==2 || nc==4) 
      octave_stdout << "First click on x-axis points " << 
                axis(0,0) << ", " << axis(0,1) <<"\n";
    if (nc==4) 
      octave_stdout << "Then click on y-axis points " << 
                axis(0,2) << ", " << axis(0,3) <<"\n";
    flush_octave_stdout ();
  }

  char *displayname = NULL;
  dpy = XOpenDisplay (displayname);

  if (!dpy) {
    fprintf(stderr,"GINPUT:  unable to open display %s\n",
                    XDisplayName(displayname));
    exit (1);
  }

  cursor = XCreateFontCursor(dpy, XC_crosshair);

  /* Grab the pointer using target cursor, letting it room all over */
  Window root = RootWindow(dpy,0);
  int done = XGrabPointer(dpy, root, False, ButtonPressMask,
         GrabModeSync, GrabModeAsync, root, cursor, CurrentTime);
  if (done != GrabSuccess) {
    fprintf(stderr,"GINPUT: Can't grab the mouse.\n");
    exit(1);
  };

  int m=0;
  do {
    XAllowEvents(dpy, SyncPointer, CurrentTime);
    XWindowEvent(dpy, root, ButtonPressMask, &event);

    e = (XButtonEvent *) &event;

    xc[m]= e->x_root;
    yc[m]= e->y_root;

/*
    printf("%d,%d,(%d,%d),B=%u,t=%lu\n",
         e->x, e->y, e->x_root, e->y_root, e->button, e->time);
*/
  } while (e->button == 1 && ++m < maxpoints);

  if (m < nc) {
    fprintf(stderr,"GINPUT: Not enough points selected.\n");
    exit(1);
  };

  double xb=0, xm=1, yb=0, ym=1;
  if (nc==2 || nc==4) {
    Matrix axis= args(0).matrix_value();

    xm= (axis(0,0)-axis(0,1)) / (xc[0]-xc[1]);
    xb= (xc[1]*axis(0,0)-xc[0]*axis(0,1)) / (xc[1]-xc[0]);

//  octave_stdout << "xm=" << xm << " xb=" << xb ;

    if (nc==4) {
      ym= (axis(0,2)-axis(0,3)) / (yc[2]-yc[3]);
      yb= (yc[3]*axis(0,2)-yc[2]*axis(0,3)) / (yc[3]-yc[2]);
    };
  };
  
  ColumnVector x(m-nc),y(m-nc);
  for(int i=nc; i<m; i++) {
    x(i-nc)= (double) xc[i]*xm + xb;
    y(i-nc)= (double) yc[i]*ym + yb;
  };

  XUngrabPointer(dpy, CurrentTime);      /* Done with pointer */
  XCloseDisplay (dpy);

  retval(0) = x;
  if (nargout == 2) 
      retval(1) = y;
  
  return retval;
}

