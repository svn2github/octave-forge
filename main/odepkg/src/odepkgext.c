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
  #include "config.h"  /* Needed for GCC_ATTR_UNUSED if compiled with mkoctfile */
#endif

#include <mex.h>       /* Needed for all mex definitions */
#include <string.h>    /* Needed for the strcmp function */
#include <stdio.h>     /* Needed for the sprintf function */
#include "odepkgext.h"
#include "odepkgmex.h"

bool fodepkgvar (const unsigned int vtodo, const char *vname, mxArray **vvalue) {
  int  cone = 1;
  bool vret = false;
  int  vnmb = 0;

  static mxArray *vodesetvar = NULL;

  switch (vtodo) {
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

    case 9:  /* Disp the whole structure (for debugging purpose) */
      mexCallMATLAB (0, NULL, 1, &vodesetvar, "disp");
      vret = true;
      break;

    default: /* Nothing has to done, get out of here */
      break;
    }
  return (vret);
}

bool fsolstore (unsigned int vz, mxArray **vt, mxArray **vy) {
  bool vret = false;
  static int vdim = 0;
  static int vcnt = 0;
  static double *vtstore = NULL;
  static double *vystore = NULL;

  switch (vz) {
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
      break;

    case 4:
      mxFree (vtstore);
      mxFree (vystore);
      vret = true; break;

    default:
      break;
  }

  return (vret);
}

bool fy2mxArray (unsigned int n, double *y, mxArray **vval) {
  int      vnum = 0;
  int      vcnt = 0;
  double  *vdbl = NULL;
  double  *vdob = NULL;
  mxArray *vtmp = NULL;

  fodepkgvar (2, "outputsel", &vtmp);
  if (!mxIsEmpty (vtmp)) {
    vnum = mxGetNumberOfElements (vtmp);
    vdob = mxGetPr (vtmp);    /* vdob = outputsel[0] */

    vval[0] = mxCreateDoubleMatrix (vnum, 1, mxREAL);
    vdbl = mxGetPr (vval[0]); /* vdbl = vval[0] */

    for (vcnt = 0; vcnt < vnum; vcnt++)
      vdbl[vcnt] = y[((int)(vdob[vcnt]))-1];
  }
  else {
    vval[0] = mxCreateDoubleMatrix (n, 1, mxREAL);
    memcpy ((void *) mxGetPr (vval[0]), (void *) y, n * sizeof (double));
  }

  return (true);
}

bool fodepkgplot (mxArray *vtime, mxArray *vvalues, mxArray *vflag) {
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
  if (!mxIsEmpty (vflag)) vrhs[2] = vflag;
  else vrhs[2] = mxCreateString ("");

  /* Set the vrhs[3..] element for the plotting function */
  fodepkgvar (2, "varargin", &vtmp);
  if (velm > 0) /* Fill up vrhs[3..] */
    for (vcnt = 0; vcnt < velm; vcnt++)
      vrhs[3+vcnt] = mxGetCell (vtmp, vcnt);

  /* Call the plotting function */
  fodepkgvar (2, "plotfun", &vtmp);
  if (strcmp (mxArrayToString (vflag), "init") ||
      strcmp (mxArrayToString (vflag), "done")) {
    if (mexCallMATLAB (0, NULL, 3+velm, vrhs, mxArrayToString (vtmp))) {
      sprintf (vmsg, "Calling \"%s\" has failed", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
    vret = true;
  }
  else {
    if (mexCallMATLAB (1, vlhs, 3+velm, vrhs, mxArrayToString (vtmp))) {
      sprintf (vmsg, "Calling \"%s\" has failed", mxArrayToString (vtmp));
      mexErrMsgTxt (vmsg);
    }
    if (!mxIsLogicalScalarTrue (vlhs[0])) vret = true;
    else vret = false;
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
