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

/* mkoctfile --mex -Wall -W -Wshadow -I./cprog odepkg_mexsolver_dop853.c cprog/dop853.c */
/* octave --eval "A = odeset (\"RelTol\", 1e-3, \"AbsTol\", [1e-4, 1e-5]), \
   [A, B] = odepkg_mexsolver_dop853 (@odepkg_equations_vanderpol, [0, 1], [2, 0], A)" */

/* #include "config.h" */
#include "mex.h"

#include <string.h> /* Needed for the memcpy function */
#include <stdio.h>
#include "dop853.h"
#include "odepkgext.h"

#define ODEPKGDEBUG 1

char format99[] = "x=%f  y=%12.10f %12.10f  nstep=%li\r\n";

typedef struct _ttolerance {
  double *reltols;
  size_t  reltoln;
  double *abstols;
  size_t  abstoln;
  int     toltype;
} _ttolerance;

typedef struct _todeoptions {
  mxArray *odeoptions;
  mxArray *defoptions;
} _todeoptions;

typedef struct _todefunction {
  mxArray  *funhandle;
  mxArray  *mexstring;
  char     *funstring;
  mxArray **funargs;
  mwSize    funargn;
} _todefunction;

typedef _ttolerance ttolerance;
typedef _todeoptions todeoptions;
typedef _todefunction todefunction;

//static    char  *vodefunction = NULL; /* The name of the function as mxArray string */
//static mxArray **vfunargs  = NULL; /* Further arguments for the ode function */
//static  mwSize   vfunargn  = 0;    /* The number of the further arguments */

static todefunction vodefunction = {NULL, NULL, NULL, NULL, 0};
static todefunction vplotfunction = {NULL, NULL, NULL, NULL, 0};

/* This is the proto */
void fodefunction (unsigned n, double x, double *y, double *f) {
  int  vcnt = 0;
  char vmsg[64] = "";
  mxArray **vlhs = NULL;
  mxArray **vrhs = NULL;

  vlhs = (mxArray **) mxMalloc (sizeof (mxArray *));
  vrhs = (mxArray **) mxCalloc (2 + vodefunction.funargn, sizeof (mxArray *));
  vrhs[0] = mxCreateDoubleScalar (x);
  vrhs[1] = mxCreateDoubleMatrix (1, n, mxREAL);
  memcpy ((void *) mxGetPr (vrhs[1]), (void *) y, n * sizeof (double));
  for (vcnt = 0; vcnt < vodefunction.funargn; vcnt++)
    vrhs[vcnt+2] = mxDuplicateArray (vodefunction.funargs[vcnt]);

  if (mexCallMATLAB (1, vlhs, 2, vrhs, vodefunction.funstring)) {
    sprintf (vmsg, "Calling '%s' has failed", vodefunction.funstring);
    mexErrMsgTxt (vmsg);
  }

  memcpy ((void *) f, (void *) mxGetPr (vlhs[0]), n * sizeof (double));

  mxFree (vlhs);
  mxFree (vrhs);
}

/* This function needs to be eliminated or changed */
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


void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) { 
  int vcnt = 0;
  int vodedimensions = 0;
  double *vtimeslot = NULL;
  double *vinitvalues = NULL;

  ttolerance  vtolerance = {NULL, 0, NULL, 0, 0}; /* Make sure that initialisation is correct */
  todeoptions vodeoptions = {NULL, NULL};         /* Make sure that initialisation is correct */

  // mxArray *vfunhandle  = NULL;
  // mxArray *vfunstring  = NULL;
  // mxArray *vodeoptions    = NULL;
  mxArray *vfieldvalue    = NULL; 

int res;
int iout;

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

    /* No option structure has been set as prhs[3] */
    if (!mxIsStruct (prhs[3])) {
      vodeoptions.odeoptions = NULL;
      vodefunction.funargn = nrhs - 3;
      vodefunction.funargs = (mxArray **) mxCalloc (vodefunction.funargn, sizeof (mxArray *));
      for (vcnt = 3; vcnt < nrhs; vcnt++)
        vodefunction.funargs[vcnt-3] = mxDuplicateArray (prhs[vcnt]);
      if (mexCallMATLAB (1, &vodeoptions.odeoptions, 0, NULL, "odeset")) 
        mexErrMsgTxt ("Calling 'odeset' has failed");
    }

    /* An option structure and further arguments have been set */
    else if (nrhs > 4) {
      vodeoptions.defoptions  = mxDuplicateArray (prhs[3]);
      vodefunction.funargn = nrhs - 4;
      vodefunction.funargs = (mxArray **) mxCalloc (vodefunction.funargn, sizeof (mxArray *));
      for (vcnt = 4; vcnt < nrhs; vcnt++)
        vodefunction.funargs[vcnt-4] = mxDuplicateArray (prhs[vcnt]);
      if (mexCallMATLAB (1, &vodeoptions.odeoptions, 1, &vodeoptions.defoptions, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling 'odepkg_structure_check' has failed");
    }

    /* Only an option-structure and no further arguments have been set */
    else {
      vodeoptions.defoptions = mxDuplicateArray (prhs[3]);
      if (mexCallMATLAB (1, &vodeoptions.odeoptions, 1, &vodeoptions.defoptions, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling 'odepkg_structure_check' has failed");
    }

  } /* No valid function call has been found before, 
       so we set the default options with odeset */
  else {
    mexCallMATLAB (1, &vodeoptions.odeoptions, 0, NULL, "odeset");
    vodefunction.funargs = NULL;
  }

  /* Nedd to get the default options that are set if odeset is called
     without further arguments. */
  if (mexCallMATLAB (1, &vodeoptions.defoptions, 0, NULL, "odeset"))
    mexErrMsgTxt ("Calling 'odeset' has failed");

  /* Handle the prhs[0] element: Create a string from the function
     handle and save the function handle and the string in the global
     (static) structure vodefunction. The structure vodefunction is
     used by the prototype function fodefunction. */
  vodefunction.funhandle = mxDuplicateArray (prhs[0]);
  if (mexCallMATLAB (1, &vodefunction.mexstring, 1, &vodefunction.funhandle, "func2str"))
    mexPrintf ("Calling 'func2str' has failed");
  vodefunction.funstring = mxArrayToString (vodefunction.mexstring);

  /* Handle the prhs[1] element: Extract the information about the
     interval that has to be solved. Fixed step sizes (as with
     ode23..ode78 can not be handled). Do this by copying the data
     from prhs[1] into the double array vtimeslot if valid. */
  if (mxGetM (prhs[1]) == 2 || mxGetN (prhs[1]) == 2) {
    vtimeslot = mxMalloc (2 * sizeof (double));
    memcpy ((void *) vtimeslot, (void *) mxGetPr (prhs[1]), 2 * sizeof (double));
  }
  else mexErrMsgTxt ("Second input argument must be of size 1x2 or 2x1 for this solver");
#ifdef ODEPKGDEBUG
  mexPrintf ("ODEPKGDEBUG: Solving is done from tStart=%f to tStop=%f\n", 
             vtimeslot[0], vtimeslot[1]);
#endif

  /* Handle the prhs[2] element: Extract the information about the
     initial values that have to be used. Do this by copying the data
     from prhs[2] into the double array vinitvalues. */
  if (mxIsRowVector (prhs[2])) vodedimensions = mxGetN (prhs[2]);
  else vodedimensions = mxGetM (prhs[2]);
  vinitvalues = mxMalloc (vodedimensions * sizeof (double));
  memcpy ((void *) vinitvalues, (void *) mxGetPr (prhs[2]), vodedimensions * sizeof (double));
#ifdef ODEPKGDEBUG
  mexPrintf ("ODEPKGDEBUG: Number of initial values is %d\n", vodedimensions);
  mexPrintf ("ODEPKGDEBUG: Last element of initial values is %f\n", vinitvalues[vodedimensions-1]);
#endif

  if (mexCallMATLAB (1, &vodeoptions.defoptions, 0, NULL, "odeset"))
    mexErrMsgTxt ("Calling 'odeset' has failed");

  /* Handle the odeoptions structure: Extract the information about
     the relative error tolerance and the absolute error tolerance
     from the mxArray options structure and set the type of the error
     calculation for the dopri solver. */
  vfieldvalue = mxGetField (vodeoptions.odeoptions, 0, "RelTol");
  if (mxIsRowVector (vfieldvalue)) vtolerance.reltoln = mxGetN (vfieldvalue);
  else vtolerance.reltoln = mxGetM (vfieldvalue); /* if mxIsColumnVector */
  vtolerance.reltols = mxMalloc (vtolerance.reltoln * sizeof (double));
  memcpy ((void *) vtolerance.reltols, (void *) mxGetPr (vfieldvalue), vtolerance.reltoln * sizeof (double));

  vfieldvalue = mxGetField (vodeoptions.odeoptions, 0, "AbsTol");
  if (mxIsRowVector (vfieldvalue)) vtolerance.abstoln = mxGetN (vfieldvalue);
  else vtolerance.abstoln = mxGetM (vfieldvalue);
  vtolerance.abstols = mxMalloc (vtolerance.abstoln * sizeof (double));
  memcpy ((void *) vtolerance.abstols, (void *) mxGetPr (vfieldvalue), vtolerance.abstoln * sizeof (double));
#ifdef ODEPKGDEBUG
  mexPrintf ("ODEPKGDEBUG: Number of relative tolerances is %d\n", vtolerance.reltoln);
  mexPrintf ("ODEPKGDEBUG: Last element of relative error is %f\n", vtolerance.reltols[vtolerance.reltoln-1]);
  mexPrintf ("ODEPKGDEBUG: Number of absolute tolerances is %d\n", vtolerance.abstoln);
  mexPrintf ("ODEPKGDEBUG: Last element of absolute error is %f\n", vtolerance.abstols[vtolerance.abstoln-1]);
#endif
 
  if (vtolerance.reltoln != vtolerance.abstoln)
    mexErrMsgTxt ("Values of 'AbsTol' and 'RelTol' must have same size");
  else {
    if (vtolerance.abstoln > 1) vtolerance.toltype = 1;
    else vtolerance.toltype = 0;
  }
#ifdef ODEPKGDEBUG
   mexPrintf ("ODEPKGDEBUG: Type of tolerance handling is %d\n", vtolerance.toltype);
#endif

  /* Handle the odeoptions structure: Extract the information about
     the output function (if any) from the mxArray options structure
     and set the type of the switch for the output function.  */
  vplotfunction.funhandle = mxGetField (vodeoptions.odeoptions, 0, "OutputFcn");
  if (mxIsEmpty (vplotfunction.funhandle) && (nlhs == 0)) {
  }
  if (mexCallMATLAB (1, &vplotfunction.mexstring, 1, &vplotfunction.funhandle, "func2str"))
    mexPrintf ("Calling 'func2str' has failed");
  vplotfunction.funstring = mxArrayToString (vplotfunction.mexstring);
    
/* typedef struct _todefunction { */
/*   mxArray  *funhandle; */
/*   mxArray  *mexstring; */
/*   char     *funstring; */
/*   mxArray **funargs; */
/*   mwSize    funargn; */
/* } _todefunction; */


  iout = 2;
  
  res = dop853 (vodedimensions, fodefunction, vtimeslot[0], vinitvalues, vtimeslot[1], 
                vtolerance.reltols, vtolerance.abstols, vtolerance.toltype, 
                solout, iout,
                stdout, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 1, 2, NULL, 0);

  // plhs[0] = vabstolerance;
  //    plhs[1] = vreltolerance;
/*   plhs[1] = vfunargs[1]; */
/*   plhs[2] = vfunargs[2]; */
/* mxFree (vtolerance.reltols); */
/*  mxFree (vfunargs); */
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
