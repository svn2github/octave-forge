//-------------------------------------------------------------------
#pragma hdrstop
//-------------------------------------------------------------------
// sumskipnan2: sums all non-NaN values
//
// Input:
// - array to sum
// - dimension to sum (1=columns; 2=rows; doesn't work for dim>2!!)
//
// Output:
// - sums
// - count of valid elements (optional)
// - sums of squares (optional)
// - sums of squares of squares (optional)
//
// Author:  Patrick Houweling (phouweling@yahoo.com)
// Version: 1.0
// Date:    17 september 2003
//
//
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; either version 2 of the License, or
//   (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with this program; if not, write to the Free Software
//   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//
//-------------------------------------------------------------------
#include <stdlib>
#include "mex.h"
//-------------------------------------------------------------------
void mexFunction(int POutputCount,  mxArray* POutput[], int PInputCount, const mxArray *PInputs[])
{
    int     M, N, m, n;
    int     i, j;
    int     LDimension;
    double* LInput;
    double* LOutputSum;
    double* LOutputCount;
    double* LOutputSum2;
    double* LOutputSum4;
    double  x, x2;
    int     LCount;
    double  LSum, LSum2, LSum4;

    // check for proper number of input and output arguments
    if ((PInputCount <= 0) || (PInputCount > 2))
        mexErrMsgTxt("SumSkipNan2 requires 1 or 2 arguments.");
    if (POutputCount > 5)
        mexErrMsgTxt("SumSkipNan2 has 1 to 4 output arguments.");

    // get 1st argument
    if(!mxIsNumeric(PInputs[0]))
        mexErrMsgTxt("First argument must be numeric.");
    M = mxGetM(PInputs[0]);
    N = mxGetN(PInputs[0]);
    LInput = mxGetPr(PInputs[0]);

    // get 2nd argument
    if  (PInputCount == 2){
        if ((!mxIsNumeric(PInputs[1])) || (mxGetM(PInputs[1]) != 1) || (mxGetN(PInputs[1]) != 1))
            mexErrMsgTxt("Second argument must be scalar.");
        LDimension = mxGetScalar(PInputs[1]);
        if ((LDimension < 0) || (LDimension > 2))
            mexErrMsgTxt("Only dimensions 1 and 2 are supported.");
    }
    else
        LDimension = 1;

    // create outputs
    if (LDimension == 1){
        m = 1;
        n = N;
    }
    if (LDimension == 2){
        m = M;
        n = 1;
    }
    POutput[0]   = mxCreateDoubleMatrix(m, n, mxREAL);
    LOutputSum   = mxGetPr(POutput[0]);
    if (POutputCount >= 2){
        POutput[1]   = mxCreateDoubleMatrix(m, n, mxREAL);
        LOutputCount = mxGetPr(POutput[1]);
    }
    if (POutputCount >= 3){
        POutput[2]   = mxCreateDoubleMatrix(m, n, mxREAL);
        LOutputSum2  = mxGetPr(POutput[2]);
    }
    if (POutputCount >= 4){
        POutput[3]   = mxCreateDoubleMatrix(m, n, mxREAL);
        LOutputSum4  = mxGetPr(POutput[3]);
    }

    if (LDimension == 1){
        // sum all non-NaN elements of each column
        for (j=0; j<N; j++){
            // init
            LCount = 0;
            LSum   = 0;
            LSum2  = 0;
            LSum4  = 0;

            for (i=0; i<M; i++){
                x = LInput[i + j*M];
                if (!mxIsNaN(x)){
                    LCount++;
                    LSum += x;
                    x2 = x*x;
                    LSum2 += x2;
                    LSum4 += x2*x2;
                }
            }
            LOutputSum[j] = LSum;
            if (POutputCount >= 2)
                LOutputCount[j] = LCount;
            if (POutputCount >= 3)
                LOutputSum2[j] = LSum2;
            if (POutputCount >= 4)
                LOutputSum4[j] = LSum4;
        }
    }
    if (LDimension == 2){
        // sum all non-NaN elements of each row
        for (i=0; i<M; i++){
            // init
            LCount = 0;
            LSum   = 0;
            LSum2  = 0;
            LSum4  = 0;

            for (j=0; j<N; j++){
                x = LInput[i + j*M];
                if (!mxIsNaN(x)){
                    LCount++;
                    LSum += x;
                    x2 = x*x;
                    LSum2 += x2;
                    LSum4 += x2*x2;
                }
            }
            LOutputSum[i] = LSum;
            if (POutputCount >= 2)
                LOutputCount[i] = LCount;
            if (POutputCount >= 3)
                LOutputSum2[i] = LSum2;
            if (POutputCount >= 4)
                LOutputSum4[i] = LSum4;
        }
    }
}
