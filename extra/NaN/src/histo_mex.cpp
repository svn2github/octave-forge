//-------------------------------------------------------------------
#pragma HISstop
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
// - flag (is actually an output argument telling whether some NaN was observed)
// - weight vector to compute weighted sum 
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
#include <string.h>
#include "mex.h"


#ifdef tmwtypes_h
  #if (MX_API_VER<0x07020000)
    typedef int mwSize;
  #endif 
#endif 

inline int uint8cmp(const uint8_t *a, const uint8_t *b) {
	return((int)*(uint8_t*)a - (int)*(uint8_t*)b);
}
inline int int8cmp(const int8_t *a, const int8_t *b) {
	return((int)*(int8_t*)a - (int)*(int8_t*)b);
}
inline int uint16cmp(const void *a, const void *b) {
	return((int)*(uint16_t*)a - (int)*(uint16_t*)b);
}
inline int int16cmp(const void *a, const void *b) {
	return((int)*(int16_t*)a - (int)*(int16_t*)b);
}
inline int uint32cmp(const void *a, const void *b) {
	return(memcmp(a,b,4));
}
inline int int32cmp(const void *a, const void *b) {
	return((int64_t)*(int32_t*)a - *(int32_t*)b);
}
inline int uint64cmp(const void *a, const void *b) {
	return(memcmp(a,b,8));
}
inline int int64cmp(const void *a, const void *b) {
	return(*(int64_t*)a - *(int64_t*)b);
}

inline int float32cmp(const void *a, const void *b) {
	return(memcmp(a,b,4));
}
inline int float64cmp(const void *a, const void *b) {
	return(memcmp(a,b,8));
}
inline int float128cmp(const void *a, const void *b) {
	return(memcmp(a,b,16));
}



void histo(void *x, size_t sz, size_t stride, size_t n) 
{
	if (stride==1)
		qsort(x,n,sz,uint32cmp);	

}

void mexFunction(int POutputCount,  mxArray* POutput[], int PInputCount, const mxArray *PInputs[]) 
{




    	const mwSize	*SZ;	    
	char flag_rows = 0; 
	char done = 0; 
	
    	mwSize		DIM = 0; 
    	mwSize    	ND, ND2;	// number of dimensions: input, output
    	mwSize    	j, k, l;		// running indices 

	// check for proper number of input and output arguments
	if ((PInputCount <= 0) || (PInputCount > 2))
	        mexErrMsgTxt("histo.MEX requires between 1 and 4 arguments.");
	if (POutputCount > 4)
	        mexErrMsgTxt("histo.MEX has 1 to 3 output arguments.");

	// get 1st argument
	if (mxIsComplex(PInputs[0]))
		mexErrMsgTxt("First argument must be REAL/DOUBLE.");
		
	if ((PInputCount>1) && (mxIsChar(PInputs[1]))) {
		char *t = mxArrayToString(PInputs[1]);
		flag_rows = !strcmp(t,"rows");
		mxFree(t); 
	} 
		

	// get size 
    	ND = mxGetNumberOfDimensions(PInputs[0]);	
    	// NN = mxGetNumberOfElements(PInputs[0]);
    	SZ = mxGetDimensions(PInputs[0]);		

	if (ND>2) 
		mexErrMsgTxt("Error HISTO.MEX: input must be vector or matrix (no more than two dimensions)");

	size_t n = SZ[0];
	size_t sz = 1;
	//size_t sz = SZ[1]; /* row sorting */	
	char flag = 0; 
	
	const char *fnames[] = {"datatype","X","H"};
	mxArray	*HIS = mxCreateStructMatrix(1, 1, 3, fnames);
	mxSetField(HIS,0,"datatype",mxCreateString("HISTOGRAM"));
	
	if (!flag_rows || (SZ[1]==1)) 
	switch (mxGetClassID(PInputs[0])) {
/*
	case mxCHAR_CLASS: {
		mxArray *H = mxCreateNumericMatrix(256, SZ[1], mxUINT64_CLASS,mxREAL);
		mxArray *X = mxCreateNumericMatrix(256, 1, mxINT8_CLASS,mxREAL); 
		mxSetField(HIS,0,"H",H);
		mxSetField(HIS,0,"X",X);

		char *x;
		x = (char*)mxGetData(X);
		qsort(x,n,sz,strcpy);	
		break;
		}
*/
	case mxINT8_CLASS: { 	
		mxArray *H = mxCreateNumericMatrix(256, SZ[1], mxUINT64_CLASS,mxREAL);
		mxArray *X = mxCreateNumericMatrix(256, 1, mxINT8_CLASS,mxREAL); 
		mxSetField(HIS,0,"H",H);
		mxSetField(HIS,0,"X",X);

		int8_t *x;
		x = (int8_t*)mxGetData(X);
		for (k=0; k<=255; k++)
			x[k]=k-128;

		x = (int8_t*)mxGetData(PInputs[0]);
		uint64_t *h = (uint64_t*)mxGetData(H);
		for (k=0; k<SZ[0]*SZ[1]; k++)
			h[x[k]+128+256*(k/SZ[0])]++;
		
		done = 1; 	
		break;
	}
	case mxUINT8_CLASS: { 	
		mxArray *H = mxCreateNumericMatrix(256, SZ[1], mxUINT64_CLASS,mxREAL);
		mxArray *X = mxCreateNumericMatrix(256, 1, mxUINT8_CLASS,mxREAL); 
		mxSetField(HIS,0,"H",H);
		mxSetField(HIS,0,"X",X);

		uint8_t *x = (uint8_t*)mxGetData(X);
		for (k=0; k<255; k++)
			x[k]=k;

		x = (uint8_t*)mxGetData(PInputs[0]);
		uint64_t *h = (uint64_t*)mxGetData(H);
		for (k=0; k<SZ[0]*SZ[1]; k++)
			h[x[k]+256*(k/SZ[0])]++;
			
		done = 1; 	
		break;
	}
	case mxINT16_CLASS: {	
		mxArray *H = mxCreateNumericMatrix(0x10000, SZ[1], mxUINT64_CLASS,mxREAL);
		mxArray *X = mxCreateNumericMatrix(0x10000, 1, mxINT16_CLASS,mxREAL); 
		mxSetField(HIS,0,"H",H);
		mxSetField(HIS,0,"X",X);

		uint64_t *h = (uint64_t*)mxGetData(H);
		int16_t *x = (int16_t*)mxGetData(X);
		for (k=0; k<0x10000; k++)
			x[k]=k-0x8000;

		x = (int16_t*)mxGetData(PInputs[0]);
		for (k=0; k<SZ[0]*SZ[1]; k++)
			h[x[k]+0x8000+0x10000*(k/SZ[0])]++;
			
		done = 1; 	
		break;
	}

	case mxUINT16_CLASS: {	
		mxArray *H = mxCreateNumericMatrix(0x10000, SZ[1], mxUINT64_CLASS,mxREAL);
		mxArray *X = mxCreateNumericMatrix(0x10000, 1, mxINT16_CLASS,mxREAL); 
		mxSetField(HIS,0,"H",H);
		mxSetField(HIS,0,"X",X);

		uint64_t *h = (uint64_t*)mxGetData(H);
		int16_t *x = (int16_t*)mxGetData(X);
		for (k=0; k<0x10000; k++)
			x[k]=k-0x8000;

		uint16_t *x16 = (uint16_t*)mxGetData(PInputs[0]);
		for (k=0; k<SZ[0]*SZ[1]; k++)
			h[x16[k]+0x10000*(k/SZ[0])]++;
		done = 1; 	
		break;	
	}
	} // end switch 	
	

	POutput[0] = HIS; 

	if (done) return; 

	/* FIXME */

	if (!flag_rows) { 
		for (size_t n=0; n<SZ[1]; n++) {
			
		}
	}
	else
	

	if (!done) 
	switch (mxGetClassID(PInputs[0])) {
	case mxINT32_CLASS: {	
		int32_t *x = (int32_t*)mxGetData(PInputs[0]);
		qsort(x,n,sz*4,int32cmp);	
			/* FIXME */
		break;
	}
	case mxUINT32_CLASS: {	
		uint32_t *x = (uint32_t*)mxGetData(PInputs[0]);
		qsort(x,n,sz*4,uint32cmp);	
			/* FIXME */
		break;
	}
	case mxINT64_CLASS: { 	
		uint64_t *x = (uint64_t*)mxGetData(PInputs[0]);
		qsort(x,n,sz*8,int64cmp);	
			/* FIXME */
		break;
	}
	case mxUINT64_CLASS: {	
		uint64_t *x = (uint64_t*)mxGetData(PInputs[0]);
		qsort(x,n,sz*8,uint64cmp);	
			/* FIXME */
		break;
	}
	case mxSINGLE_CLASS: {
		mxArray *H = mxCreateNumericMatrix(0x10000, SZ[1], mxUINT64_CLASS,mxREAL);
		mxArray *X = mxCreateNumericMatrix(0x10000, 1, mxSINGLE_CLASS,mxREAL); 
		mxSetField(HIS,0,"H",H);
		mxSetField(HIS,0,"X",X);

		uint64_t *h = (uint64_t*)mxGetData(H);
		float *x = (float*)mxGetData(X);
		x = (float*)mxGetData(PInputs[0]);

		flag = 0; 
		for (k=0; (k<SZ[0]) && !flag; k++) {
			if (x[k] == ceil(x[k])) 
				h[(size_t)x[k]+0x8000]++;
			else 
				flag = 1; 	
		}
		if (!flag) {
			for (k=0; k<0x10000; )
				x[k++]=k-0x8000;
		}
		else {
			qsort(x,n,sz*4,float32cmp);	
			/* FIXME */
		}	
		break;
	}
	case mxDOUBLE_CLASS: { 	
		mxArray *H = mxCreateNumericMatrix(0x18000, SZ[1], mxUINT64_CLASS,mxREAL);
		mxArray *X = mxCreateNumericMatrix(0x18000, 1, mxDOUBLE_CLASS,mxREAL); 
		mxSetField(HIS,0,"H",H);
		mxSetField(HIS,0,"X",X);

		uint64_t *h = (uint64_t*)mxGetData(H);
		double *x = (double*)mxGetData(X);
		x = (double*)mxGetData(PInputs[0]);
		flag = 0; 
		for (k=0; (k<SZ[0]) && !flag; k++) {
			if ((x[k] == ceil(x[k])) && (x[k]<0x10000) && (x[k]>-32769)) 
				h[(int)x[k]+0x8000]++;
			else 
				flag = 1; 	
		}
		if (!flag) 
			for (k=0; k<0x18000; k++)
				x[k++] = k-0x8000;
		else {
			qsort(x, n, sz*8, float64cmp);	
			
			/* FIXME */
		}	
		break;
	}
	}	// end switch 

		
	/*******  output    *******/
	POutput[0] = HIS; 

}
