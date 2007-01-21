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
   odepkg_mexsolver_dopri5.c odepkgmex.c odepkgext.c cprog/dopri5.o
*/
/* octave --eval "A = odeset (\"RelTol\", 1e-3, \"AbsTol\", 1e-4, \"OutputFcn\", \
   @odeprint, \"OutputSel\", [2, 1], \"Refine\", 3); \
   [C, B] = odepkg_mexsolver_dopri5 (@odepkg_equations_vanderpol, [0, 1], [2, 0], A, 12)"
*/

/* mex -v -D__ODEPKGDEBUG__ -I./cprog odepkg_mexsolver_dopri5.c odepkgext.c odepkgmex.c cprog/dopri5.c
   odepkg_mexsolver_dopri5 (@odepkg_equations_vanderpol, [0,2], [2,0])
*/

#ifdef HAVE_CONFIG_H
  #include "config.h"  /* Needed for GCC_ATTR_UNUSED if compiled with mkoctfile */
#endif

#include <mex.h>       /* Needed for all mex definitions */
#include <string.h>    /* Needed for the memcpy function etc.*/
#include "odepkgmex.h" /* Needed for the mex extensions */
#include "odepkgext.h" /* Needed for the odepkg extensions */
#include "dopri5.h"    /* Needed for the solver function */

/* These are the prototypes from this file */
void fodefun (unsigned n, double x, double *y, double *f);
void fsolout (long nr, double xold, double x, double* y, unsigned n, int* irtrn);
void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]);

void fodefun (unsigned n, double x, double *y, double *f) {
  int  vcnt = 0;
  int  vnum = 0;
  char vmsg[64] = "";

  mxArray  *vtmp = NULL;
  mxArray **vlhs = NULL;
  mxArray **vrhs = NULL;

  /* Get number of varargin elements for allocating memory */
  fodepkgvar (2, "varargin", &vtmp);
  vnum = mxGetNumberOfElements (vtmp);

  /* Allocate memory and set up variables lhs-arguments and rhs-arguments */
  vlhs = (mxArray **) mxMalloc (sizeof (mxArray *));
  vrhs = (mxArray **) mxMalloc ((2 + vnum) * sizeof (mxArray *));
  vrhs[0] = mxCreateDoubleScalar (x);

  /* Copy the values that are given from the solver into the mxArray */
  vrhs[1] = mxCreateDoubleMatrix (n, 1, mxREAL);
  memcpy ((void *) mxGetPr (vrhs[1]), (void *) y, n * sizeof (double));

  if (vnum > 0) /* Fill up vrhs[2..] */
    for (vcnt = 0; vcnt < vnum; vcnt++)
      vrhs[vcnt+2] = mxGetCell (vtmp, vcnt);

  /* Evaluate the ode function in the octave caller workspace */
  fodepkgvar (2, "odefun", &vtmp);
  if (mexCallMATLAB (1, vlhs, vnum+2, vrhs, mxArrayToString (vtmp))) {
    sprintf (vmsg, "Calling \"%s\" has failed", mxArrayToString (vtmp));
    mexErrMsgTxt (vmsg);
  }

  /* Save the result of this time step in the variable f */
  memcpy ((void *) f, (void *) mxGetPr (vlhs[0]), n * sizeof (double));
  mxFree (vlhs); /* Free the vlhs mxArray */
  mxFree (vrhs); /* Free the vrhs mxArray */
}

void fsolout (long nr, double xold, double x, double* y, unsigned n, int* irtrn) {
  bool     vsuc = false;
  mxArray *vtmp = NULL;
  mxArray *vtem = NULL;
  mxArray *vtim = NULL;

  /* Convert the double *y into a selection of variables */
  fy2mxArray (n, y, &vtem);
  vtim = mxCreateDoubleScalar (x);
  if (nr > 1) fsolstore (1, &vtim, &vtem);

  /* Call plotting function if this is not the initial first call */
  fodepkgvar (2, "plotfun", &vtmp);
  if (!mxIsEmpty (vtmp) && nr > 1) {
    vsuc = fodepkgplot (vtim, vtem, mxCreateString (""));
    irtrn[0] = ((int) vsuc) - 1;
  }

  /* #ifdef __ODEPKGDEBUG__ */
  /*   mexPrintf ("%ld  %f  %f  %f  %f  %d  %d\n",  */
  /*     nr, xold, x, y[0], y[1], n, irtrn[0]); */
  /* #endif */
}

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) { 
  int vcnt = 0;
  int vnum = 0;
  int vone = 1;

  double  *vdbl = NULL;
  char     vmsg[64] = "";

  mxArray *vtmp = NULL;
  mxArray *vtem = NULL;

  int      vodedimen = 0;
  double  *vtimeslot = NULL;
  double  *vinitvals = NULL;

  int      vtoltype  = 0;
  double  *vtolrelat = NULL;
  double  *vtolabsol = NULL;

  double   vinitstep = 0.0;
  double   vmaxstep  = 0.0;

#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER INITIALISATION PROCEDURE\n");
#endif
  fodepkgvar (0, NULL, NULL);

  if (nrhs == 0) { /* Check number and types of all input arguments */
    vtmp = mxCreateString ("ode5d");
    if (mexCallMATLAB (0, NULL, 1, &vtmp, "help"))
      mexErrMsgTxt ("Calling \"help\" has failed");
    mexErrMsgTxt ("Number of input arguments must be greater than zero");
  }
  else if (nrhs < 3) { /* Check if number of input arguments >= 3 */
    mexUsgMsgTxt ("[t, y] = odepkg_mexsolver_dopri5 (fun, slot, init, varargin)");
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
      vnum = nrhs - 3; vtmp = mxCreateCellArray (1, &vnum);
      for (vcnt = 3; vcnt < nrhs; vcnt++)
        mxSetCell (vtmp, vcnt-3, mxDuplicateArray (prhs[vcnt]));
      fodepkgvar (1, "varargin", &vtmp);
      if (mexCallMATLAB (1, &vtmp, 0, NULL, "odeset"))
        mexErrMsgTxt ("Calling \"odeset\" has failed");
      fodepkgvar (1, "odeoptions", &vtmp);
    }

    else if (nrhs > 4) { /* An option structure and further arguments have been set */
      vnum = nrhs - 4; vtmp = mxCreateCellArray (1, &vnum);
      for (vcnt = 4; vcnt < nrhs; vcnt++)
        mxSetCell (vtmp, vcnt-4, mxDuplicateArray (prhs[vcnt]));
      fodepkgvar (1, "varargin", &vtmp);
      vtem = mxDuplicateArray (prhs[3]);
      if (mexCallMATLAB (1, &vtmp, 1, &vtem, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling \"odepkg_structure_check\" has failed");
      fodepkgvar (1, "odeoptions", &vtmp);
    }

    else { /* Only an option-structure and no further arguments have been set */
      vnum = 0; vtmp = mxCreateCellArray (1, &vnum);
      fodepkgvar (1, "varargin", &vtmp);
      vtem = mxDuplicateArray (prhs[3]);
      if (mexCallMATLAB (1, &vtmp, 1, &vtem, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling \"odepkg_structure_check\" has failed");
      fodepkgvar (1, "odeoptions", &vtmp);
    }

  } /* No valid function call has been found before - set the defaults */
  else {
      vnum = 0; vtmp = mxCreateCellArray (1, &vnum);
      fodepkgvar (1, "varargin", &vtmp);
      if (mexCallMATLAB (1, &vtmp, 0, NULL, "odeset"))
        mexErrMsgTxt ("Calling \"odeset\" has failed");
      fodepkgvar (1, "odeoptions", &vtmp);
  }

  /* Get the default options (Calling 'odeset' without arguments) */
  if (mexCallMATLAB (1, &vtmp, 0, NULL, "odeset"))
    mexErrMsgTxt ("Calling \"odeset\" has failed");
  fodepkgvar (1, "defoptions", &vtmp);

  /* Handle the prhs[0] element: The ode function that has to be solved */
  vtem = mxDuplicateArray (prhs[0]);
  if (mexCallMATLAB (1, &vtmp, 1, &vtem, "func2str"))
    mexErrMsgTxt ("Calling \"func2str\" has failed");
  fodepkgvar (1, "odefun", &vtmp);

  /* Handle the prhs[1] element: Split the integration interval */
  if (mxGetM (prhs[1]) == 2 || mxGetN (prhs[1]) == 2) {
    vtimeslot = mxMalloc (2 * sizeof (double));
    memcpy ((void *) vtimeslot, (void *) mxGetPr (prhs[1]), 2 * sizeof (double));
  }
  else mexErrMsgTxt ("Second input argument of this solver must be of size 1x2 or 2x1");
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Solving is done from tStart=%f to tStop=%f\n", 
             vtimeslot[0], vtimeslot[1]);
#endif

  /* Handle the prhs[2] element: Set the initial values */
  if (mxIsRowVector (prhs[2])) vodedimen = (int) mxGetN (prhs[2]);
  else vodedimen = (int) mxGetM (prhs[2]);
  vinitvals = mxMalloc (vodedimen * sizeof (double));
  vtmp = mxCreateDoubleScalar (vodedimen);
  fodepkgvar (1, "odedim", &vtmp);
  memcpy ((void *) vinitvals, (void *) mxGetPr (prhs[2]), vodedimen * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Number of initial values is %d\n", vodedimen);
  mexPrintf ("ODEPKGDEBUG: Last element of initial values is %f\n", vinitvals[vodedimen-1]);
#endif

  /* Handle the odeoptions structure field: RELTOL */
  fodepkgvar (2, "odeoptions", &vtmp);
  vtem = mxGetField (vtmp, 0, "RelTol");
  if (mxIsRowVector (vtem)) vcnt = (int) mxGetN (vtem);
  else vcnt = (int) mxGetM (vtem);
  vtolrelat = mxMalloc (vcnt * sizeof (double));
  memcpy ((void *) vtolrelat, (void *) mxGetPr (vtem), vcnt * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Last element of relative error is %f\n", vtolrelat[vcnt-1]);
#endif

  /* Handle the odeoptions structure field: ABSTOL */
  vtem = mxGetField (vtmp, 0, "AbsTol");
  if (mxIsRowVector (vtem)) vnum = (int) mxGetN (vtem);
  else vnum = (int) mxGetM (vtem);
  vtolabsol = mxMalloc (vnum * sizeof (double));
  memcpy ((void *) vtolabsol, (void *) mxGetPr (vtem), vnum * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Last element of relative error is %f\n", vtolabsol[vnum-1]);
#endif

  /* Handle the odeoptions structure field: RELTOL vs. ABSTOL */
  if (vcnt != vnum)
    mexErrMsgTxt ("Values of \"AbsTol\" and \"RelTol\" must have same size");
  else if (vcnt > 1) vtoltype = 1;
  else vtoltype = 0;
#ifdef __ODEPKGDEBUG__
   mexPrintf ("ODEPKGDEBUG: Type of dopri tolerance handling is %d\n", vtoltype);
#endif

  /* Handle the odeoptions structure field: NORMCONTROL */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "NormControl"),
                  mxGetField (vtem, 0, "NormControl") ) )
    mexWarnMsgTxt ("Option \"NormControl\" will be ignored by this solver");

  /* Handle the odeoptions structure field: OUTPUTFCN  */
  fodepkgvar (2, "odeoptions", &vtmp);
  vtem = mxGetField (vtmp, 0, "OutputFcn");
  if (mxIsEmpty (vtem) && (nlhs == 0)) {
    vtmp = mxCreateString ("odeplot");
    fodepkgvar (1, "plotfun", &vtmp);
  }
  else if (!mxIsEmpty (vtem)) {
    if (mexCallMATLAB (1, &vtmp, 1, &vtem, "func2str"))
      mexErrMsgTxt ("Calling \"func2str\" has failed");
    fodepkgvar (1, "plotfun", &vtmp);
  }
  else {
    vtmp = mxCreateString ("");
    fodepkgvar (1, "plotfun", &vtmp);
  }
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The output function was set to \"%s\"\n",
             mxArrayToString (vtmp));
#endif

  /* Handle the odeoptions structure field: OUTPUTSEL */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  vtmp = mxGetField (vtmp, 0, "OutputSel");
  vtem = mxGetField (vtem, 0, "OutputSel");
  if (!mxIsEqual (vtmp, vtem)) {
    vnum = (int) mxGetNumberOfElements (vtmp);
    vdbl = mxGetPr (vtmp);
    for (vcnt = 0; vcnt < vnum; vcnt++)
      if ((int)(vdbl[vcnt]) > vodedimen) {
	sprintf (vmsg, "Found invalid number element \"%d\" in option \"OuputSel\"", 
	  (int)(vdbl[vcnt]));
	mexErrMsgTxt (vmsg);
      }
    fodepkgvar (1, "outputsel", &vtmp);
  }
  else fodepkgvar (1, "outputsel", &vtmp);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The outputsel option has successfully been set\n");
#endif

  /* Handle the odeoptions structure field: REFINE */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Refine"), mxGetField (vtem, 0, "Refine")))
    mexWarnMsgTxt ("Not yet implemented option \"Refine\" will be ignored");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Refine option has not been set\n");
#endif

  /* Handle the odeoptions structure field: STATS */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Stats"), mxGetField (vtem, 0, "Stats"))) {
    /* mexWarnMsgTxt ("Not yet implemented option \"Stats\" will be ignored"); */
    vtmp = mxCreateLogicalScalar (true);
    fodepkgvar (1, "stats", &vtmp);
  }
  else {
    vtmp = mxCreateLogicalScalar (false);
    fodepkgvar (1, "stats", &vtmp);
#ifdef __ODEPKGDEBUG__
    mexPrintf ("ODEPKGDEBUG: The Stats option has not been set\n");
#endif
  }

  /* Handle the odeoptions structure field: INITIALSTEP */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "InitialStep"), mxGetField (vtem, 0, "InitialStep")))
    vinitstep = *mxGetPr (mxGetField (vtmp, 0, "InitialStep") );
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The inital step size is %f\n", vinitstep);
#endif

  /* Handle the odeoptions structure field: MAXSTEP */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MaxStep"), mxGetField (vtem, 0, "MaxStep")))
    vmaxstep = *mxGetPr (mxGetField (vtmp, 0, "MaxStep") );
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The maximum step size is %f\n", vmaxstep);
#endif

  /* Handle the odeoptions structure field: EVENTS */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Events"), mxGetField (vtem, 0, "Events")))
    mexWarnMsgTxt ("Not yet implemented option \"Events\" will be ignored");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Events option has not been set\n");
#endif

  /* Handle the odeoptions structure field: JACOBIAN */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Jacobian"), mxGetField (vtem, 0, "Jacobian")))
    mexWarnMsgTxt ("Option \"Jacobian\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Jacobian option has not been set\n");
#endif

  /* Handle the odeoptions structure field: JPATTERN */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "JPattern"), mxGetField (vtem, 0, "JPattern")))
    mexWarnMsgTxt ("Option \"JPattern\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The JPattern option has not been set\n");
#endif

  /* Handle the odeoptions structure field: VECTORIZED */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Vectorized"), mxGetField (vtem, 0, "Vectorized")))
    mexWarnMsgTxt ("Option \"Vectorized\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Vectorized option has not been set\n");
#endif

  /* Handle the odeoptions structure field: MASS */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Mass"), mxGetField (vtem, 0, "Mass")))
    mexWarnMsgTxt ("Option \"Mass\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Mass option has not been set\n");
#endif

  /* Handle the odeoptions structure field: MSTATEDEP */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MStateDependence"), mxGetField (vtem, 0, "MStateDependence")))
    mexWarnMsgTxt ("Option \"MStateDependence\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The MStateDependence option has not been set\n");
#endif

  /* Handle the odeoptions structure field: MVPATTERN */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MvPattern"), mxGetField (vtem, 0, "MvPattern")))
    mexWarnMsgTxt ("Option \"MvPattern\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The MvPattern option has not been set\n");
#endif

  /* Handle the odeoptions structure field: MASSSINGULAR */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MassSingular"), mxGetField (vtem, 0, "MassSingular")))
    mexWarnMsgTxt ("Option \"MassSingular\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The MassSingular option has not been set\n");
#endif

  /* Handle the odeoptions structure field: INITIALSLOPE */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "InitialSlope"), mxGetField (vtem, 0, "InitialSlope")))
    mexWarnMsgTxt ("Option \"InitialSlope\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The InitialSlope option has not been set\n");
#endif

  /* Handle the odeoptions structure field: MAXORDER */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MaxOrder"), mxGetField (vtem, 0, "MaxOrder")))
    mexWarnMsgTxt ("Option \"MaxOrder\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The MaxOrder option has not been set\n");
#endif

  /* Handle the odeoptions structure field: BDF */
  fodepkgvar (2, "odeoptions", &vtmp);
  fodepkgvar (2, "defoptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "BDF"), mxGetField (vtem, 0, "BDF")))
    mexWarnMsgTxt ("Option \"BDF\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The BDF option has not been set\n");
#endif

  /* Initialize the function: FODEPKGPLOT */
  fodepkgvar (2, "plotfun", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vtmp = mxDuplicateArray (prhs[1]);
    fy2mxArray (vodedimen, vinitvals, &vtem);
    if (!fodepkgplot (vtmp, vtem, mxCreateString ("init"))) {
      fodepkgvar (2, "plotfun", &vtmp);
      sprintf (vmsg, "Error at initialisation of output function \"%s\"", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
  }
/* #ifdef __ODEPKGDEBUG__ */
/*   fodepkgvar (9, NULL, NULL); */
/* #endif */

  /* Initialize the function: FSOLSTORE */
  vtmp = mxCreateDoubleScalar (vtimeslot[0]);
  fy2mxArray (vodedimen, vinitvals, &vtem);
  fsolstore (0, &vtmp, &vtem);

#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER CALCULATION PROCEDURE\n");
#endif

  vnum = dopri5 (vodedimen, fodefun, vtimeslot[0], vinitvals, 
    vtimeslot[1], vtolrelat, vtolabsol, vtoltype, fsolout, 2,
    stdout, 0.0, 0.0, 0.0, 0.0, 0.0, vmaxstep, vinitstep, 
    0, 0, 10, vodedimen, NULL, vodedimen);

#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER POSTPROCESSING PROCEDURE\n");
#endif

  /* Handle the odeoptions structure field: STATS */
  fodepkgvar (2, "stats", &vtmp);
  if (mxIsLogicalScalarTrue (vtmp)) { /* Print additional information */
    vnum = nstepRead ();  /* A dopri solver function */
    vtem = mxCreateDoubleScalar ((double) vnum);
    fodepkgvar (1, "vsuccess", &vtem);
    mexPrintf ("Number of used steps:     %d\n", vnum);

    vnum = naccptRead (); /* A dopri solver function */
    vtem = mxCreateDoubleScalar ((double) vnum);
    fodepkgvar (1, "vaccept", &vtem);
    mexPrintf ("Number of accepted steps: %d\n", vnum);

    vnum = nrejctRead (); /* A dopri solver function */
    vtem = mxCreateDoubleScalar ((double) vnum);
    fodepkgvar (1, "vreject", &vtem);
    mexPrintf ("Number of rejected steps: %d\n", vnum);

    vnum = nfcnRead ();  /* A dopri solver function */
    vtem = mxCreateDoubleScalar ((double) vnum);
    fodepkgvar (1, "vfevals", &vtem);
    mexPrintf ("Number of function calls: %d\n", vnum);
  }

  /* Handle the PLHS array */
  if (nlhs == 1) {
    plhs[0] = mxCreateStructArray (1, &vone, 0, NULL);

    fsolstore (2, &vtmp, &vtem);

    mxAddField (plhs[0], "x");
    vnum = mxGetFieldNumber (plhs[0], "x");
    mxSetFieldByNumber (plhs[0], 0, vnum, vtmp);

    mxAddField (plhs[0], "y");
    vnum = mxGetFieldNumber (plhs[0], "y");
    mxSetFieldByNumber (plhs[0], 0, vnum, mxTransposeMatrix (vtem));

    mxAddField (plhs[0], "solver");
    vnum = mxGetFieldNumber (plhs[0], "solver");
    mxSetFieldByNumber (plhs[0], 0, vnum, mxCreateString ("ode5d"));

    fodepkgvar (2, "stats", &vtmp);
    if (mxIsLogicalScalarTrue (vtmp)) { /* Put additional information */
      vtem = mxCreateStructArray (1, &vone, 0, NULL);

      mxAddField (vtem, "success");
      vnum = mxGetFieldNumber (vtem, "success");
      fodepkgvar (2, "vsuccess", &vtmp);
      mxSetFieldByNumber (vtem, 0, vnum, mxDuplicateArray (vtmp));

      mxAddField (vtem, "failed");
      vnum = mxGetFieldNumber (vtem, "failed");
      fodepkgvar (2, "vreject", &vtmp);
      mxSetFieldByNumber (vtem, 0, vnum, mxDuplicateArray (vtmp));

      mxAddField (vtem, "fevals");
      vnum = mxGetFieldNumber (vtem, "fevals");
      fodepkgvar (2, "vfevals", &vtmp);
      mxSetFieldByNumber (vtem, 0, vnum, mxDuplicateArray (vtmp));

      mxAddField (vtem, "partial");
      vnum = mxGetFieldNumber (vtem, "partial");
      mxSetFieldByNumber (vtem, 0, vnum, mxCreateDoubleScalar (0.0));

      mxAddField (vtem, "ludecom");
      vnum = mxGetFieldNumber (vtem, "ludecom");
      mxSetFieldByNumber (vtem, 0, vnum, mxCreateDoubleScalar (0.0));

      mxAddField (vtem, "linsol");
      vnum = mxGetFieldNumber (vtem, "linsol");
      mxSetFieldByNumber (vtem, 0, vnum, mxCreateDoubleScalar (0.0));

      mxAddField (plhs[0], "stats");
      vnum = mxGetFieldNumber (plhs[0], "stats");
      mxSetFieldByNumber (plhs[0], 0, vnum, vtem);

    }
  }

  else if (nlhs == 2) {
    fsolstore (2, &vtmp, &vtem);
    plhs[0] = vtmp;
    plhs[1] = mxTransposeMatrix (vtem);
  }

  else if (nlhs == 5) {

  }

#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER CLEANUP PROCEDURE\n");
#endif

/*   fsolstore (2, vtmp, vtem); */
/*   vdbl = mxGetPr (vtmp); */
/*   mexPrintf ("-----> %f\n", vdbl[0]); */
/*   plhs[0] = vtmp; */

  /* Cleanup all internals of: FODEPKGPLOT */
  fodepkgvar (2, "plotfun", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vtmp = mxDuplicateArray (prhs[1]);
    vtem = mxDuplicateArray (prhs[2]);
    if (!fodepkgplot (vtmp, vtem, mxCreateString ("done"))) {
      fodepkgvar (2, "plotfun", &vtmp);
      sprintf (vmsg, "Error at finalisation of output function \"%s\"", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
  }

  /* Cleanup all internals of: FSOLSTORE */
  fsolstore (4, NULL, NULL);
  /* Cleanup all internals of: FODEPKGVAR */
  fodepkgvar (4, NULL, NULL);
}

/*
Local Variables: ***
mode: C ***
End: ***
*/
