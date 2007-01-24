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

#include <mex.h>       /* Needed for all mex definitions */
#include "odepkgmex.h" /* Needed for the mex extensions */

/**
 * mexFixMsgTxt - Prints a fixme message
 * @vmsg: The string that has to be displayed
 *
 * Displays the string @vmsg in the octave window as "FIXME: ..."
 **/
void mexFixMsgTxt (const char *vmsg) {
  mexPrintf ("FIXME: %s\n", vmsg);
}

/**
 * mexUsgMsgTxt - Prints a usage message
 * @vmsg: The string that has to be displayed
 *
 * Displays the string @vmsg in the octave window as "usage: ..."
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
 * mxIsColumnVector - Checks for column vector
 * @vmat: The numerical mxArray
 *
 * Returns a boolean value that is either %true if @vmat is a column
 * vector or %false if @vmat is no column vector.
 *
 * Return value: The constant %true or %false.
 **/
bool mxIsColumnVector (const mxArray *vmat) {
  if (mxIsNumeric (vmat)) {
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
  if (mxIsNumeric (vmat)) {
    if (mxGetM (vmat) == 1 && mxGetN (vmat) > 1)
      return (true);
  }
  return (false);
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
  if (mxIsNumeric (vmat)) {
    if ( (mxGetM (vmat) == 1 && mxGetN (vmat) > 1) ||
         (mxGetN (vmat) == 1 && mxGetM (vmat) > 1) )
      return (true);
  }
  return (false);
}

mxArray *mxGetMatrixRow (mxArray *vmat, unsigned int vind) {
  bool vbool = false;
  unsigned int vcnt = 0;
  unsigned int vrow = 0;
  unsigned int vcol = 0;

  double  *vdbl = NULL;
  double  *vdob = NULL;
  mxArray *vret = NULL;

  if (mxIsSparse (vmat))
    mexFixMsgTxt ("mxGetMatrixRow: No vector given back, sparse matrix found");

  if (mxIsNumeric (vmat)) {
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
    mexErrMsgTxt ("mxGetMatrixRow: Numerical matrix expected");

  return (vret);
}

mxArray *mxGetMatrixColumn (mxArray *vmat, unsigned int vind) {
  vmat = NULL;
  vind = 0;
}

/**
 * mxTransposeMatrix - Transpose matrix
 * @vmat: The numerical mxArray
 *
 * Returns a newly allocated numerical mxArray matrix that is the
 * transposed matrix of @vmat.
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

  if (!mxIsNumeric (vmat))       /* Check if input argument is numeric */
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
    mexFixMsgTxt ("mxTransposeMatrix: Returning a matrix that is not transposed");
    vret = vmat;
  }

  return (vret);
}
