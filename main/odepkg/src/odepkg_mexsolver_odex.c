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

/* To manually compile this file with debug messages

     mkoctfile --mex -Wall -W -Wshadow -D__ODEPKGDEBUG__ \
     odepkg_mexsolver_odex.c odepkgmex.c odepkgext.c hairer/odex.f

   or

     mex -v -D__ODEPKGDEBUG__ odepkg_mexsolver_odex.c odepkgext.c \
     odepkgmex.c hairer/odex.f

   a function check can be done via

     octave --quiet --eval "A = odeset (\"RelTol\", 1e-3, \"AbsTol\", 1e-4, \
       \"OutputFcn\", @odeprint, \"OutputSel\", [2, 1], \"Refine\", 3); \
     [C, B] = odepkg_mexsolver_odex (@odepkg_equations_vanderpol, \
       [0, 1], [2, 0], A, 12)"
*/

#include <config.h>    /* Needed for the F77_FUNC definition etc. */
#include <mex.h>       /* Needed for all mex definitions */
#include <f77-fcn.h>   /* Needed for the use of Fortran routines */
#include <stdio.h>     /* Needed for the sprintf function etc.*/
#include <string.h>    /* Needed for the memcpy function etc.*/
#include "odepkgmex.h" /* Needed for the mex extensions */
#include "odepkgext.h" /* Needed for the odepkg interfaces */

/* These are the prototype definitions for the solver function, the
   interpolation function that is used to achieve better results, the
   Jacobian calculation function (if any), the mass calculation
   function and the output function. These functions are very similar
   to the functions from other solvers, therefore there is nor
   explicit documentation for them in the manual. */

extern void F77_FUNC (odex, ODEX) (int *N, void *FCN, double *X, double *Y,
  double *XEND, double *H, double *RTOL, double *ATOL, int *ITOL, void *SOL, 
  int *IOUT, double *WORK, int *LWORK, int *IWORK, int *LIWORK, double *RPAR,
  int *IPAR, int *VRET);

extern double F77_FUNC (contex, CONTEX) (int *I, double *S, double *CON,
  int *NCON, int *ICOMP, int *ND);

void F77_FUNC (ffcn, FFCN) (int *N, double *X, double *Y, double *F, 
  GCC_ATTR_UNUSED double *RPAR, GCC_ATTR_UNUSED int *IPAR) {
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
  vrhs[0] = mxCreateDoubleScalar (*X);

  /* Copy the values that are given from the solver into the mxArray */
  vrhs[1] = mxCreateDoubleMatrix (*N, 1, mxREAL);
  memcpy ((void *) mxGetPr (vrhs[1]), (void *) Y, *N * sizeof (double));

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
  memcpy ((void *) F, (void *) mxGetPr (vlhs[0]), *N * sizeof (double));
  mxFree (vlhs); /* Free the vlhs mxArray */
  mxFree (vrhs); /* Free the vrhs mxArray */
}

void F77_FUNC (fsol, FSOL) (int *NR, double *XOLD, double *X, double *Y, int *N,
  double *CON, int *NCON, int *ICOMP, int *ND, GCC_ATTR_UNUSED double *RPAR, 
  GCC_ATTR_UNUSED int *IPAR, int *IRTRN) {

  bool     vsuc = false;
  double   vdbt = 0.0;
  unsigned int vref = 0;
  unsigned int vcnt = 0;
  int vnum = 0;

  double  *vdob = NULL;
  double  *vdbl = NULL;
  mxArray *vtmp = NULL;
  mxArray *vtem = NULL;
  mxArray *vtim = NULL;
  mxArray *vrtm = NULL;
  mxArray *vrvl = NULL;

  /* Convert the double *y into a selection of variables */
  fy2mxArray (*N, Y, &vtem);
  vtim = mxCreateDoubleScalar (*X);

  /* Save the solution if this is not the initial first call */
  if (*NR > 1) fsolstore (1, &vtim, &vtem);

  /* Call output function if this is not the initial first call */
  fodepkgvar (2, "PlotFunction", &vtmp);
  if (!mxIsEmpty (vtmp) && *NR > 1) {
    fodepkgvar (2, "Refine", &vtmp); /* Check for "Refine" option */
    vdbl = mxGetPr (vtmp);
    vref = (int)vdbl[0];

    if (vref > 0) { /* If the Refine option is > 0 */
      vdob = (double *) mxMalloc (*N * sizeof (double));

      for (vcnt = 0; vcnt < vref; vcnt++) {
        vdbt = *XOLD + (double)(vcnt + 1) * ((*X - *XOLD) / (vref + 2));
        vrtm = mxCreateDoubleScalar (vdbt);
        /* Time stamps for approximation: mexPrintf ("%f %f %f\n", *XOLD, vdbt, x); */

        for (vnum = 1; vnum <= *N; vnum++)
          vdob[vnum-1] = F77_FUNC (contex, CONTEX) (&vnum, &vdbt, CON, NCON, ICOMP, ND);

        fy2mxArray (*N, vdob, &vrvl);
        /* Time stamps and approx. values: mexPrintf ("%f %f %f\n", vdbt, vdob[0], vdob[1]); */
        fodepkgplot (vrtm, vrvl, mxCreateString (""));
      }
      mxFree (vdob);
    }
    vsuc = fodepkgplot (vtim, vtem, mxCreateString (""));
    if (vsuc == false) {
      mexPrintf ("Integration has been stopped from output function at time t=%f\n", *X);
      IRTRN[0] = - 1; /* Stop integration ? */
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
      vtim = mxCreateDoubleScalar (*X);
      vtmp = mxGetMatrixRow (vtem, mxGetM (vtem) - 1);
      fsolstore (1, &vtim, &vtmp); /* Set last row of events solution */
      mexPrintf ("Integration has been stopped from event function at time t=%f\n", *X);
      IRTRN[0] = -1;               /* Tell the solver to stop solving */
    }
  }
}

void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) { 
  int      vcnt = 0;
  int      vnum = 0;
  double  *vdbl = NULL;
  char     vmsg[64] = "";
  mxArray *vtmp = NULL;
  mxArray *vtem = NULL;

  /* Variables that are needed to call the solver function */
  int     N = 0;        /* Dimension of differential equations */
  int     ITOL = 0;     /* Type of error tolerance handling */
  int     LWORK = 0;    /* Size of work vector will be set later */
  int     LIWORK = 0;   /* Size of iwork vector will be set later */
  int    *IWORK = NULL; /* Memory of iwork vector will be allocated later */
  int     IPAR = 0;     /* Integer parameters will be unused */
  int     VRET = 0;     /* Return value of the solver function */
  double *SLOT = NULL;  /* Time slot values tstart and tend */
  double *INIT = NULL;  /* Initial values for differential equations */
  double *RTOL = NULL;  /* Relative tolerances scalar or vector */
  double *ATOL = NULL;  /* Absolute tolerances scalar or vector */
  double *WORK = NULL;  /* Memory of work vector will be allocated later */
  double  H = 0.0;      /* Initial step size guess, odex will set this */
  double  RPAR = 0;     /* Real parameters will be unused */

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
    mexUsgMsgTxt ("[t, y] = odepkg_mexsolver_odex (fun, slot, init, varargin)");
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
    SLOT = mxMalloc (2 * sizeof (double));
    memcpy ((void *) SLOT, (void *) mxGetPr (prhs[1]), 2 * sizeof (double));
  }
  else mexErrMsgTxt ("Second input argument of this solver must be of size 1x2 or 2x1");
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Solving is done from tStart=%f to tStop=%f\n", 
             SLOT[0], SLOT[1]);
#endif

  /* Handle the prhs[2] element: Set the dimension and the initial values */
  if (mxIsRowVector (prhs[2])) N = (int) mxGetN (prhs[2]);
  else N = (int) mxGetM (prhs[2]);
  INIT = mxMalloc (N * sizeof (double));
  vtmp = mxCreateDoubleScalar (N);
  fodepkgvar (1, "OdeDimension", &vtmp);
  memcpy ((void *) INIT, (void *) mxGetPr (prhs[2]), N * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Number of initial values is %d\n", N);
  mexPrintf ("ODEPKGDEBUG: Last element of initial values is %f\n", INIT[N-1]);
#endif

  /* Initialize the WORK and LWORK vectors with zeros */
  LWORK = N*(9+5)+5*9+20+(2*9*(9+2)+5)*N; /* LWORK = N*(KM+5)+5*KM+20+(2*KM*(KM+2)+5)*NRDENS; */
  WORK = (double *) mxMalloc (LWORK * sizeof (double));
  for (vcnt = 0; vcnt < LWORK; vcnt++) WORK[vcnt] = 0.0;
  LIWORK = 2*9+21+N; /* LIWORK = 2*KM+21+NRDENS; */
  IWORK = (int *) mxMalloc (LIWORK * sizeof (int));
  for (vcnt = 0; vcnt < LIWORK; vcnt++) IWORK[vcnt] = 0;

  /* Handle the OdeOptions structure field: RELTOL */
  fodepkgvar (2, "OdeOptions", &vtmp);
  vtem = mxGetField (vtmp, 0, "RelTol");
  if (mxIsRowVector (vtem)) vcnt = (int) mxGetN (vtem);
  else vcnt = (int) mxGetM (vtem);
  RTOL = mxMalloc (vcnt * sizeof (double));
  memcpy ((void *) RTOL, (void *) mxGetPr (vtem), vcnt * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Last element of relative error is %f\n", RTOL[vcnt-1]);
#endif

  /* Handle the OdeOptions structure field: ABSTOL */
  vtem = mxGetField (vtmp, 0, "AbsTol");
  if (mxIsRowVector (vtem)) vnum = (int) mxGetN (vtem);
  else vnum = (int) mxGetM (vtem);
  ATOL = mxMalloc (vnum * sizeof (double));
  memcpy ((void *) ATOL, (void *) mxGetPr (vtem), vnum * sizeof (double));
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Last element of relative error is %f\n", ATOL[vnum-1]);
#endif

  /* Handle the OdeOptions structure field: RELTOL vs. ABSTOL vs. N */
  if (vcnt != vnum)
    mexErrMsgTxt ("\"AbsTol\" and \"RelTol\" must have same size");
  else if (vcnt > 1) {
    if (vcnt != N)
      mexErrMsgTxt ("\"AbsTol\", \"RelTol\" and the dimension must have same size");
    ITOL = 1;
  }
  else ITOL = 0;
#ifdef __ODEPKGDEBUG__
   mexPrintf ("ODEPKGDEBUG: Type of dopri tolerance handling is %d\n", ITOL);
#endif

  /* Handle the OdeOptions structure field: NORMCONTROL */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (mxIsEqual (mxGetField (vtmp, 0, "NormControl"), mxCreateString ("on"))) IWORK[5] = 0;
  else IWORK[5] = 1;

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
      if ((int)(vdbl[vcnt]) > N) {
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
    H = *mxGetPr (mxGetField (vtmp, 0, "InitialStep") );
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The inital step size is %f\n", WORK[6]);
#endif

  /* Handle the OdeOptions structure field: MAXSTEP */
  fodepkgvar (2, "OdeOptions", &vtmp);
  fodepkgvar (2, "DefaultOptions", &vtem);
  if (!mxIsEqual (mxGetField (vtmp, 0, "MaxStep"), mxGetField (vtem, 0, "MaxStep")))
    WORK[1] = *mxGetPr (mxGetField (vtmp, 0, "MaxStep") );
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: The maximum step size is %f\n", WORK[5]);
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
    fy2mxArray (N, INIT, &vtem);
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
    vtmp = mxCreateDoubleScalar (SLOT[0]);
    fy2mxArray (N, INIT, &vtem);
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
  vtmp = mxCreateDoubleScalar (SLOT[0]);
  fy2mxArray (N, INIT, &vtem);
  fsolstore (0, &vtmp, &vtem);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Initialisation of fsolstore function successfully completed\n");
#endif

#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER CALCULATION PROCEDURE\n");
#endif

  /* IWORK[0] = 10^4; */ /* The maximal number of allowed steps */
  /* IWORK[1] = 0; */    /* Number of needed extrapolation columns */
  IWORK[2] = 5;    /* Switch for step size sequence */
  /* IWORK[3] = 1000; */ /* Switch for stability check activation  */
  /* IWORK[4] = 0; */    /* Switch for stability check activation  */
  /* IWORK[5] = 0; */    /* Switch for error estimation, cf. NormControl */
  /* IWORK[6] = 0; */    /* Number for the degree of interpolation */
  IWORK[7] = N;          /* Number of components for dense output */

  /* FORTRAN SUBROUTINE ODEX(N, FCN, X, Y, XEND, H, RTOL, ATOL, ITOL, */
  /*   SOLOUT, IOUT, WORK, LWORK, IWORK, LIWORK, RPAR, IPAR, IDID) */

  vnum = 2; /* Needed to call output at every successful step */
  F77_FUNC (odex, ODEX) (&N, &F77_FUNC (ffcn, FFCN), &SLOT[0],
    INIT, &SLOT[1], &H, RTOL, ATOL, &ITOL, &F77_FUNC (fsol, FSOL),
    &vnum, WORK, &LWORK, IWORK, &LIWORK, &RPAR, &IPAR, &VRET);
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: Solving has been finished, exit status %d\n", VRET);
#endif

  switch (VRET) {   /* Only two possible return values do exist */
    case -1:        /* Computation has not been successful */
      mexPrintf ("Computation has not been successful\n");
      break;
    case 1:  break; /* Computation has been successful */
    default: break;
  }
#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER POSTPROCESSING PROCEDURE\n");
#endif

  /* Handle the OdeOptions structure field: STATS */
  fodepkgvar (2, "Stats", &vtmp);
  if (mxIsLogicalScalarTrue (vtmp)) { 
    /* Print additional information on the screen */
    vnum = IWORK[16]; /* A dopri solver result */
    vtem = mxCreateDoubleScalar ((double) vnum);
    fodepkgvar (1, "vfevals", &vtem);
    mexPrintf ("Number of function calls: %d\n", vnum);

    vnum = IWORK[17]; /* A dopri solver result */
    vtem = mxCreateDoubleScalar ((double) vnum);
    fodepkgvar (1, "vsuccess", &vtem);
    mexPrintf ("Number of used steps:     %d\n", vnum);

    vnum = IWORK[18]; /* A dopri solver result */
    vtem = mxCreateDoubleScalar ((double) vnum);
    fodepkgvar (1, "vaccept", &vtem);
    mexPrintf ("Number of accepted steps: %d\n", vnum);

    vnum = IWORK[19]; /* A dopri solver result */
    vtem = mxCreateDoubleScalar ((double) vnum);
    fodepkgvar (1, "vreject", &vtem);
    mexPrintf ("Number of rejected steps: %d\n", vnum);
  }

  if (nlhs == 1) { /* Handle the PLHS array (1 output argument) */
    vnum = 1;
    plhs[0] = mxCreateStructArray (1, &vnum, 0, NULL);

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
    if (mxIsLogicalScalarTrue (vtmp)) {
      vnum = 1; /* Put additional information into structure */
      vtem = mxCreateStructArray (1, &vnum, 0, NULL);

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
    if (!mxIsEmpty (vtmp)) { 
      /* Put additional information about events into structure */
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

  else if (nlhs == 2) { 
    /* Handle the PLHS array (2 output arguments) */
    fsolstore (2, &vtmp, &vtem);
    plhs[0] = vtmp;
    plhs[1] = mxTransposeMatrix (vtem);
  }

  else if (nlhs == 5) { 
    /* Handle the PLHS array (5 output arguments) */
    fsolstore (2, &vtmp, &vtem);
    plhs[0] = vtmp;
    plhs[1] = mxTransposeMatrix (vtem);

    fodepkgvar (2, "EventFunction", &vtmp);
    if (!mxIsEmpty (vtmp)) {
      fodepkgvar (2, "EventSolution", &vtem);
      plhs[2] = mxDuplicateArray (mxGetCell (vtem, 2));
      plhs[3] = mxDuplicateArray (mxGetCell (vtem, 3));
      plhs[4] = mxDuplicateArray (mxGetCell (vtem, 1));
    }
    else {
      plhs[2] = mxCreateDoubleMatrix (0, 0, mxREAL);
      plhs[3] = mxCreateDoubleMatrix (0, 0, mxREAL);
      plhs[4] = mxCreateDoubleMatrix (0, 0, mxREAL);
    }
  }

#ifdef __ODEPKGDEBUG__
  mexPrintf ("ODEPKGDEBUG: ----- STARTING SOLVER CLEANUP PROCEDURE\n");
#endif

  /* Cleanup all internals of: FODEPKGPLOT */
  fodepkgvar (2, "PlotFunction", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vtmp = mxDuplicateArray (prhs[1]);
    fy2mxArray (N, INIT, &vtem); /* vtem = mxDuplicateArray (prhs[2]); */
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
    vtmp = mxCreateDoubleScalar (SLOT[0]);
    fy2mxArray (N, INIT, &vtem);
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
/*   mxFree (SLOT); */
/*   mxFree (INIT); */
/*   mxFree (RTOL); */
/*   mxFree (ATOL); */
/*   mxDestroyArray (vtmp); */
/*   mxDestroyArray (vtem); */
/* fodepkgvar (9, NULL, NULL); */

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
