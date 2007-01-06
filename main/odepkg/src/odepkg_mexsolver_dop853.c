/*
Copyright (C) 2006, Thomas Treichl <treichl@users.sourceforge.net>
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

/* mkoctfile --mex -Wall -W -Wshadow -I./cprog odepkg_mexsolver_dopri5.c cprog/dopri5.c */

#include "config.h"
#include "mex.h"

#include <string.h> /* Needed for the memcpy function */
#include <stdio.h>
#include "dop853.h"

#ifndef mwSize
#define mwSize int
#endif

#ifndef mwSize
#define mwSize int
#endif

#ifndef true
#define true 1
#endif

#ifndef false
#define false 0
#endif

char format99[] = "x=%f  y=%12.10f %12.10f  nstep=%li\r\n";

char            *vodefunction  = NULL; /* The name of the function as mxArray string */
static mxArray **vodefunargs   = NULL; /* Further arguments for the ode-function */
static mwSize    vodefunargn   = 0;    /* The number of the further arguments */

/* This is the proto */
void fodefun (unsigned n, double x, double *y, double *f) {
  uint      vcnt = 0;
  mxArray **vlhs = NULL;
  mxArray **vrhs = NULL;

  vlhs = (mxArray **) mxMalloc (sizeof (mxArray *));
  vrhs = (mxArray **) mxCalloc (2 + vodefunargn, sizeof (mxArray *));
  vrhs[0] = mxCreateDoubleScalar (x);
  vrhs[1] = mxCreateDoubleMatrix (1, n, mxREAL);

  memcpy ((void *) mxGetPr (vrhs[1]), (void *) y, n * sizeof (double));
  for (vcnt = 0; vcnt < vodefunargn; vcnt++)
    vrhs[vcnt+2] = mxDuplicateArray (vodefunargs[vcnt]);

  if (mexCallMATLAB (1, vlhs, 2, vrhs, vodefunction))
    mexPrintf("calling '%s' has failed", vodefunction);

  memcpy ((void *) f, (void *) mxGetPr (vlhs[0]), n * sizeof (double));

  mxFree (vlhs);
  mxFree (vrhs);
}


void solout (long nr, double xold, double x, double* y, unsigned n, int* irtrn)
{
  static double xout; 

  if (nr == 1)
  { 
    printf ( "x=%f  y=%12.10f %12.10f  nstep=%li\r\n", x, y[0], y[1], nr-1);
    xout = x + 0.1;
  }
  else 
    while (x >= xout)
    {
      printf (format99, xout, contd8(0,xout), contd8(1,xout), nr-1);
      xout += 0.1;
    }
    
} /* solout */

void mexUsgMsgTxt (const char *vusg) {
  mexPrintf ("usage: %s\n", vusg);
  mexErrMsgTxt ("");
}

void mexFixMsgTxt (const char *vfix) {
  mexPrintf ("FIXME: %s\n", vfix);
}

bool mxIsVector (const mxArray *vinp) {
  if (mxIsNumeric (vinp)) {
    if ( (mxGetM (vinp) == 1 && mxGetN (vinp) > 1) ||
         (mxGetN (vinp) == 1 && mxGetM (vinp) > 1) )
      /* mexPrintf ("Yes it is a vector!"); */
      return (true);
  }
  return (false);
}

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) { 
  mxArray *vodefunhandle = NULL;
  mxArray *vodefunstring = NULL;
  mxArray *vodeoptions   = NULL;
  int      vcnt = 0;

  if (nrhs == 0) { /* Check number and types of all input arguments */
    mexFixMsgTxt ("Do something like this as in octave: help ('ode23');");
    mexErrMsgTxt ("Number of input arguments must be greater than zero");
  }
  else if (nrhs < 3) { /* Check if number of input arguments >= 3 */
    mexUsgMsgTxt ("[t, y] = odetmpl (fun, slot, init, varargin)");
  }
  else if (mxGetClassID (prhs[0]) != mxFUNCTION_CLASS) {
    mexErrMsgTxt ("First input argument must be valid function handle");
  }
  else if (!mxIsVector (prhs[1]) && (mxGetNumberOfElements (prhs[1]) < 2)) { /* vslot */
    mexErrMsgTxt ("Second input argument must be a valid vector");
  }
  else if (!mxIsVector (prhs[2]) || !mxIsNumeric (prhs[2])) { /* vinit */
    mexErrMsgTxt ("Third input argument must be a valid vector"); 
  }
  else if (nrhs >= 4) {
    /* No option structure has been set */
    if (!mxIsStruct (prhs[3])) {
      vodeoptions = NULL; vodefunargn = nrhs-3;
      vodefunargs = (mxArray **) mxCalloc (vodefunargn, sizeof (mxArray *));
      for (vcnt = 3; vcnt < nrhs; vcnt++)
        vodefunargs[vcnt-3] = mxDuplicateArray (prhs[vcnt]);
      if (mexCallMATLAB (1, &vodeoptions, 0, NULL, "odeset")) 
        mexErrMsgTxt ("Calling 'odeset' has failed");
    }
    /* An option structure and further arguments have been set */
    else if (nrhs > 4) {
      vodeoptions = mxDuplicateArray (prhs[3]); vodefunargn = nrhs-4;
      vodefunargs = (mxArray **) mxCalloc (vodefunargn, sizeof (mxArray *));
      for (vcnt = 4; vcnt < nrhs; vcnt++)
        vodefunargs[vcnt-4] = mxDuplicateArray (prhs[vcnt]);
      if (mexCallMATLAB (1, &vodeoptions, 1, &vodeoptions, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling 'odepkg_structure_check' has failed");
    }
    /* Only an option-structure and no further arguments have been set */
    else {
      vodeoptions = mxDuplicateArray (prhs[3]);
      mexCallMATLAB (1, &vodeoptions, 1, &vodeoptions, "odepkg_structure_check");
    }
  }
  /* No valid function call has been found before, 
     so we set the default options with odeset */
  else {
    mexCallMATLAB (1, &vodeoptions, 0, NULL, "odeset");
    vodefunargs = NULL;
  }

  /* Create a string from the function handle and save the string in the static
     variable vodefunction. */
  vodefunhandle = mxDuplicateArray (prhs[0]);
  mexCallMATLAB (1, &vodefunstring , 1, &vodefunhandle, "func2str");
  vodefunction = mxArrayToString (vodefunstring);

  double   y[2];
  int      res, iout, itoler;
  double   x, xend, atoler, rtoler;

  iout = 2;
  x = 0.0;
  y[0] = 2.0;
  y[1] = 0.0;
  xend = 1.0;
  itoler = 0;
  rtoler = 1.0E-6;
  atoler = rtoler;
  
  res = dop853 (2, fodefun, x, y, xend, &rtoler, &atoler, itoler, solout, iout,
		stdout, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1, 2, NULL, 0);

/*   plhs[0] = vodefunargs[0]; */
/*   plhs[1] = vodefunargs[1]; */
/*   plhs[2] = vodefunargs[2]; */

  mxFree (vodefunargs);
}


/*
%!test
%! disp("YES");
*/

/*
Local Variables: ***
mode: C ***
End: ***
*/
