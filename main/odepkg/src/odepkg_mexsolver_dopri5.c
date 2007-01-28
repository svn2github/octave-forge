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
#include "odepkgext.h" /* Needed for the odepkg interfaces */
#include "dopri5.h"    /* Needed for the solver function */

/* These prototype definitions from functions that are found in this file */
void fodefun (unsigned n, double x, double *y, double *f);
void fsolout (long nr, double xold, double x, double* y, unsigned n, int* irtrn);
void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]);

/**
 * TODO
 * Return value: On success the constant %true, otherwise %false.
 **/
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

  /* Evaluate the ode function in the octave workspace */
  fodepkgvar (2, "OdeFunction", &vtmp);
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
  double   vdbt = 0.0;
  unsigned int vref = 0;
  unsigned int vcnt = 0;
  unsigned int vnum = 0;

  double  *vdob = NULL;
  double  *vdbl = NULL;
  mxArray *vtmp = NULL;
  mxArray *vtem = NULL;
  mxArray *vtim = NULL;
  mxArray *vrtm = NULL;
  mxArray *vrvl = NULL;

  /* Convert the double *y into a selection of variables */
  fy2mxArray (n, y, &vtem);
  vtim = mxCreateDoubleScalar (x);

  /* Save the solution if this is not the initial first call */
  if (nr > 1) fsolstore (1, &vtim, &vtem);

  /* Call output function if this is not the initial first call */
  fodepkgvar (2, "PlotFunction", &vtmp);
  if (!mxIsEmpty (vtmp) && nr > 1) {
    fodepkgvar (2, "Refine", &vtmp); /* Check for "Refine" option */
    vdbl = mxGetPr (vtmp);
    vref = (int)vdbl[0];

    if (vref > 0) { /* If the Refine option is > 0 */
      vdob = (double *) mxMalloc (n * sizeof (double));

      for (vcnt = 0; vcnt < vref; vcnt++) {
        vdbt = xold + (double)(vcnt + 1) * ((x - xold) / (vdbl[0] + 2));
        vrtm = mxCreateDoubleScalar (vdbt);
        /* Time stamps for approximation: mexPrintf ("%f %f %f\n", xold, vdbt, x); */

        for (vnum = 0; vnum < n; vnum++) vdob[vnum] = contd5(vnum, vdbt);
        fy2mxArray (n, vdob, &vrvl);
        /* Time stamps and approx. values: mexPrintf ("%f %f %f\n", vdbt, vdob[0], vdob[1]); */
        fodepkgplot (vrtm, vrvl, mxCreateString (""));
      }
      mxFree (vdob);
    }
    vsuc = fodepkgplot (vtim, vtem, mxCreateString (""));
    if (vsuc == false) {
      mexPrintf ("Integration has been stopped from output function at time t=%f\n", x);
      irtrn[0] = - 1; /* Stop integration ? */
    }
  }

  fodepkgvar (2, "EventFunction", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    fodepkgevent (vtim, vtem, mxCreateString (""), &vtmp);
    fodepkgvar (3, "EventSolution", NULL);  /* Remove the last events results */
    fodepkgvar (1, "EventSolution", &vtmp); /* Set the new events results */

    vtem = mxGetCell (vtmp, 0);    /* Check if we have to stop solving */
    if (mxIsLogicalScalarTrue (vtem)) {
      fsolstore (3, NULL, NULL);   /* Remove the last solution entry */
      vtem = mxGetCell (vtmp, 3);  /* Get last row of events solution */
      vtim = mxCreateDoubleScalar (x);
      vtmp = mxGetMatrixRow (vtem, mxGetM (vtem) - 1);
      fsolstore (1, &vtim, &vtmp); /* Set last row of events solution */
      mexPrintf ("Integration has been stopped from event function at time t=%f\n", x);
      irtrn[0] = -1;               /* Tell the solver to stop solving */
    }
  }
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
      fodepkgvar (1, "OdeOptions", &vtmp);
    }

    else if (nrhs > 4) { /* An option structure and further arguments have been set */
      vnum = nrhs - 4; vtmp = mxCreateCellArray (1, &vnum);
      for (vcnt = 4; vcnt < nrhs; vcnt++)
        mxSetCell (vtmp, vcnt-4, mxDuplicateArray (prhs[vcnt]));
      fodepkgvar (1, "varargin", &vtmp);
      vtem = mxDuplicateArray (prhs[3]);
      if (mexCallMATLAB (1, &vtmp, 1, &vtem, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling \"odepkg_structure_check\" has failed");
      fodepkgvar (1, "OdeOptions", &vtmp);
    }

    else { /* Only an option-structure and no further arguments have been set */
      vnum = 0; vtmp = mxCreateCellArray (1, &vnum);
      fodepkgvar (1, "varargin", &vtmp);
      vtem = mxDuplicateArray (prhs[3]);
      if (mexCallMATLAB (1, &vtmp, 1, &vtem, "odepkg_structure_check"))
        mexErrMsgTxt ("Calling \"odepkg_structure_check\" has failed");
      fodepkgvar (1, "OdeOptions", &vtmp);
    }

  } /* No valid function call has been found before - set the defaults */
  else {
      vnum = 0; vtmp = mxCreateCellArray (1, &vnum);
      fodepkgvar (1, "varargin", &vtmp);
      if (mexCallMATLAB (1, &vtmp, 0, NULL, "odeset"))
        mexErrMsgTxt ("Calling \"odeset\" has failed");
      fodepkgvar (1, "OdeOptions", &vtmp);
  }

  /* Get the default options (Calling 'odeset' without arguments) */
  if (mexCallMATLAB (1, &vtmp, 0, NULL, "odeset"))
    mexErrMsgTxt ("Calling \"odeset\" has failed");
  fodepkgvar (1, "DefaultOptions", &vtmp);

  /* Handle the prhs[0] element: The ode function that has to be solved */
  vtem = mxDuplicateArray (prhs[0]);
  if (mexCallMATLAB (1, &vtmp, 1, &vtem, "func2str"))
    mexErrMsgTxt ("Calling \"func2str\" has failed");
  fodepkgvar (1, "OdeFunction", &vtmp);

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
  fodepkgvar (1, "OdeDimension", &vtmp);
  memcpy ((void *) vinitvals, (void *) mxGetPr (prhs[2]), vodedimen * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Number of initial values is %d\n", vodedimen);
  mexPrintf ("ODEPKGDEBUG: Last element of initial values is %f\n", vinitvals[vodedimen-1]);
#endif

  /* Handle the OdeOptions structure field: RELTOL */
  fodepkgvar (2, "OdeOptions", &vtmp);
  vtem = mxGetField (vtmp, 0, "RelTol");
  if (mxIsRowVector (vtem)) vcnt = (int) mxGetN (vtem);
  else vcnt = (int) mxGetM (vtem);
  vtolrelat = mxMalloc (vcnt * sizeof (double));
  memcpy ((void *) vtolrelat, (void *) mxGetPr (vtem), vcnt * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Last element of relative error is %f\n", vtolrelat[vcnt-1]);
#endif

  /* Handle the OdeOptions structure field: ABSTOL */
  vtem = mxGetField (vtmp, 0, "AbsTol");
  if (mxIsRowVector (vtem)) vnum = (int) mxGetN (vtem);
  else vnum = (int) mxGetM (vtem);
  vtolabsol = mxMalloc (vnum * sizeof (double));
  memcpy ((void *) vtolabsol, (void *) mxGetPr (vtem), vnum * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Last element of relative error is %f\n", vtolabsol[vnum-1]);
#endif

  /* Handle the OdeOptions structure field: RELTOL vs. ABSTOL */
  if (vcnt != vnum)
    mexErrMsgTxt ("Values of \"AbsTol\" and \"RelTol\" must have same size");
  else if (vcnt > 1) vtoltype = 1;
  else vtoltype = 0;
#ifdef __ODEPKGDEBUG__
   mexPrintf ("ODEPKGDEBUG: Type of dopri tolerance handling is %d\n", vtoltype);
#endif

  /* Handle the OdeOptions structure field: NORMCONTROL */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "NormControl"),
                  mxGetField (vtem, 0, "NormControl") ) )
    mexWarnMsgTxt ("Option \"NormControl\" will be ignored by this solver");

  /* Handle the OdeOptions structure field: OUTPUTFCN  */
  fodepkgvar (2, "OdeOptions", &vtmp);
  vtem = mxGetField (vtmp, 0, "OutputFcn");
  if (mxIsEmpty (vtem) && (nlhs == 0)) {
    vtmp = mxCreateString ("odeplot");
    fodepkgvar (1, "PlotFunction", &vtmp);
  }
  else if (!mxIsEmpty (vtem)) {
    if (mexCallMATLAB (1, &vtmp, 1, &vtem, "func2str"))
      mexErrMsgTxt ("Calling \"func2str\" has failed");
    fodepkgvar (1, "PlotFunction", &vtmp);
  }
  else {
    vtmp = mxCreateString ("");
    fodepkgvar (1, "PlotFunction", &vtmp);
  }
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The output function was set to \"%s\"\n",
             mxArrayToString (vtmp));
#endif

  /* Handle the OdeOptions structure field: OUTPUTSEL */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
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
    fodepkgvar (1, "OutputSelection", &vtmp);
  }
  else fodepkgvar (1, "OutputSelection", &vtmp);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The outputsel option has successfully been set\n");
#endif

  /* Handle the OdeOptions structure field: REFINE */
  fodepkgvar (2, "OdeOptions", &vtmp);
  vtem = mxGetField (vtmp, 0, "Refine");
  fodepkgvar (1, "Refine", &vtem);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The Refine option has been set\n");
#endif

  /* Handle the OdeOptions structure field: STATS */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Stats"), mxGetField (vtem, 0, "Stats"))) {
    /* mexWarnMsgTxt ("Not yet implemented option \"Stats\" will be ignored"); */
    vtmp = mxCreateLogicalScalar (true);
    fodepkgvar (1, "Stats", &vtmp);
  }
  else {
    vtmp = mxCreateLogicalScalar (false);
    fodepkgvar (1, "Stats", &vtmp);
#ifdef __ODEPKGDEBUG__
    mexPrintf ("ODEPKGDEBUG: The Stats option has not been set\n");
#endif
  }

  /* Handle the OdeOptions structure field: INITIALSTEP */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "InitialStep"), mxGetField (vtem, 0, "InitialStep")))
    vinitstep = *mxGetPr (mxGetField (vtmp, 0, "InitialStep") );
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The inital step size is %f\n", vinitstep);
#endif

  /* Handle the OdeOptions structure field: MAXSTEP */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MaxStep"), mxGetField (vtem, 0, "MaxStep")))
    vmaxstep = *mxGetPr (mxGetField (vtmp, 0, "MaxStep") );
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The maximum step size is %f\n", vmaxstep);
#endif

  /* Handle the OdeOptions structure field: EVENTS */
  fodepkgvar (2, "OdeOptions", &vtmp);
  vtem = mxGetField (vtmp, 0, "Events");
  fodepkgvar (1, "EventFunction", &vtem);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The Events option has been set\n");
#endif

  /* Handle the OdeOptions structure field: JACOBIAN */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Jacobian"), mxGetField (vtem, 0, "Jacobian")))
    mexWarnMsgTxt ("Option \"Jacobian\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Jacobian option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: JPATTERN */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "JPattern"), mxGetField (vtem, 0, "JPattern")))
    mexWarnMsgTxt ("Option \"JPattern\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The JPattern option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: VECTORIZED */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Vectorized"), mxGetField (vtem, 0, "Vectorized")))
    mexWarnMsgTxt ("Option \"Vectorized\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Vectorized option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: MASS */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "Mass"), mxGetField (vtem, 0, "Mass")))
    mexWarnMsgTxt ("Option \"Mass\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The Mass option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: MSTATEDEP */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MStateDependence"), mxGetField (vtem, 0, "MStateDependence")))
    mexWarnMsgTxt ("Option \"MStateDependence\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The MStateDependence option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: MVPATTERN */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MvPattern"), mxGetField (vtem, 0, "MvPattern")))
    mexWarnMsgTxt ("Option \"MvPattern\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The MvPattern option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: MASSSINGULAR */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MassSingular"), mxGetField (vtem, 0, "MassSingular")))
    mexWarnMsgTxt ("Option \"MassSingular\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The MassSingular option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: INITIALSLOPE */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "InitialSlope"), mxGetField (vtem, 0, "InitialSlope")))
    mexWarnMsgTxt ("Option \"InitialSlope\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The InitialSlope option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: MAXORDER */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MaxOrder"), mxGetField (vtem, 0, "MaxOrder")))
    mexWarnMsgTxt ("Option \"MaxOrder\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The MaxOrder option has not been set\n");
#endif

  /* Handle the OdeOptions structure field: BDF */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "BDF"), mxGetField (vtem, 0, "BDF")))
    mexWarnMsgTxt ("Option \"BDF\" will be ignored by this solver");
#ifdef __ODEPKGDEBUG__
  else
    mexPrintf ("ODEPKGDEBUG: The BDF option has not been set\n");
#endif

  /* Initialize the function: FODEPKGPLOT */
  fodepkgvar (2, "PlotFunction", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vtmp = mxDuplicateArray (prhs[1]);
    fy2mxArray (vodedimen, vinitvals, &vtem);
    if (!fodepkgplot (vtmp, vtem, mxCreateString ("init"))) {
      fodepkgvar (2, "PlotFunction", &vtmp);
      sprintf (vmsg, "Error at initialisation of output function \"%s\"", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
#ifdef __ODEPKGDEBUG__
    else
      mexPrintf ("ODEPKGDEBUG: Initialisation of output function successfully completed\n");
#endif
  }

  /* Initialize the function: FODEPKGEVENT */
  fodepkgvar (2, "EventFunction", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vtmp = mxCreateDoubleScalar (vtimeslot[0]);
    fy2mxArray (vodedimen, vinitvals, &vtem);
    if (!fodepkgevent (vtmp, vtem, mxCreateString ("init"), NULL)) {
      fodepkgvar (2, "EventFunction", &vtmp);
      sprintf (vmsg, "Error at initialisation of event function \"%s\"", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
#ifdef __ODEPKGDEBUG__
    else
      mexPrintf ("ODEPKGDEBUG: Initialisation of event function successfully completed\n");
#endif
  }

  /* Initialize the function: FSOLSTORE */
  vtmp = mxCreateDoubleScalar (vtimeslot[0]);
  fy2mxArray (vodedimen, vinitvals, &vtem);
  fsolstore (0, &vtmp, &vtem);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Initialisation of fsolstore function successfully completed\n");
#endif

#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER CALCULATION PROCEDURE\n");
#endif

  vnum = dopri5 (vodedimen, fodefun, vtimeslot[0], vinitvals, 
    vtimeslot[1], vtolrelat, vtolabsol, vtoltype, fsolout, 2,
    stdout, 0.0, 0.0, 0.0, 0.0, 0.0, vmaxstep, vinitstep, 
    0, 0, 100, vodedimen, NULL, vodedimen);
  switch (vnum) {
    case -4:
      mexPrintf ("The computation has been stopped because the problem is probably stff\n");
      break;
    case -3:
      mexPrintf ("The step size grew too small, reduce InitialStep and/or MaxStep\n");
      break;
    case -2:
      mexPrintf ("Maximal number of allowed steps (100000) has been reached\n");
      break;
    case -1:
      mexPrintf ("Input is not consistent\n");
      break;
    case 0:  break; /* Not treated */
    case 1:  break; /* Computation has been successful */
    case 2:  break; /* Computation has been successful, stopped of fsolout */
    default: break;
  }
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER POSTPROCESSING PROCEDURE\n");
#endif

  /* Handle the OdeOptions structure field: STATS */
  fodepkgvar (2, "Stats", &vtmp);
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

  if (nlhs == 1) { /* Handle the PLHS array (1 output argument) */
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

    fodepkgvar (2, "Stats", &vtmp);
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

      mxAddField (plhs[0], "Stats");
      vnum = mxGetFieldNumber (plhs[0], "Stats");
      mxSetFieldByNumber (plhs[0], 0, vnum, vtem);
    }

    fodepkgvar (2, "EventFunction", &vtmp);
    if (!mxIsEmpty (vtmp)) { /* Put additional information about events */
      fodepkgvar (2, "EventSolution", &vtem);

      mxAddField (plhs[0], "ie");
      vnum = mxGetFieldNumber (plhs[0], "ie");
      vtmp = mxDuplicateArray (mxGetCell (vtem, 1));
      mxSetFieldByNumber (plhs[0], 0, vnum, vtmp);

      mxAddField (plhs[0], "xe");
      vnum = mxGetFieldNumber (plhs[0], "xe");
      vtmp = mxDuplicateArray (mxGetCell (vtem, 2));
      mxSetFieldByNumber (plhs[0], 0, vnum, vtmp);

      mxAddField (plhs[0], "ye");
      vnum = mxGetFieldNumber (plhs[0], "ye");
      vtmp = mxDuplicateArray (mxGetCell (vtem, 3));
      mxSetFieldByNumber (plhs[0], 0, vnum, vtmp);
    }
  }

  else if (nlhs == 2) { /* Handle the PLHS array (2 output arguments) */
    fsolstore (2, &vtmp, &vtem);
    plhs[0] = vtmp;
    plhs[1] = mxTransposeMatrix (vtem);
  }

  else if (nlhs == 5) { /* Handle the PLHS array (5 output arguments) */
    fsolstore (2, &vtmp, &vtem);
    plhs[0] = vtmp;
    plhs[1] = mxTransposeMatrix (vtem);

    fodepkgvar (2, "EventSolution", &vtem);
    plhs[2] = mxDuplicateArray (mxGetCell (vtem, 2));
    plhs[3] = mxDuplicateArray (mxGetCell (vtem, 3));
    plhs[4] = mxDuplicateArray (mxGetCell (vtem, 1));
    /* mexCallMATLAB (0, NULL, 1, &vtem, "disp"); */
  }

#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER CLEANUP PROCEDURE\n");
#endif

  /* Cleanup all internals of: FODEPKGPLOT */
  fodepkgvar (2, "PlotFunction", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vtmp = mxDuplicateArray (prhs[1]);
    fy2mxArray (vodedimen, vinitvals, &vtem); /* vtem = mxDuplicateArray (prhs[2]); */
    if (!fodepkgplot (vtmp, vtem, mxCreateString ("done"))) {
      fodepkgvar (2, "PlotFunction", &vtmp);
      sprintf (vmsg, "Error at finalisation of output function \"%s\"", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
#ifdef __ODEPKGDEBUG__
    else
      mexPrintf ("ODEPKGDEBUG: Cleanup of output function successfully completed\n");
#endif
  }

  /* Cleanup all internals of: FODEPKGEVENT */
  fodepkgvar (2, "EventFunction", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vtmp = mxCreateDoubleScalar (vtimeslot[0]);
    fy2mxArray (vodedimen, vinitvals, &vtem);
    if (!fodepkgevent (vtmp, vtem, mxCreateString ("done"), NULL)) {
      fodepkgvar (2, "EventFunction", &vtmp);
      sprintf (vmsg, "Error at initialisation of event function \"%s\"", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
#ifdef __ODEPKGDEBUG__
    else
      mexPrintf ("ODEPKGDEBUG: Cleanup of event function successfully completed\n");
#endif
  }

  /* Free and destroy the mxAllocated arrays */
/*   mxFree (vtimeslot); */
/*   mxFree (vinitvals); */
/*   mxFree (vtolrelat); */
/*   mxFree (vtolabsol); */
/*   mxDestroyArray (vtmp); */
/*   mxDestroyArray (vtem); */
fodepkgvar (9, NULL, NULL);

  /* Cleanup all internals of: FSOLSTORE */
  fsolstore (4, NULL, NULL);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Cleanup of fsolstore function successfully completed\n");
#endif

  /* Cleanup all internals of: FODEPKGVAR */
  fodepkgvar (4, NULL, NULL);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Cleanup of fodepkgvar function successfully completed\n");
#endif

}

/*
Local Variables: ***
mode: C ***
End: ***
*/
