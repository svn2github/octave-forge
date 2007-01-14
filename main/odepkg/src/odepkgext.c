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

#include <stdio.h>
#include <mex.h>
#include "odepkgmex.h"
#include "odepkgext.h"

extern todefunction vplotfunction;
extern todefunction vodefunction;

bool fplotfunction (mxArray *vtime, mxArray *vvalues, mxArray *vflag, mxArray *voptions) {
  int  vcnt = 0;
  bool vret = false;
  char vmsg[64] = "";

  int     voutputseln = 0;
  double *voutputsels = NULL;
  double *voutputplot = NULL;
  double *vinputvals  = NULL;

  mxArray *vselect = NULL;
  mxArray *vreturn = NULL;

  const mxArray *cinit = mxCreateString ("init");
  const mxArray *ccalc = mxCreateString ("");
  const mxArray *cdone = mxCreateString ("done");

/* #ifdef __ODEPKGDEBUG__ */
/*   mexPrintf ("ODEPKGDEBUG: time=%7.5f  val[0]= %7.5f  flag=%s  sel[0]=%d\n",  */
/*              *mxGetPr (vtime), *mxGetPr (vvalues),  */
/*              mxArrayToString (vflag), (int) *mxGetPr (vselect)); */
/* #endif */

  if (mxIsEqual (vflag, cinit)) {
    vplotfunction.funargn = 3 + vodefunction.funargn;
    vplotfunction.funargs = (mxArray **) mxMalloc (vplotfunction.funargn * sizeof (mxArray *));
  }

  /* Set the vplotfunction.funargs[0] element */
  vplotfunction.funargs[0] = vtime;

  /* Set the vplotfunction.funargs[1] element */
  vselect = mxGetField (voptions, 0, "OutputSel");
  if (mxIsEmpty (vselect)) /* All results are needed */
    vplotfunction.funargs[1] = vvalues; /* mxDuplicateArray (vvalues) */

  else { /* OutputSel is not empty, only some results are needed */
    voutputsels = mxGetPr (vselect);
    voutputseln = mxGetNumberOfElements (vselect);

    /* vplotfunction.funargs[1] must be a column vector */
    vplotfunction.funargs[1] = mxCreateDoubleMatrix (voutputseln, 1, mxREAL);
    voutputplot = mxGetPr (vplotfunction.funargs[1]);
    vinputvals  = mxGetPr (vvalues);

    if (voutputseln != 0)
      for (vcnt = 0; vcnt < voutputseln; vcnt++) {
        if (voutputseln < ((int)(voutputsels[vcnt]))) { /* Check if valid */
          sprintf (vmsg, "No valid number element \"%d\" in option \"OutputSel\"", 
            ((int)(voutputsels[vcnt]))); mexErrMsgTxt (vmsg); }
        else voutputplot[vcnt] = vinputvals[((int)(voutputsels[vcnt]))-1];
      }
  }

  /* Set the vplotfunction.funargs[2] element */
  vplotfunction.funargs[2] = vflag;

  /* Fill up vplotfunction.funargs[3..] if vflag == "init" */
  if (mxIsEqual (vflag, cinit))
    if (vodefunction.funargn > 0)
      for (vcnt = 0; vcnt < vodefunction.funargn; vcnt++)
        vplotfunction.funargs[vcnt+3] = vodefunction.funargs[vcnt];

  /* Eval the output function */
  if (mxIsEqual (vflag, ccalc)) {
    vreturn = mxCreateLogicalScalar (false);
    if (mexCallMATLAB (1, &vreturn, vplotfunction.funargn, vplotfunction.funargs, 
                       vplotfunction.funstring)) {
      sprintf (vmsg, "Calling \"%s\" has failed", vplotfunction.funstring);
      mexErrMsgTxt (vmsg);
    }
    vret = mxIsLogicalScalarTrue (vreturn);
    /* mxDestroyArray (vreturn); Needed or not needed? */
  }
  else if (mexCallMATLAB (0, NULL, vplotfunction.funargn, vplotfunction.funargs, 
                          vplotfunction.funstring)) {
    sprintf (vmsg, "Calling \"%s\" has failed", vplotfunction.funstring);
    mexErrMsgTxt (vmsg);
  }

  if (mxIsEqual (vflag, cdone)) mxFree (vplotfunction.funargs);
  /* mxDestroyArray (&cinit); Needed or not needed? */
  /* mxDestroyArray (&ccalc); Needed or not needed? */
  /* mxDestroyArray (&cdone); Needed or not needed? */

  return (vret);
}
