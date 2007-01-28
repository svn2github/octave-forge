/*
Copyright (C) 2007, Thomas Treichl <treichl@users.sourceforge.net>
OdePkg - Package for solving ordinary differential equations with octave

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

#ifdef HAVE_CONFIG_H
  #include "config.h"  /* Needed for #defines if compiled with mkoctfile */
#endif

#include <mex.h>       /* Needed for all mex definitions */
#include <string.h>    /* Needed for the memcpy function */
#include <stdio.h>     /* Needed for the sprintf function */
#include "odepkgext.h" /* Needed for the odepkg interfaces */
#include "odepkgmex.h" /* Needed for the mex extensions */

/**
 * fodepkgvar - Stores mxArrays in an internal variable
 * @vdeci: The decision for what has to be done
 * @vname: The name of the variable that is stored
 * @vvalue: The value of the stored variable
 *
 * If @vdeci is 0 (@vname is %NULL and @vvalue is %NULL) then this
 * function is initialized. Otherwise if @vdeci is 1 (@vname must be
 * the name of the variable and @vvalue must be a pointer to its
 * value) the variable is set and will be stored, if @vdeci is 2 the
 * value of the stored variable will be returned (@vname is the name
 * of the variable and @vvalue is a pointer to the place to where its
 * value should be returned). If @vdeci is 3 then the variable is
 * removed from the internal storage system (@vname must be the name
 * of the variable and @vvalue is a %NULL pointer). @vdeci should be
 * set 4 if cleaning up has to be performed normally at the end of a
 * function call (@vname is %NULL and @vvalue is %NULL).
 *
 * This function will be mainly used to suppress the use of global
 * variables in C-function with mex-support.
 *
 * Return value: On success the constant %true, otherwise %false.
 **/
bool fodepkgvar (const unsigned int vdeci, const char *vname, mxArray **vvalue) {
  int  cone = 1;
  bool vret = false;
  int  vnmb = 0;

  static mxArray *vodesetvar = NULL;

  switch (vdeci) {
    case 0:  /* Initialisation has to be performed */
      vodesetvar = mxCreateStructArray (1, &cone, 0, NULL);
      vret = true;
      break;

    case 1:  /* Setting a value has to be performed */
      mxAddField (vodesetvar, vname);
      vnmb = mxGetFieldNumber (vodesetvar, vname);
      mxSetFieldByNumber (vodesetvar, 0, vnmb, mxDuplicateArray (vvalue[0]));
      vret = true; /* mxDuplicateArray is used to delete variable outside */
      break;

    case 2:  /* Getting a value has to be performed */
      vnmb = mxGetFieldNumber (vodesetvar, vname);
      vvalue[0] = mxGetFieldByNumber (vodesetvar, 0, vnmb);
      vret = true;
      break;

    case 3:  /* Removing a structure field and its value */
      vnmb = mxGetFieldNumber (vodesetvar, vname);
      mxRemoveField (vodesetvar, vnmb);
      vret = true;
      break;

    case 4:  /* Removing the whole structure and clear memory */
      mxDestroyArray (vodesetvar);
      vret = true;
      break;

#ifdef __ODEPKGDEBUG__
    case 9:  /* Disp the whole structure (for debugging purpose) */
      mexCallMATLAB (0, NULL, 1, &vodesetvar, "disp");
      vret = true;
      break;
#endif

    default: /* Nothing has to done, get out of here */
      break;
    }
  return (vret);
}

/**
 * fsolstore - Stores a mxArray time- and solution vector
 * @vdeci: The decision for what has to be done
 * @vt: A pointer to the time value mxArray
 * @vy: A pointer to the mxArray solution vector
 *
 * If @vdeci is 0 (@vt is a pointer to the initial time step and @vy
 * is a pointer to the initial values vector) then this function is
 * initialized. Otherwise if @vdeci is 1 (@vt is a pointer to another
 * time step and @vy is a pointer to the solution vector) the values
 * of @vt and @vy are added to the internal variable, if @vdeci is 2
 * then the newly allocated internal vectors are returned as pointer
 * @vt and @vy. If @vdeci is 4 (@vdeci being 3 is unused for
 * compatibility with function fodepkgvar) then the internal variable
 * is cleaned up and the memory is free.
 *
 * This function will be mainly used to suppress the use of global
 * variables for storing a time and solution vector in C-functions
 * with mex-support.
 *
 * Return value: On success the constant %true, otherwise %false.
 **/
bool fsolstore (unsigned int vdeci, mxArray **vt, mxArray **vy) {
  bool vret = false;
  static int vdim = 0;
  static int vcnt = 0;
  static double *vtstore = NULL;
  static double *vystore = NULL;

  switch (vdeci) {
    case 0:
      vtstore = (double *) mxMalloc (1 * sizeof (double));
      memcpy ((void *) (vtstore + 0), (void *) mxGetPr (vt[0]), 1 * sizeof (double));
      vdim = mxGetNumberOfElements (vy[0]);
      vystore = (double *) mxMalloc (vdim * sizeof (double));
      memcpy ((void *) (vystore + 0), (void *) mxGetPr (vy[0]), vdim * sizeof (double));
      vcnt = 0; vcnt++; vret = true; break;

    case 1:
      vtstore = (double *) mxRealloc (vtstore, (vcnt+1) * sizeof (double));
      memcpy ((void *) (vtstore+vcnt), (void *) mxGetPr (vt[0]), sizeof (double));
      vystore = (double *) mxRealloc (vystore, (vcnt+1) * vdim * sizeof (double));
      memcpy ((void *) (vystore+(vcnt*vdim)), (void *) mxGetPr (vy[0]), vdim * sizeof (double));
      vcnt++; vret = true; break;

    case 2:
      vt[0] = mxCreateDoubleMatrix (vcnt, 1, mxREAL);
      memcpy ((void *) mxGetPr (vt[0]), (void *) vtstore, vcnt * sizeof (double));
      vy[0] = mxCreateDoubleMatrix (vdim, vcnt, mxREAL);
      memcpy ((void *) mxGetPr (vy[0]), (void *) vystore, vcnt * vdim * sizeof (double));
      vret = true; break;

    case 3:
      vtstore = (double *) mxRealloc (vtstore, (vcnt-1) * sizeof (double));
      vystore = (double *) mxRealloc (vystore, (vcnt-1) * vdim * sizeof (double));
      vcnt--; vret = true; break;

    case 4:
      mxFree (vtstore);
      mxFree (vystore);
      vret = true; break;

    default:
      break;
  }

  return (vret);
}

/**
 * fy2mxArray - Takes elements of a vector and returns a mxArray
 * @n: The number of elements in the vector @y
 * @y: A pointer to the first element of a vector
 * @vval: A pointer to the mxArray solution vector
 *
 * Takes elements out of a vector @y that has the size @n. The
 * elements that have to be taken are stored via the fodepkgvar()
 * function in the variable @OutputSelection (make sure calling
 * fodepkgvar(1, "OutputSel", @value) before calling this
 * fy2mxArray()).  The solution is stored in a newly allocated mxArray
 * and is returned as a pointer @val;
 *
 * Return value: On success the constant %true, otherwise %false.
 **/
bool fy2mxArray (unsigned int n, double *y, mxArray **vval) {
  int      vnum = 0;
  int      vcnt = 0;
  double  *vdbl = NULL;
  double  *vdob = NULL;
  mxArray *vtmp = NULL;

  fodepkgvar (2, "OutputSelection", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vnum = mxGetNumberOfElements (vtmp);
    vdob = mxGetPr (vtmp);    /* vdob eq. OutputSelection[0] */

    vval[0] = mxCreateDoubleMatrix (vnum, 1, mxREAL);
    vdbl = mxGetPr (vval[0]); /* vdbl eq. vval[0] */

    for (vcnt = 0; vcnt < vnum; vcnt++)
      vdbl[vcnt] = y[((int)(vdob[vcnt]))-1];
  }
  else {
    vval[0] = mxCreateDoubleMatrix (n, 1, mxREAL);
    memcpy ((void *) mxGetPr (vval[0]), (void *) y, n * sizeof (double));
  }

  return (true);
}

/**
 * fodepkgplot - Interface to the output function
 * @vtime: The time value mxArray
 * @vvalues: The solution vector mxArray
 * @vdeci: The decision for what has to be done
 *
 * Prepares the right-hand side variable before calling the odepkg
 * output function. @vdeci can either be "init", "" or "done
 * (cf. interpreter help text eg. odeprint(), odeplot), @vtime is the
 * actual timevalue and vvalues the solution vector. The output
 * function that has to be called from fodepkgplot() is set via the
 * command odeset() at interpreter side. Before calling this function
 * fodepkgvar(1, "varargin", value) and fodepkgvar(1, "PlotFunction",
 * value) have to be called to set the necessary name of the output
 * function and further arguments that have to be passed.
 *
 * Return value: %false if solving has to be stopped, otherwise %true.
 **/
bool fodepkgplot (mxArray *vtime, mxArray *vvalues, mxArray *vdeci) {
  bool vret = false;
  int  vcnt = 0;
  int  velm = 0;
  char vmsg[64] = "";

  mxArray  *vtmp = NULL;
  mxArray **vlhs = NULL;
  mxArray **vrhs = NULL;

  /* Get number of varargin elements for allocating memory */
  fodepkgvar (2, "varargin", &vtmp);
  velm = mxGetNumberOfElements (vtmp);
  vlhs = (mxArray **) mxMalloc (sizeof (mxArray *));
  vrhs = (mxArray **) mxMalloc ((3 + velm) * sizeof (mxArray *));

  /* Set the vrhs[0] element for the plotting function */
  vrhs[0] = vtime;

  /* Set the vrhs[1] element for the plotting function */
  vrhs[1] = vvalues;

  /* Set the vrhs[2] element for the plotting function */
  if (!mxIsEmpty (vdeci)) vrhs[2] = vdeci;
  else vrhs[2] = mxCreateString ("");

  /* Set the vrhs[3..] element for the plotting function */
  fodepkgvar (2, "varargin", &vtmp);
  if (velm > 0) /* Fill up vrhs[3..] */
    for (vcnt = 0; vcnt < velm; vcnt++)
      vrhs[3+vcnt] = mxGetCell (vtmp, vcnt);

  /* Call the plotting function */
  fodepkgvar (2, "PlotFunction", &vtmp);
  if ((strcmp (mxArrayToString (vdeci), "init") == 0) ||
      (strcmp (mxArrayToString (vdeci), "done") == 0)) {
    /* mexPrintf ("-----> INIT or DONE\n"); */
    if (mexCallMATLAB (0, NULL, 3+velm, vrhs, mxArrayToString (vtmp))) {
      sprintf (vmsg, "Calling \"%s\" has failed", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
    vret = true;
  }
  else {
    /* mexPrintf ("-----> CALC\n"); */
    if (mexCallMATLAB (1, vlhs, 3+velm, vrhs, mxArrayToString (vtmp))) {
      sprintf (vmsg, "Calling \"%s\" has failed", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
    if (mxIsLogicalScalarTrue (vlhs[0])) vret = true;
    else vret = false;
  }

  mxFree (vlhs); /* Free the vlhs mxArray */
  mxFree (vrhs); /* Free the vrhs mxArray */
  return (vret);
}

/**
 * fodepkgevent - Interface to the event function
 * @vtime: The time value mxArray
 * @vvalues: The solution vector mxArray
 * @vdeci: The decision for what has to be done
 * @vval: The event output values
 *
 * Prepares the right-hand side variable before calling the odepkg
 * event function. @vdeci can either be "init", "" or "done
 * (cf. interpreter help text eg. odeprint(), odeplot), @vtime is the
 * actual timevalue and vvalues the solution vector. The event
 * function that has to be called from fodepkgplot() is set via the
 * command odeset() at interpreter side. Before calling this function
 * fodepkgvar(1, "varargin", value) and fodepkgvar(1, "EventFunction",
 * value) have to be called to set the necessary name of the output
 * function and further arguments that have to be passed.
 *
 * Return value: %false if solving has to be stopped, otherwise %true.
 **/
bool fodepkgevent (mxArray *vtime, mxArray *vvalues, mxArray *vdeci, mxArray **vval) {
  const char *odepkg_event_handle = "odepkg_event_handle";

  bool vret = false;
  int  vcnt = 0;
  int  velm = 0;
  char vmsg[64] = "";

  mxArray  *vtmp = NULL;
  mxArray **vlhs = NULL;
  mxArray **vrhs = NULL;

  /* Get number of varargin elements for allocating memory */
  fodepkgvar (2, "varargin", &vtmp);
  velm = mxGetNumberOfElements (vtmp);
  vlhs = (mxArray **) mxMalloc (sizeof (mxArray *));
  vrhs = (mxArray **) mxMalloc ((4 + velm) * sizeof (mxArray *));

  /* Set the vrhs[0] element for the event function */
  fodepkgvar (2, "EventFunction", &vtmp);
  vrhs[0] = vtmp;

  /* Set the vrhs[1] element for the event function */
  vrhs[1] = vtime;

  /* Set the vrhs[2] element for the event function */
  vrhs[2] = vvalues;

  /* Set the vrhs[3] element for the event function */
  if (!mxIsEmpty (vdeci)) vrhs[3] = vdeci;
  else vrhs[3] = mxCreateString ("");

  /* Set the vrhs[4..] element for the event function */
  fodepkgvar (2, "varargin", &vtmp);
  if (velm > 0) /* Fill up vrhs[3..] */
    for (vcnt = 0; vcnt < velm; vcnt++)
      vrhs[4+vcnt] = mxGetCell (vtmp, vcnt);

  /* Call the event function */
  if ((strcmp (mxArrayToString (vdeci), "init") == 0) ||
      (strcmp (mxArrayToString (vdeci), "done") == 0)) {
    //mexPrintf ("---> BIN ICH DRINNN? %s %d %d\n", mxArrayToString (vdeci), !(-1), !(-2));
    if (mexCallMATLAB (0, NULL, 4+velm, vrhs, odepkg_event_handle)) {
      sprintf (vmsg, "Calling \"%s\" has failed", odepkg_event_handle);
      mexErrMsgTxt (vmsg);
    }
    vret = true;
  }
  else {
    //mexPrintf ("---> BIN WOANDERS? %s %d %d\n", mxArrayToString (vdeci), !(-1), !(-2));
    if (mexCallMATLAB (1, vlhs, 4+velm, vrhs, odepkg_event_handle)) {
      sprintf (vmsg, "Calling \"%s\" has failed", odepkg_event_handle);
      mexErrMsgTxt (vmsg);
    }
    for (vcnt = 0; vcnt < 3; vcnt++) vval[vcnt] = vlhs[vcnt];
    vret = true;
  }

  mxFree (vlhs); /* Free the vlhs mxArray */
  mxFree (vrhs); /* Free the vrhs mxArray */
  return (vret);
}

/*
Local Variables: ***
mode: C ***
End: ***
*/
