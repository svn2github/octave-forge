#include "mex.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
  int i;
  mxArray *v;
  const char *keys[] = { "this", "that" };

  if (nrhs != 1 || !mxIsStruct(prhs[0]))
    mexErrMsgTxt("expects struct");
  for (i=0; i < mxGetNumberOfFields(prhs[0]); i++) {
    mexPrintf("field %s has value:\n", mxGetFieldNameByNumber(prhs[0],i));
    v = mxGetFieldByNumber(prhs[0],0,i);
    mexCallMATLAB(0, (mxArray**)0, 1, &v, "disp");
  }

  v = mxCreateStructMatrix(1,1,2,keys);
  mxSetFieldByNumber(v,0,0,mxCreateString("this"));
  mxSetFieldByNumber(v,0,1,mxCreateString("that"));
  if (nlhs) plhs[0] = v;
}
