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

#include <mex.h>
#include "odepkgmex.h"

void mexFixMsgTxt (const char *vfix) {
  mexPrintf ("FIXME: %s\n", vfix);
}

void mexUsgMsgTxt (const char *vusg) {
  mexPrintf ("usage: %s\n", vusg);
  mexErrMsgTxt ("");
}

bool mxIsEqual (const mxArray *vone, const mxArray *vtwo) {
  bool vret = false;

  mxArray **vlhs = NULL;
  mxArray **vrhs = NULL;

  vlhs = (mxArray **) mxMalloc (sizeof (mxArray *));
  vrhs = (mxArray **) mxMalloc (2 * sizeof (mxArray *));
  vrhs[0] = mxDuplicateArray (vone);
  vrhs[1] = mxDuplicateArray (vtwo);

  if (mexCallMATLAB (1, vlhs, 2, vrhs, "isequal"))
    mexErrMsgTxt ("Calling \"isequal\" has failed");
  if (mxIsLogicalScalarTrue (vlhs[0])) vret = true;

  mxFree (vlhs);
  mxFree (vrhs);
  return (vret);
}

bool mxIsColumnVector (const mxArray *vinp) {
  if (mxIsNumeric (vinp)) {
    if (mxGetN (vinp) == 1 && mxGetM (vinp) > 1)
      return (true);
  }
  return (false);
}

bool mxIsRowVector (const mxArray *vinp) {
  if (mxIsNumeric (vinp)) {
    if (mxGetM (vinp) == 1 && mxGetN (vinp) > 1) 
      return (true);
  }
  return (false);
}

bool mxIsVector (const mxArray *vinp) {
  if (mxIsNumeric (vinp)) {
    if ( (mxGetM (vinp) == 1 && mxGetN (vinp) > 1) ||
         (mxGetN (vinp) == 1 && mxGetM (vinp) > 1) )
      return (true);
  }
  return (false);
}
