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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#include <mex.h>       /* Needed for all mex definitions */
#include "odepkgmex.h" /* Needed for the mex extensions */

/**
 * mexFixMsgTxt - Prints a fixme message
 * @vmsg: The string that has to be displayed
 *
 * Displays the string @vmsg in the octave window as "FIXME: ..." and
 * continues.
 **/
void mexFixMsgTxt (const char *vmsg) {
  mexPrintf ("FIXME: %s\n", vmsg);
}

/**
 * mexUsgMsgTxt - Prints a usage message
 * @vmsg: The string that has to be displayed
 *
 * Displays the string @vmsg in the octave window as "usage: ..." and
 * stops computation because of an empty error message.
 **/
void mexUsgMsgTxt (const char *vmsg) {
  mexPrintf ("usage: %s\n", vmsg);
  mexErrMsgTxt ("");
}

/**
 * mxIsEqual - Compares two mxArrays
 * @vone: The first mxArray variable
 * @vtwo: The second mxArray variable
 *
 * Compares the two mxArrays @vone and @vtwo and returns a boolean
 * value that is either %true if both mxArrays are the same or %false
 * if the two mxArrays are different.
 *
 * Return value: The constant %true or %false.
 **/
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

/**
 * mxIsVector - Checks for vector
 * @vmat: The numerical mxArray
 *
 * Returns a boolean value that is either %true if @vmat is a vector
 * or %false if @vmat is no vector.
 *
 * Return value: The constant %true or %false.
 **/
bool mxIsVector (const mxArray *vmat) {
  if (mxIsMatrix (vmat)) {
    if ( (mxGetM (vmat) == 1 && mxGetN (vmat) > 1) ||
         (mxGetN (vmat) == 1 && mxGetM (vmat) > 1) )
      return (true);
  }
  return (false);
}

/**
 * mxIsColumnVector - Checks for column vector
 * @vmat: The numerical mxArray
 *
 * Returns a boolean value that is either %true if @vmat is a column
 * vector or %false if @vmat is no column vector.
 *
 * Return value: The constant %true or %false.
 **/
bool mxIsColumnVector (const mxArray *vmat) {
  if (mxIsVector (vmat)) {
    if (mxGetN (vmat) == 1 && mxGetM (vmat) > 1)
      return (true);
  }
  return (false);
}

/**
 * mxIsRowVector - Checks for row vector
 * @vmat: The numerical mxArray
 *
 * Returns a boolean value that is either %true if @vmat is a row
 * vector or %false if @vmat is no row vector.
 *
 * Return value: The constant %true or %false.
 **/
bool mxIsRowVector (const mxArray *vmat) {
  if (mxIsVector (vmat)) {
    if (mxGetM (vmat) == 1 && mxGetN (vmat) > 1)
      return (true);
  }
  return (false);
}

/**
 * mxIsRowVector - Checks for matrix
 * @vmat: The numerical mxArray
 *
 * Returns a boolean value that is either %true if @vmat is a
 * numerical matrix or %false if @vmat is no matrix.
 *
 * Return value: The constant %true or %false.
 **/
bool mxIsMatrix (const mxArray *vmat) {
  if (mxIsNumeric (vmat)) {
    if (mxGetNumberOfElements (vmat) > 1)
      /* if (mxGetM (vmat) >= 1 && mxGetN (vmat) >= 1) */
      return (true);
  }
  return (false);
}

/**
 * mxGetMatrixRow - Returns one row from a matrix or vector
 * @vmat: The numerical mxArray
 *
 * Returns a newly allocated numerical mxArray with one row of
 * elements from the matrix or vector @vmat.
 *
 * Return value: An newly allocated mxArray.
 **/
mxArray *mxGetMatrixRow (mxArray *vmat, unsigned int vind) {
  bool vbool = false;
  unsigned int vcnt = 0;
  unsigned int vrow = 0;
  unsigned int vcol = 0;

  double  *vdbl = NULL;
  double  *vdob = NULL;
  mxArray *vret = NULL;

  if (mxIsSparse (vmat))
    mexFixMsgTxt ("mxGetMatrixRow: No vector is given back, sparse matrix found");

  if (mxIsVector (vmat) || mxIsMatrix (vmat)) {
    vbool = mxIsComplex (vmat);
    vdbl  = mxGetPr (vmat);
    vrow  = mxGetM (vmat);
    vcol  = mxGetN (vmat);

    if (!vbool)
      vret = mxCreateDoubleMatrix (1, vcol, mxREAL);
    else /* Found a complex matrix... */
      vret = mxCreateDoubleMatrix (1, vcol, mxCOMPLEX);

    vdob = mxGetPr (vret);

    if (vind > (vrow-1))
      mexErrMsgTxt ("mxGetMatrixRow: Index exceeds matrix dimension");
    else {
      for (vcnt = 0; vcnt < vcol; vcnt++) vdob[vcnt] = vdbl[vind+vcnt*vrow];
      if (vbool) { /* If we have a complex matrix... */
        vdbl = mxGetPi (vmat);
        vdob = mxGetPi (vret);
        for (vcnt = 0; vcnt < vcol; vcnt++) vdob[vcnt] = vdbl[vind+vcnt*vrow];
      }
    }
  }

  else
    mexErrMsgTxt ("mxGetMatrixRow: Numerical mxArray matrix or vector expected");

  return (vret);
}

/**
 * mxGetMatrixColumn - Returns one column from a matrix or vector
 * @vmat: The numerical mxArray
 *
 * Returns a newly allocated numerical mxArray with one column of
 * elements from the matrix or vector @vmat.
 *
 * Return value: An newly allocated mxArray.
 **/
mxArray *mxGetMatrixColumn (mxArray *vmat, unsigned int vind) {
  bool vbool = false;
  unsigned int vcnt = 0;
  unsigned int vrow = 0;
  unsigned int vcol = 0;

  double  *vdbl = NULL;
  double  *vdob = NULL;
  mxArray *vret = NULL;

  if (mxIsSparse (vmat))
    mexFixMsgTxt ("mxGetMatrixRow: No vector is given back, sparse matrix found");

  if (mxIsVector (vmat) || mxIsMatrix (vmat)) {
    vbool = mxIsComplex (vmat);
    vdbl  = mxGetPr (vmat);
    vrow  = mxGetM (vmat);
    vcol  = mxGetN (vmat);

    if (!vbool)
      vret = mxCreateDoubleMatrix (vrow, 1, mxREAL);
    else /* Found a complex matrix... */
      vret = mxCreateDoubleMatrix (vrow, 1, mxCOMPLEX);

    vdob = mxGetPr (vret);
    /* mexPrintf ("%f %f %f %f %f %f %f %f %f %f %f %f \n", */
    /*   vdbl[0], vdbl[1], vdbl[2], vdbl[3], */
    /*   vdbl[4], vdbl[5], vdbl[6], vdbl[7], */
    /*   vdbl[8], vdbl[9], vdbl[10], vdbl[11]); */
    if (vind > (vcol-1))
      mexErrMsgTxt ("mxGetMatrixColumn: Index exceeds matrix dimension");
    else {
      for (vcnt = 0; vcnt < vrow; vcnt++) vdob[vcnt] = vdbl[vcnt+vind*vrow];
      if (vbool) { /* If we have a complex matrix... */
        vdbl = mxGetPi (vmat);
        vdob = mxGetPi (vret);
        for (vcnt = 0; vcnt < vrow; vcnt++) vdob[vcnt] = vdbl[vcnt+vind*vrow];
      }
    }
  }

  else
    mexErrMsgTxt ("mxGetMatrixColumn: Numerical mxArray matrix or vector expected");

  return (vret);
}

/**
 * mxTransposeMatrix - Transpose matrix
 * @vmat: The numerical mxArray
 *
 * Returns a newly allocated numerical mxArray matrix that is the
 * non-conjugate transposed matrix of @vmat.
 *
 * Return value: An newly allocated mxArray.
 **/
mxArray *mxTransposeMatrix (mxArray *vmat) {
  bool vbool = false;
  int  vrows = 0;
  int  vcols = 0;
  int  vcntR = 0;
  int  vcntC = 0;

  double  *vdob = NULL;
  double  *vdbl = NULL;
  mxArray *vret = NULL;

  if (!mxIsMatrix (vmat))       /* Check if input argument is numeric */
    mexErrMsgTxt ("Input argument of mxTransposeMatrix must be valid matrix");

  else if (!mxIsSparse (vmat)) { /* Check if input argument is a sparse matrix */
    vrows = mxGetM (vmat);
    vcols = mxGetN (vmat);
    vbool = mxIsComplex (vmat);

    if (!vbool)                  /* Check if input argument is a complex matrix */
      vret = mxCreateDoubleMatrix (vcols, vrows, mxREAL);
    else
      vret = mxCreateDoubleMatrix (vcols, vrows, mxCOMPLEX);

    vdob = mxGetPr (vmat);
    vdbl = mxGetPr (vret);
    for (vcntR = 0; vcntR < vrows; vcntR++)
      for (vcntC = 0; vcntC < vcols; vcntC++)
          vdbl[(vcntR*vcols)+vcntC] = vdob[(vcntC*vrows)+vcntR];

    if (vbool) {                 /* On complex matrix also transpose imaginary part */
      vdob = mxGetPi (vmat);
      vdbl = mxGetPi (vret);
      for (vcntR = 0; vcntR < vrows; vcntR++)
        for (vcntC = 0; vcntC < vcols; vcntC++)
          vdbl[(vcntR*vcols)+vcntC] = vdob[(vcntC*vrows)+vcntR];
    }
  }

  else {                         /* Input argument is a sparse matrix, no implementation */
    mexFixMsgTxt ("mxTransposeMatrix: No implementation to transpose a sparse matrix");
    mexFixMsgTxt ("mxTransposeMatrix: Returning the input matrix that is not transposed");
    vret = vmat;
  }

  return (vret);
}

/* Developer function for a fast trial and error implementation of a
   test procedure, this is a comment region by default.
   Developers normally do something like this: mex -v odepkgmex.c
*/
/* void mexFunction (int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
  mxArray *vtmp = mxDuplicateArray (prhs[0]);
  plhs[0] = mxCreateLogicalScalar (mxIsVector (vtmp));
  plhs[1] = mxCreateLogicalScalar (mxIsRowVector (vtmp));
  plhs[2] = mxCreateLogicalScalar (mxIsColumnVector (vtmp));
  plhs[0] = mxGetMatrixRow (vtmp, 1);
  plhs[1] = mxGetMatrixColumn (vtem, 1);
  plhs[0] = mxTransposeMatrix (vtmp);
} */

/*
Local Variables: ***
mode: C ***
End: ***
*/
