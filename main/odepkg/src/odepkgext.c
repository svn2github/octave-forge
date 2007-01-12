#include <mex.h>
#include "odepkgext.h"
#include <string.h>

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
