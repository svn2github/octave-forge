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

struct sort_t {
	uint8_t *Table;
	size_t Size;
	size_t Stride; 
	size_t N; 
	mxClassID Type;  
} Sort; 	

//inline int compare(const sqize_t *a, const size_t *b) {
inline int compare(const void *a, const void *b) {
	int z = 0; 
	size_t i = 0;
//	mexPrintf("cmp: %u %u\n",*(size_t*)a,*(size_t*)b);
//	mexPrintf("%i: %i %i %i %i %i %i \n",Sort.Type,mxINT32_CLASS,mxUINT32_CLASS,mxINT64_CLASS,mxUINT64_CLASS,mxSINGLE_CLASS,mxDOUBLE_CLASS);
	while ((i<Sort.N) && !z) {

		switch (Sort.Type) {
		case mxCHAR_CLASS:
			z = memcmp(Sort.Table+((*(size_t*)a + Sort.Stride*i)*Sort.Size),Sort.Table+((*(size_t*)b + Sort.Stride*i)*Sort.Size),Sort.Size); 
			break;
		case mxINT32_CLASS: {
			int32_t f1,f2;
			f1 = ((int32_t*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((int32_t*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxUINT32_CLASS: {
			uint32_t f1,f2;
			f1 = ((uint32_t*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((uint32_t*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxINT64_CLASS: {
			int64_t f1,f2;
			f1 = ((int64_t*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((int64_t*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxUINT64_CLASS: {
			uint64_t f1,f2; 
			f1 = ((uint64_t*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((uint64_t*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxSINGLE_CLASS: {
			float f1,f2;
			f1 = ((float*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((float*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxDOUBLE_CLASS: {
			double f1,f2;
			f1 = ((double*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((double*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxINT16_CLASS: {
			int16_t f1,f2;
			f1 = ((int16_t*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((int16_t*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxUINT16_CLASS: {
			uint16_t f1,f2;
			f1 = ((uint16_t*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((uint16_t*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxINT8_CLASS: {
			int8_t f1,f2;
			f1 = ((int8_t*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((int8_t*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		case mxUINT8_CLASS: {
			uint8_t f1,f2;
			f1 = ((uint8_t*)Sort.Table)[(*(size_t*)a + Sort.Stride*i)];
			f2 = ((uint8_t*)Sort.Table)[(*(size_t*)b + Sort.Stride*i)];
			if (f1<f2) z = -1; 
			else if (f1>f2) z = 1; 
			break;
			}
		}
		i++;	
	}	
	return(z);
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
	
	size_t *idx = NULL;
	if (flag_rows) { 
//	if (SZ[1]==1) { 
		int (*compar)(const void*, const void*);
		size_t n; 
		idx = (size_t*) mxMalloc(SZ[0]*sizeof(size_t));
		for (size_t n=0; n<SZ[0]; n++) {
			idx[n]=n;			
		}
		Sort.Type = mxGetClassID(PInputs[0]); 
		Sort.Table = (uint8_t*) mxGetData(PInputs[0]);
		switch (mxGetClassID(PInputs[0])) {
		case mxINT8_CLASS: 
		case mxUINT8_CLASS: 
			Sort.Size = 1;
			break; 
		case mxINT16_CLASS: 
		case mxUINT16_CLASS: 
			Sort.Size = 2;
			break; 
		case mxINT32_CLASS: 
		case mxUINT32_CLASS: 
		case mxSINGLE_CLASS:
			Sort.Size = 4;
			break; 
		case mxINT64_CLASS: 
		case mxUINT64_CLASS: 
		case mxDOUBLE_CLASS: 
			Sort.Size = 8;
			break;
		default:
			mexErrMsgTxt("unsupported input type"); 
		}	
		Sort.N = flag_rows ? SZ[1] : 1; 

		qsort(idx,SZ[0],sizeof(*idx),compare);
		n = SZ[0] ? 1 : 0; 
		for (size_t k=1; k<SZ[0]; k++) {
			if (compare(idx+k-1,idx+k)) n++;
		}
		mxArray *H = mxCreateNumericMatrix(n, 1, mxUINT64_CLASS,mxREAL);
		mxArray *X = mxCreateNumericMatrix(n, SZ[1], mxGetClassID(PInputs[0]),mxREAL); 
		mxSetField(HIS,0,"H",H);
		mxSetField(HIS,0,"X",X);
		uint64_t *h = (uint64_t*)mxGetData(H);
		uint8_t *x = (uint8_t*)mxGetData(X);
		
		for (j=0; j<SZ[1]; j++) {
			memcpy(x+j*n*Sort.Size,Sort.Table+(idx[0]+j*Sort.Stride)*Sort.Size,Sort.Size);
		}
		h[0] = 1; 
		l = 0;
		for (size_t k=1; k<SZ[0]; k++) {
			if (compare(&idx[k-1], &idx[k])) {
				l++;
				for (j=0; j<SZ[1]; j++) {
					memcpy(x + (l+j*n)*Sort.Size, Sort.Table+(idx[k] + j*Sort.Stride)*Sort.Size, Sort.Size);
				}
			}
			h[l]++;	
		}
		mxFree(idx); 
		done = 1;
	}

	else { 
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

		default: {
			/* FIXME */
			mexErrMsgTxt("multicolumns with int32 or larger not supported!"); 

			mxArray *H = mxCreateNumericMatrix(0x10000, SZ[1], mxUINT64_CLASS,mxREAL);
			mxArray *X = mxCreateNumericMatrix(0x10000, SZ[1], mxGetClassID(PInputs[0]),mxREAL); 
			mxSetField(HIS,0,"H",H);
			mxSetField(HIS,0,"X",X);

			uint64_t *h = (uint64_t*)mxGetData(H);
			int16_t *x = (int16_t*)mxGetData(X);

			for (size_t n=0; n<SZ[1]; n++) {
			}	
			}
		} // end switch 	
	}
	

	/*******  output    *******/
	if (done) POutput[0] = HIS; 
	
	return; 
}
