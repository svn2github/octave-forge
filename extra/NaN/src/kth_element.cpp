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


/*
   http://en.wikipedia.org/wiki/Selection_algorithm
 */
static size_t partition(double array[], size_t left, size_t right, size_t pivotIndex)
{
        double temp;
        double pivotValue = array[pivotIndex];
        array[pivotIndex] = array[right];
        array[right] = pivotValue;
        size_t storeIndex = left;
        for (size_t i = left; i <= right - 1; ++i ) {
                if (array[i] <= pivotValue) {
                        temp = array[i];
                        array[i] = array[storeIndex];
                        array[storeIndex] = temp;
                        ++storeIndex;
                }
        }
        temp = array[storeIndex];
        array[storeIndex] = array[right];
        array[right] = temp;
        return storeIndex;
}

 
static void findFirstK(double array[], size_t left, size_t right, size_t k)
{
        size_t pivotNewIndex = 0;
        if (right > left) {
                size_t pivotIndex = (left + right) / 2;
                pivotNewIndex = partition(array, left, right, pivotIndex);
                if (pivotNewIndex > k)
                        findFirstK(array, left, pivotNewIndex - 1, k);
                else if (pivotNewIndex < k)
                        findFirstK(array, pivotNewIndex + 1, right, k);
        }
}
 

void mexFunction(int POutputCount,  mxArray* POutput[], int PInputCount, const mxArray *PInputs[]) 
{
    	mwIndex j, k, n;	// running indices 
    	mwSize  szK, szX; 
    	double 	*Y,*X,*K; 

	// check for proper number of input and output arguments
	if (PInputCount != 2) {
		mexPrintf("KTH_ELEMENT returns the K-th smallest element of vector X\n\n");
		mexPrintf("usage:\tx = kth_element(X,k)\n");
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

	for (j=0, k=0; k<szX; k++) {
		if (j<k) X[j] = X[k];
		if (!mxIsNaN(X[k])) j++;
	}
	for ( k=j; k<szX; k++) X[k] = 0.0/0.0; // needed when X contains NaN's and kth_element is called several times on the same data.  

	/*********** create output arguments *****************/

	POutput[0] = mxCreateDoubleMatrix(mxGetM(PInputs[1]),mxGetN(PInputs[1]),mxREAL);
	Y = (double*) mxGetData(POutput[0]);
	for (k=0; k < szK; k++) {
		n = K[k]-1;       // convert to zero-based indexing 
		if (n >= j || n < 0)
			Y[k] = 0.0/0.0;
		else {
        		findFirstK(X, 0, j-1, n);
        		Y[k] = X[n];
		}	
	}

	return; 
}

