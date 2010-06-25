//-------------------------------------------------------------------
//   C-MEX implementation of kth element - this function is part of the NaN-toolbox. 
//
//   usage: x = kth_element(X,k)
//          returns sort(X)(k)
//
//   
//
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; either version 3 of the License, or
//   (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with this program; if not, see <http://www.gnu.org/licenses/>.
//
//
// Input:
// - X  data vector, must be double/real 
//        data might be reorded (partially sorted) in place, and NaN's are removed. 
// - k  which element should be selected
//
// Output:
//      x = sort(X)(k)  
//
//    $Id$
//    Copyright (C) 2010 Alois Schloegl <a.schloegl@ieee.org>
//    This function is part of the NaN-toolbox
//    http://biosig-consulting.com/matlab/NaN/
//
//-------------------------------------------------------------------


#include <inttypes.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"


#ifdef tmwtypes_h
  #if (MX_API_VER<=0x07020000)
    typedef int mwSize;
    typedef int mwIndex;
  #endif 
#endif 


#define SWAP(a,b) {temp = a; a=b; b=temp;} 
 
static void findFirstK(double array[], size_t left, size_t right, size_t k)
{
        while (right > left) {
                mwIndex pivotIndex = (left + right) / 2;

		/* partition */
	        double temp;
	        double pivotValue = array[pivotIndex];
        	SWAP(array[pivotIndex], array[right]);
        	pivotIndex = left;
	        for (mwIndex i = left; i <= right - 1; ++i ) {
        	        if (array[i] <= pivotValue || isnan(pivotValue)) {
        	        	SWAP(array[i], array[pivotIndex]);
        	                ++pivotIndex;
                	}
        	}
        	SWAP(array[pivotIndex], array[right]);

                if (pivotIndex > k)
                	right = pivotIndex - 1;
                else if (pivotIndex < k)
                        left = pivotIndex + 1;
                else break;        
        }
}
 

void mexFunction(int POutputCount,  mxArray* POutput[], int PInputCount, const mxArray *PInputs[]) 
{
    	mwIndex k, n;	// running indices 
    	mwSize  szK, szX; 
    	double 	*Y,*X,*K; 

	// check for proper number of input and output arguments
	if (PInputCount != 2) {
		mexPrintf("KTH_ELEMENT returns the K-th smallest element of vector X\n");
		mexPrintf("\nusage:\tx = kth_element(X,k)\n");
		mexPrintf("\nNote, the elements in X are modified in place. Do not use kth_element directely unless you know what you do. You are warned.\n");
		
	    	mexPrintf("\nsee also: median, quantile\n\n");
	        mexErrMsgTxt("KTH_ELEMENT requires 2 input arguments\n");
	}        
	if (POutputCount > 2)
	        mexErrMsgTxt("KTH_ELEMENT has 1 output arguments.");

	// get 1st argument
	if (mxIsComplex(PInputs[0]))
		mexErrMsgTxt("complex argument not supported (yet). ");
	if (!mxIsDouble(PInputs[0]) || !mxIsDouble(PInputs[1]))
		mexErrMsgTxt("input arguments must be of type double . ");
	// TODO: support of complex, and integer data	
		

	szK = mxGetNumberOfElements(PInputs[1]);
	K = (double*)mxGetData(PInputs[1]);

	szX = mxGetNumberOfElements(PInputs[0]);
	X = (double*)mxGetData(PInputs[0]);

	/*********** create output arguments *****************/

	POutput[0] = mxCreateDoubleMatrix(mxGetM(PInputs[1]),mxGetN(PInputs[1]),mxREAL);
	Y = (double*) mxGetData(POutput[0]);
	for (k=0; k < szK; k++) {
		n = K[k]-1;       // convert to zero-based indexing 
		if (n >= szX || n < 0)
			Y[k] = 0.0/0.0;	// NaN: result undefined
		else {
        		findFirstK(X, 0, szX-1, n);
        		Y[k] = X[n];
		}	
	}

	return; 
}

