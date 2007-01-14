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

/* mkoctfile --mex -Wall -W -Wshadow -DHAVE_CONFIG_H -D__ODEPKGDEBUG__ -I./cprog\
   odepkg_mexsolver_dopri5.c odepkgext.c cprog/dopri5.o
*/
/* octave --eval "A = odeset (\"RelTol\", 1e-3, \"AbsTol\", 1e-4, \"OutputFcn\", \
   @odeprint, \"OutputSel\", [2, 1], \"Refine\", 3); \
   [A, B] = odepkg_mexsolver_dopri5 (@odepkg_equations_vanderpol, [0, 1], [2, 0], A, 12)"
*/

#ifdef HAVE_CONFIG_H
  #include "config.h"  /* Needed for GCC_ATTR_UNUSED */
#endif
#include "mex.h"       /* Needed for the mex-definitions */
#include <string.h>    /* Needed for the "memcpy" and "strcmp" functions */
#include <stdio.h>     /* Should be removed */
#include "dopri5.h"    /* Needed for the solver function "dopri5" */
#include "odepkgmex.h" /* Needed for the mxIsVector, mxIsColumnVector etc. functions */
#include "odepkgext.h" /* Needed for the fplotfunction, etc. */

/* There is no other way to put values into the functions that are
   needed by the dopri solvers. Therefore we put them via global
   variables into the functiions. Make sure that the initialisation of
   the following global variables is correct. */;
todefunction vodefunction  = {NULL, NULL, NULL, NULL, 0};
todefunction vplotfunction = {NULL, NULL, NULL, NULL, 0};
todeoptions  vodeoptions   = {NULL, NULL};

void fodefunction (unsigned n, double x, double *y, double *f) {
  int  vcnt = 0;
  char vmsg[64] = "";
  mxArray **vlhs = NULL;
  mxArray **vrhs = NULL;

  vlhs = (mxArray **) mxMalloc (sizeof (mxArray *));
  vrhs = (mxArray **) mxMalloc ((2 + vodefunction.funargn) * sizeof (mxArray *));
  vrhs[0] = mxCreateDoubleScalar (x);
  vrhs[1] = mxCreateDoubleMatrix (1, n, mxREAL);

  /* Copy the values that are given from the solver into the mxArray */
  memcpy ((void *) mxGetPr (vrhs[1]), (void *) y, n * sizeof (double));
  if (vodefunction.funargn > 0) /* Fill up vrhs[2..] */
    for (vcnt = 0; vcnt < vodefunction.funargn; vcnt++)
      vrhs[vcnt+2] = vodefunction.funargs[vcnt];

  /* Evaluate the ode function in the octave caller workspace */
  if (mexCallMATLAB (1, vlhs, vodefunction.funargn+2, vrhs, vodefunction.funstring)) {
    sprintf (vmsg, "Calling \"%s\" has failed", vodefunction.funstring);
    mexErrMsgTxt (vmsg);
  }

  /* Save the result of this time step in the variable f */
  memcpy ((void *) f, (void *) mxGetPr (vlhs[0]), n * sizeof (double));
  mxFree (vlhs); /* Free the vlhs mxArray */
  mxFree (vrhs); /* Free the vrhs mxArray */
}

void fodesolution (GCC_ATTR_UNUSED long nr, GCC_ATTR_UNUSED double xold, 
                   double x, double* y, unsigned n, int* irtrn) {

  bool vret = false;

  mxArray *vtime   = NULL;
  mxArray *vvalues = NULL;
  mxArray *vflag   = NULL;

  vtime   = mxCreateDoubleScalar (x);
  vvalues = mxCreateDoubleMatrix (1, n, mxREAL);
  memcpy ((void *) mxGetPr (vvalues), (void *) y, n * sizeof (double));
  vflag = mxCreateString (""); /* Do calculation ... */
  vret = fplotfunction (vtime, vvalues, vflag, vodeoptions.odeoptions);

  irtrn[0] = (int) (vret - 1); /* Stop integration on negative value */

/* #ifdef __ODEPKGDEBUG__ */
/*   if (nr == 1) */
/*     mexPrintf ("ODEPKGDEBUG: n=%d step=%02d  told=%7.5f  time=%7.5f  y[1]=%7.5f  y[2]=%7.5f\n", */
/*                n, nr, xold, x, y[0], y[1]); */
/*   else  */
/*     mexPrintf ("ODEPKGDEBUG: n=%d step=%02d  told=%7.5f  time=%7.5f  y[1]=%7.5f  y[2]=%7.5f\n", */
/*                n, nr, xold, x, contd5(0,x), contd5(1,x)); */
/* #endif */

}

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) { 
  int vcnt = 0;
  int vodedimensions = 0;

  double *vtimeslot = NULL;
  double *vinitvalues = NULL;
  double vinitstep = 0.0;
  double vmaximumstep = 0.0;

  ttolerance vtolerance = {NULL, 0, NULL, 0, 0}; /* Make sure that initialisation is correct */

  mxArray *vfieldvalue = NULL; /* This is a temporary mxArray */
  mxArray *vtemporary  = NULL; /* This is a temporary mxArray */

int res;
int iout;

  if (nrhs == 0) { /* Check number and types of all input arguments */
    mexFixMsgTxt ("Do something like this as in octave: help (\"ode23\");");
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

    if (!mxIsStruct (prhs[3])) { /* No option structure has been set in prhs[3] */
      vodefunction.funargn = nrhs - 3;
      vodefunction.funargs = (mxArray **) mxCalloc (vodefunction.funargn, sizeof (mxArray *));
      for (vcnt = 3; vcnt < nrhs; vcnt++)
        vodefunction.funargs[vcnt-3] = mxDuplicateArray (prhs[vcnt]);

      if (mexCallMATLAB (1, &vodeoptions.odeoptions, 0, NULL, "odeset")) 
        mexErrMsgTxt ("Calling \"odeset\" has failed");
    }

    else if (nrhs > 4) { /* An option structure and further arguments have been set */
      vodefunction.funargn = nrhs - 4;
      vodefunction.funargs = (mxArray **) mxCalloc (vodefunction.funargn, sizeof (mxArray *));
      for (vcnt = 4; vcnt < nrhs; vcnt++)
        vodefunction.funargs[vcnt-4] = mxDuplicateArray (prhs[vcnt]);

      vodeoptions.defoptions = mxDuplicateArray (prhs[3]);
      if (mexCallMATLAB (1, &vodeoptions.odeoptions, 1, &vodeoptions.defoptions, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling \"odepkg_structure_check\" has failed");
    }

    else { /* Only an option-structure and no further arguments have been set */
      vodefunction.funargn = 0;
      vodefunction.funargs = NULL;

      vodeoptions.defoptions = mxDuplicateArray (prhs[3]);
      if (mexCallMATLAB (1, &vodeoptions.odeoptions, 1, &vodeoptions.defoptions, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling \"odepkg_structure_check\" has failed");
    }

  } /* No valid function call has been found before - set the defaults */
  else {
    mexCallMATLAB (1, &vodeoptions.odeoptions, 0, NULL, "odeset");
    vodefunction.funargn = 0;
    vodefunction.funargs = NULL;
  }
  /* Get the default options (Calling 'odeset' without arguments) */
  if (mexCallMATLAB (1, &vodeoptions.defoptions, 0, NULL, "odeset"))
    mexErrMsgTxt ("Calling \"odeset\" has failed");



  /* Handle the prhs[0] element: The ode function that has to be solved */
  vodefunction.funhandle = mxDuplicateArray (prhs[0]);
  if (mexCallMATLAB (1, &vodefunction.mexstring, 1, &vodefunction.funhandle, "func2str"))
    mexErrMsgTxt ("Calling \"func2str\" has failed");
  vodefunction.funstring = mxArrayToString (vodefunction.mexstring);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The function that has to be solved is \"%s\"\n", 
             vodefunction.funstring);
#endif

  /* Handle the prhs[1] element: Split the integration interval */
  if (mxGetM (prhs[1]) == 2 || mxGetN (prhs[1]) == 2) {
    vtimeslot = mxMalloc (2 * sizeof (double));
    memcpy ((void *) vtimeslot, (void *) mxGetPr (prhs[1]), 2 * sizeof (double));
  }
  else mexErrMsgTxt ("Second input argument must be of size 1x2 or 2x1 for this solver");
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Solving is done from tStart=%f to tStop=%f\n", 
             vtimeslot[0], vtimeslot[1]);
#endif

  /* Handle the prhs[2] element: Set the initial values */
  if (mxIsRowVector (prhs[2])) vodedimensions = mxGetN (prhs[2]);
  else vodedimensions = mxGetM (prhs[2]);
  vinitvalues = mxMalloc (vodedimensions * sizeof (double));
  memcpy ((void *) vinitvalues, (void *) mxGetPr (prhs[2]), vodedimensions * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Number of initial values is %d\n", vodedimensions);
  mexPrintf ("ODEPKGDEBUG: Last element of initial values is %f\n", vinitvalues[vodedimensions-1]);
#endif



  /* Handle the odeoptions structure field: RELTOL, ABSTOL */
  vfieldvalue = mxGetField (vodeoptions.odeoptions, 0, "RelTol");
  if (mxIsRowVector (vfieldvalue)) vtolerance.reltoln = mxGetN (vfieldvalue);
  else vtolerance.reltoln = mxGetM (vfieldvalue); /* if mxIsColumnVector */
  vtolerance.reltols = mxMalloc (vtolerance.reltoln * sizeof (double));
  memcpy ((void *) vtolerance.reltols, (void *) mxGetPr (vfieldvalue), vtolerance.reltoln * sizeof (double));

  vfieldvalue = mxGetField (vodeoptions.odeoptions, 0, "AbsTol");
  if (mxIsRowVector (vfieldvalue)) vtolerance.abstoln = mxGetN (vfieldvalue);
  else vtolerance.abstoln = mxGetM (vfieldvalue); /* if mxIsColumnVector */
  vtolerance.abstols = mxMalloc (vtolerance.abstoln * sizeof (double));
  memcpy ((void *) vtolerance.abstols, (void *) mxGetPr (vfieldvalue), vtolerance.abstoln * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Number of relative tolerances is %d\n", vtolerance.reltoln);
  mexPrintf ("ODEPKGDEBUG: Last element of relative error is %f\n", vtolerance.reltols[vtolerance.reltoln-1]);
  mexPrintf ("ODEPKGDEBUG: Number of absolute tolerances is %d\n", vtolerance.abstoln);
  mexPrintf ("ODEPKGDEBUG: Last element of absolute error is %f\n", vtolerance.abstols[vtolerance.abstoln-1]);
#endif
 
  if (vtolerance.reltoln != vtolerance.abstoln)
    mexErrMsgTxt ("Values of \"AbsTol\" and \"RelTol\" must have same size");
  else {
    if (vtolerance.abstoln > 1) vtolerance.toltype = 1;
    else vtolerance.toltype = 0;
  }
#ifdef __ODEPKGDEBUG__
   mexPrintf ("ODEPKGDEBUG: Type of dopri tolerance handling is %d\n", vtolerance.toltype);
#endif

  /* Handle the odeoptions structure field: NORMCONTROL */
  if (!mxIsEqual (mxGetField (vodeoptions.odeoptions, 0, "NormControl"),
                  mxGetField (vodeoptions.defoptions, 0, "NormControl") ) )
    mexWarnMsgTxt ("Option \"NormControl\" will be ignored by this solver");

  /* Handle the odeoptions structure field: OUTPUTFCN  */
  vplotfunction.funhandle = mxGetField (vodeoptions.odeoptions, 0, "OutputFcn");
  vplotfunction.mexstring = NULL; /* Make sure that this pointer is NULL */
  vplotfunction.funstring = NULL; /* Make sure that this pointer is NULL */
  if (mxIsEmpty (vplotfunction.funhandle) && (nlhs == 0)) {
    vplotfunction.mexstring = mxCreateString ("odeplot");
    vplotfunction.funstring = mxArrayToString (vplotfunction.mexstring);
    if (mexCallMATLAB (1, &vplotfunction.funhandle, 1, &vplotfunction.mexstring, "str2func"))
      mexErrMsgTxt ("Calling \"str2func\" has failed");
  } /* else if mxIsEmpty (vplotfunction.funhandle) there is no output function */

  else {
    if (!mxIsEmpty (vplotfunction.funhandle)) {
      if (mexCallMATLAB (1, &vplotfunction.mexstring, 1, &vplotfunction.funhandle, "func2str"))
        mexErrMsgTxt ("Calling \"func2str\" has failed");
      vplotfunction.funstring = mxArrayToString (vplotfunction.mexstring);
    }
  }
#ifdef __ODEPKGDEBUG__
  if (vplotfunction.funstring) mexPrintf ("ODEPKGDEBUG: The output function was set to \"%s\"\n", 
    vplotfunction.funstring); /* An output function is set if !mxIsEmpty(funhandle) */
  else mexPrintf ("ODEPKGDEBUG: No output function has been set.\n");
#endif

  /* Handle the odeoptions structure field: OUTPUTSEL. Implementation
     of the option OUTPUTSEL has been finished. The output selection
     itself is handled in the output function "fplotfunction" */

  /* Handle the odeoptions structure field: REFINE */
  vfieldvalue = mxGetField (vodeoptions.odeoptions, 0, "Refine");
  vtemporary  = mxGetField (vodeoptions.defoptions, 0, "Refine");
  if (*mxGetPr (vfieldvalue) != *mxGetPr (vtemporary))
    mexWarnMsgTxt ("Not yet implemented option \"Refine\" will be ignored");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Refine option has not been set\n");
#endif

  /* Handle the odeoptions structure field: STATS */
  if (!mxIsEqual (mxGetField (vodeoptions.odeoptions, 0, "Stats"), 
                  mxGetField (vodeoptions.defoptions, 0, "Stats") ) )
    mexWarnMsgTxt ("Not yet implemented option \"Stats\" will be ignored");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Stats option has not been set\n");
#endif

  /* Handle the odeoptions structure field: INITIALSTEP */
  if (!mxIsEqual (mxGetField (vodeoptions.odeoptions, 0, "InitialStep"), 
                  mxGetField (vodeoptions.defoptions, 0, "InitialStep") ) )
    vinitstep = *mxGetPr (mxGetField (vodeoptions.odeoptions, 0, "InitialStep") );
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The inital step size is %f\n", vinitstep);
#endif

  /* Handle the odeoptions structure field: MAXSTEP */
  if (!mxIsEqual (mxGetField (vodeoptions.odeoptions, 0, "MaxStep"), 
                  mxGetField (vodeoptions.defoptions, 0, "MaxStep") ) )
    vmaximumstep = *mxGetPr (mxGetField (vodeoptions.odeoptions, 0, "MaxStep") );
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The maximum step size is %f\n", vmaximumstep);
#endif


  /* Handle the odeoptions structure field: EVENT */
  mexFixMsgTxt ("No implementation for Event by now");
  /* No implementation for Jacobian by now */
  mexFixMsgTxt ("No implementation for Jacobian by now");
  /* No implementation for JPattern by now */
  mexFixMsgTxt ("No implementation for JPattern by now");
  /* No implementation for Vectorized by now */
  mexFixMsgTxt ("No implementation for Vectorized by now");
  /* No implementation for Mass by now */
  mexFixMsgTxt ("No implementation for Mass by now");
  /* No implementation for MStateDep by now */
  mexFixMsgTxt ("No implementation for MStateDep by now");
  /* No implementation for MvPattern by now */
  mexFixMsgTxt ("No implementation for MvPattern by now");
  /* No implementation for MassSingular by now */
  mexFixMsgTxt ("No implementation for MassSingular by now");
  /* No implementation for InitialSlope by now */
  mexFixMsgTxt ("No implementation for InitialSlope by now");
  /* No implementation for MaxOrder by now */
  mexFixMsgTxt ("No implementation for MaxOrder by now");
  /* No implementation for BDF by now */
  mexFixMsgTxt ("No implementation for BDF by now");

  iout = 2;

  /*TODO REPLACE MXDUPLICTEARRAY */
  fplotfunction (mxDuplicateArray (prhs[1]), /*TODO*/
                 mxDuplicateArray (prhs[2]),
                 mxCreateString ("init"),
                 vodeoptions.odeoptions);

  /* Call the solver with all input arguments that can be used, here
     are some comments about this implementation: */
  res = dopri5 (vodedimensions, fodefunction, vtimeslot[0], vinitvalues, 
                vtimeslot[1], vtolerance.reltols, vtolerance.abstols, 
                vtolerance.toltype, fodesolution, iout,
                stdout, 0.0, 0.0, 0.0, 0.0, 0.0, vmaximumstep, vinitstep, 
                0, 0, 1, vodedimensions, NULL, vodedimensions);

  /*TODO REPLACE MXDUPLICTEARRAY */
  fplotfunction (mxDuplicateArray (prhs[1]), /*TODO*/
                 mxDuplicateArray (prhs[2]),
                 mxCreateString ("done"),
                 vodeoptions.odeoptions);

/*   plhs[0] = vplotfunction.funargs[0]; */
/*   plhs[1] = vplotfunction.funargs[1]; */
/*   plhs[2] = vplotfunction.funargs[2]; */
/*   plhs[3] = vplotfunction.funargs[3]; */

/*   mxFree (vtolerance.reltols); */
/*   mxFree (vfunargs); */

}

/*
Local Variables: ***
mode: C ***
End: ***
*/
