//-------------------------------------------------------------------
#pragma hdrstop
//-------------------------------------------------------------------
//   C-MEX implementation of SUMSKIPNAN - this function is part of the NaN-toolbox. 
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
// - array to sum
// - dimension to sum
//
// Output:
// - sums
// - count of valid elements (optional)
// - sums of squares (optional)
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

inline int __sumskipnan2__(double *data, size_t Ni, double *s, double *No, char *flag_anyISNAN);
inline int __sumskipnan3__(double *data, size_t Ni, double *s, double *s2, double *No, char *flag_anyISNAN);

//#define NO_FLAG

void mexFunction(int POutputCount,  mxArray* POutput[], int PInputCount, const mxArray *PInputs[]) 
{
    	const int	*SZ;	    
    	double* 	LInput;
    	double* 	LOutputSum;
    	double* 	LOutputCount;
    	double* 	LOutputSum2;
    	double  	x;
    	unsigned long   LCount;

    	unsigned	DIM = 0; 
    	size_t		D1, D2, D3; 	// NN; 	//  	
    	unsigned    	ND, ND2;	// number of dimensions: input, output
    	size_t		ix0, ix1, ix2;	// index to input and output
    	unsigned    	j, l;		// running indices 
    	int 		*SZ2;		// size of output 	    
	char	 	flag_isNaN = 0;


	// check for proper number of input and output arguments
	if ((PInputCount <= 0) || (PInputCount > 3))
	        mexErrMsgTxt("SumSkipNan.MEX requires 1,2 or 3 arguments.");
	if (POutputCount > 4)
	        mexErrMsgTxt("SumSkipNan.MEX has 1 to 3 output arguments.");

	// get 1st argument
	if(mxIsDouble(PInputs[0]) && !mxIsComplex(PInputs[0]))
		LInput  = mxGetPr(PInputs[0]);
	else 	
		mexErrMsgTxt("First argument must be REAL/DOUBLE.");

    	// get 2nd argument
    	if  (PInputCount > 1){
 	       	switch (mxGetNumberOfElements(PInputs[1])) {
		case 0: x = 0.0; 		// accept empty element
			break;
		case 1: x = (mxIsNumeric(PInputs[1]) ? mxGetScalar(PInputs[1]) : -1.0); 
			break;
		default:x = -1.0;		// invalid 
		}
		if ((x < 0) || (x > 65535) || (x != floor(x))) 
			mexErrMsgTxt("Error SUMSKIPNAN.MEX: DIM-argument must be a positive integer scalar");

		DIM = (unsigned)floor(x);	
	}

	// get size 
    	ND = mxGetNumberOfDimensions(PInputs[0]);	
    	// NN = mxGetNumberOfElements(PInputs[0]);
    	SZ = mxGetDimensions(PInputs[0]);		

	// if DIM==0 (undefined), look for first dimension with more than 1 element. 
	for (j = 0; (DIM < 1) && (j < ND); j++) 
		if (SZ[j]>1) DIM = j+1;
	
	if (DIM < 1) DIM=1;		// in case DIM is still undefined 

	ND2 = (ND>DIM ? ND : DIM);	// number of dimensions of output 

	SZ2 = (int*)mxCalloc(ND2, sizeof(int)); // allocate memory for output size

	for (j=0; j<ND; j++)		// copy size of input;  
		SZ2[j] = SZ[j]; 	
	for (j=ND; j<ND2; j++)		// in case DIM > ND, add extra elements 1 
		SZ2[j] = 1; 	

    	for (j=0, D1=1; j<DIM-1; D1=D1*SZ2[j++]); 	// D1 is the number of elements between two elements along dimension  DIM  
	D2 = SZ2[DIM-1];		// D2 contains the size along dimension DIM 	
    	for (j=DIM, D3=1;  j<ND; D3=D3*SZ2[j++]); 	// D3 is the number of blocks containing D1*D2 elements 

	SZ2[DIM-1] = 1;		// size of output is same as size of input but SZ(DIM)=1;

	    // create outputs
	#define TYP mxDOUBLE_CLASS

	POutput[0] = mxCreateNumericArray(ND2, SZ2, TYP, mxREAL);
	LOutputSum = mxGetPr(POutput[0]);

    	if (POutputCount >= 2) {
		POutput[1] = mxCreateNumericArray(ND2, SZ2, TYP, mxREAL);
		LOutputCount = mxGetPr(POutput[1]);
    	}
    	if (POutputCount >= 3) {
		POutput[2] = mxCreateNumericArray(ND2, SZ2, TYP, mxREAL);
        	LOutputSum2  = mxGetPr(POutput[2]);
    	}

	mxFree(SZ2);

	if ((POutputCount <= 1) && !mxIsComplex(PInputs[0])) {
		// OUTER LOOP: along dimensions > DIM
		for (l = 0; l<D3; l++) {
			ix0 = l*D1; 	// index for output
			ix1 = ix0*D2;	// index for input 
			if (D1==1)  	
			{
				double count;
				__sumskipnan2__(LInput+ix1, D2, LOutputSum+ix0, &count, &flag_isNaN);
 	       		}
			else for (j=0; j<D2; j++) {
				// minimize cache misses 
				ix2 =   ix0;	// index for output 
				// Inner LOOP: along dimensions < DIM
				do {
					register double x = *LInput;
        				if (!isnan(x)) {
						LOutputSum[ix2]   += x; 
					}
#ifndef NO_FLAG
					else 
						flag_isNaN = 1; 
#endif 
					LInput++;
					ix2++;
				} while (ix2 != (l+1)*D1);
               		}
               	}		
	}

	else if ((POutputCount == 2) && !mxIsComplex(PInputs[0])) {
		// OUTER LOOP: along dimensions > DIM
		for (l = 0; l<D3; l++) {
			ix0 = l*D1; 
			ix1 = ix0*D2;	// index for input 
			if (D1==1)  	
			{
				__sumskipnan2__(LInput+ix1, D2, LOutputSum+ix0, LOutputCount+ix0, &flag_isNaN);
 	       		}
			else for (j=0; j<D2; j++) {
				// minimize cache misses 
				ix2 =   ix0;	// index for output 
				// Inner LOOP: along dimensions < DIM
				do {
					register double x = *LInput;
        				if (!isnan(x)) {
						LOutputCount[ix2] += 1.0; 
						LOutputSum[ix2]   += x; 
					}
#ifndef NO_FLAG
					else 
						flag_isNaN = 1; 
#endif
					LInput++;
					ix2++;
				} while (ix2 != (l+1)*D1);
               		}
               	}		
	}

	else if ((POutputCount == 3) && !mxIsComplex(PInputs[0])) {
		// OUTER LOOP: along dimensions > DIM
		for (l = 0; l<D3; l++) {
			ix0 = l*D1; 
			ix1 = ix0*D2;	// index for input 
			if (D1==1)  	
			{
				size_t count;
				__sumskipnan3__(LInput+ix1, D2, LOutputSum+ix0, LOutputSum2+ix0, LOutputCount+ix0, &flag_isNaN);
 	       		}
			else for (j=0; j<D2; j++) {
				// minimize cache misses 
				ix2 =   ix0;	// index for output 
				// Inner LOOP: along dimensions < DIM
				do {
					register double x = *LInput;
        				if (!isnan(x)) {
						LOutputCount[ix2] += 1.0; 
						LOutputSum[ix2]   += x; 
						LOutputSum2[ix2]  += x*x; 
					}
#ifndef NO_FLAG
					else 
						flag_isNaN = 1; 
#endif
					LInput++;
					ix2++;	
				} while (ix2 != (l+1)*D1);
               		}
               	}		
	}

#ifndef NO_FLAG
	if  (flag_isNaN && (PInputCount > 2)) {
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
    			mexPrintf("Type of 3rd input argument not supported.");
		}
	}
#endif
}


#define stride 1 
inline int __sumskipnan2__(double *data, size_t Ni, double *s, double *No, char *flag_anyISNAN)
{
	register double sum=0; 
	register size_t count=0; 
	register char   flag=0; 
	// LOOP  along dimension DIM
	
	void *end = data + stride*Ni; 
	do {
		register double x = *data;
        	if (!isnan(x))
		{
			count++; 
			sum += x; 
		}
#ifndef NO_FLAG
		else 
			flag = 1; 
#endif

		data +=stride;	
	}
	while (data < end);
	
#ifndef NO_FLAG
	if (flag && (flag_anyISNAN != NULL)) *flag_anyISNAN = 1; 
#endif
	*s  = sum;
        *No = (double)count;

}

inline int __sumskipnan3__(double *data, size_t Ni, double *s, double *s2, double *No, char *flag_anyISNAN)
{
	register double sum=0; 
	register double msq=0; 
	register size_t count=0; 
	register char   flag=0; 
	// LOOP  along dimension DIM
	
	void *end = data + stride*Ni; 
	do {
		register double x = *data;
        	if (!isnan(x)) {
			count++; 
			sum += x; 
			msq += x*x; 
		}
#ifndef NO_FLAG
		else 
			flag = 1; 
#endif

		data++;	// stride=1
	}
	while (data < end);

#ifndef NO_FLAG
	if (flag && (flag_anyISNAN != NULL)) *flag_anyISNAN = 1; 
#endif
	*s  = sum;
	*s2 = msq; 
        *No = (double)count;
}

