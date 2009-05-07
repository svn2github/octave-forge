//-------------------------------------------------------------------
#pragma hdrstop
//-------------------------------------------------------------------
//   C-MEX implementation of COVM - this function is part of the NaN-toolbox. 
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
// sumskipnan: sums all non-NaN values
//
// Input:
// - X
// - Y [optional]
// - flag (is actually an output argument telling whether some NaN was observed)
// - weight vector to compute weighted correlation 
//
// Output:
// - crosscorrelation
// - count of valid elements (optional)
//
//
//    $Id$
//    Copyright (C) 2009 Alois Schloegl <a.schloegl@ieee.org>
//    This function is part of the NaN-toolbox
//    http://hci.tugraz.at/~schloegl/matlab/NaN/
//
//-------------------------------------------------------------------

#include <inttypes.h>
#include <math.h>
#include "mex.h"

//#define NO_FLAG

void mexFunction(int POutputCount,  mxArray* POutput[], int PInputCount, const mxArray *PInputs[]) 
{
    	const mwSize	*SZ;	    
    	double 		*X0,*Y0,*X,*Y,*W=NULL;
    	double	 	*CC;
    	double 		*NN;
    	double* 	LOutputSum2;
    	double  	x;
    	//unsigned long   LCount;

    	mwSize		rX,cX,rY,cY,nW=0;
    	mwSize    	i,j,k,l;	// running indices 
	char	 	flag_isNaN = 0;

	// check for proper number of input and output arguments
	if ((PInputCount <= 0) || (PInputCount > 4))
	        mexErrMsgTxt("covm.MEX requires between 1 and 4 arguments.");
	if (POutputCount > 2)
	        mexErrMsgTxt("covm.MEX has 1 to 2 output arguments.");

/*	TODO:
	support for complex matrices 
*/


	// get 1st argument
	if(mxIsDouble(PInputs[0]) && !mxIsComplex(PInputs[0]))
		X0  = mxGetPr(PInputs[0]);
	else 	
		mexErrMsgTxt("First argument must be REAL/DOUBLE.");
	rX = mxGetM(PInputs[0]);		
	cX = mxGetN(PInputs[0]);		
		
	// get 2nd argument
       	if  (PInputCount > 1)	{
		if (!mxGetNumberOfElements(PInputs[1]))
			Y0 = NULL; 		

		else if (mxIsDouble(PInputs[1]) && !mxIsComplex(PInputs[1]))
			Y0  = mxGetPr(PInputs[1]);
			
		else 	
			mexErrMsgTxt("Second argument must be REAL/DOUBLE.");
	}
	else 
		Y0 = NULL; 
	

    	// get weight vector for weighted sumskipnan 
       	if  (PInputCount > 3)	{
		// get 4th argument
		nW = mxGetNumberOfElements(PInputs[3]);		
		if (!nW) 
			; 
		else if (nW == rX) 	
			W  = mxGetPr(PInputs[3]);
		else 	
			mexErrMsgTxt("number of elements in W must match numbers of rows in X");

	}

	if (!Y0) {
		Y0 = X0; 
		rY = rX;
		cY = cX; 		
	}
	else {
		rY = mxGetM(PInputs[1]);		
		cY = mxGetN(PInputs[1]);		
	}
	if (rX != rY)
		mexErrMsgTxt("number of rows in X and Y do not match");

	    // create outputs

	POutput[0] = mxCreateDoubleMatrix(cX, cY, mxREAL);
	CC = mxGetPr(POutput[0]);

    	if (POutputCount > 1) {
		POutput[1] = mxCreateDoubleMatrix(cX, cY, mxREAL);
		NN = mxGetPr(POutput[1]);
    	}

#if 0
	/*	this solution is slower than the alternative solution below 
		for transposed matrices, this might be faster. 
	*/	
	for (k=0; k<rX; k++) {
		double w;
		if (W) w = W[k];
		else   w = 1.0;
		for (i=0; i<cX; i++) {
			double x = X0[k+i*rX];
			if (isnan(x)) {
#ifndef NO_FLAG
				flag_isNaN = 1;
#endif 
				continue;
			}
			for (j=0; j<cY; j++) {
				double y = Y0[k+j*rY];
				if (isnan(y)) {
#ifndef NO_FLAG
					flag_isNaN = 1;
#endif 
					continue;
				}
				CC[i+j*cX] += x*y*w; 
	    			if (POutputCount > 1) 
					NN[i+j*cX] += w; 
			}
		}
	}
	
#else 
	// this version is faster than the one above. 
	if (W) /* weighted version */
	for (i=0; i<cX; i++)
	for (j=0; j<cY; j++) {
		X = X0+i*rX;
		Y = Y0+j*rY;
		register double cc=0.0;
		register double nn=0.0;
		for (k=0; k<rX; k++) {
			double x = X[k];
			double y = Y[k];

			if (!isnan(x) && !isnan(y)) 
			{
				cc += x*y*W[k];
				nn += W[k];
			}
#ifndef NO_FLAG
			else 
				flag_isNaN = 1; 
#endif 
		}	
		CC[i+j*cX] = cc; 
	    	if (POutputCount > 1) 
			NN[i+j*cX] = nn; 
	}
	else /* no weights, all weights are 1 */
	for (i=0; i<cX; i++)
	for (j=0; j<cY; j++) {
		X = X0+i*rX;
		Y = Y0+j*rY;
		register double cc=0.0;
		register mwSize nn=0.0;
		for (k=0; k<rX; k++) {
			double x = X[k];
			double y = Y[k];
			
			if (!isnan(x) && !isnan(y)) 
			{
				cc += x*y;
				nn++;
			}
#ifndef NO_FLAG
			else 
				flag_isNaN = 1; 
#endif 
		}	
		CC[i+j*cX] = cc; 
	    	if (POutputCount > 1) 
			NN[i+j*cX] = (double)nn; 
	}
	

#ifndef NO_FLAG
	//mexPrintf("Third argument must be not empty - otherwise status whether a NaN occured or not cannot be returned.");
	/* this is a hack, the third input argument is used to return whether a NaN occured or not. 
		this requires that the input argument is a non-empty variable
	*/	
	if  (flag_isNaN && (PInputCount > 2) && mxGetNumberOfElements(PInputs[2])) {
    		// set FLAG_NANS_OCCURED 
    		switch (mxGetClassID(PInputs[2])) {
    		case mxLOGICAL_CLASS:
    		case mxCHAR_CLASS:
    		case mxINT8_CLASS:
    		case mxUINT8_CLASS:
    			*(uint8_t*)mxGetData(PInputs[2]) = 1;
    			break; 
    		case mxDOUBLE_CLASS:
    			*(double*)mxGetData(PInputs[2]) = 1.0;
    			break; 
    		case mxSINGLE_CLASS:
    			*(float*)mxGetData(PInputs[2]) = 1.0;
    			break; 
    		case mxINT16_CLASS:
    		case mxUINT16_CLASS:
    			*(uint16_t*)mxGetData(PInputs[2]) = 1;
    			break; 
    		case mxINT32_CLASS:
    		case mxUINT32_CLASS:
    			*(uint32_t*)mxGetData(PInputs[2])= 1;
    			break; 
    		case mxINT64_CLASS:
    		case mxUINT64_CLASS:
    			*(uint64_t*)mxGetData(PInputs[2]) = 1;
    			break; 
    		case mxFUNCTION_CLASS:
    		case mxUNKNOWN_CLASS:
    		case mxCELL_CLASS:
    		case mxSTRUCT_CLASS:
    			mexPrintf("Type of 3rd input argument cannot be used to return status of NaN occurence.");
		}
	}
#endif
#endif
}

