#include <mex.h>
#include "odepkgext.h"

void mexFixMsgTxt (const char *vfix) {
  mexPrintf ("FIXME: %s\n", vfix);
}

void mexUsgMsgTxt (const char *vusg) {
  mexPrintf ("usage: %s\n", vusg);
  mexErrMsgTxt ("");
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
