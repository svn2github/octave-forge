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
// usage:
//	[num,status,strarray] = str2double_mex(s,cdelim,rdelim,ddelim)
//
// Input:
//  s 	        data array
//  cdelim	column delimiter
//  rdelim	row delimiter
//  ddelim      decimal delimiter
//
// Output:
//    $Id$
//    Copyright (C) 2010 Alois Schloegl <a.schloegl@ieee.org>
//    This function is part of the NaN-toolbox
//    http://hci.tugraz.at/~schloegl/matlab/NaN/
//
//-------------------------------------------------------------------




#include <ctype.h>
#include <inttypes.h>
#include <math.h>
#include <string.h>
#include "mex.h"

#ifdef tmwtypes_h
  #if (MX_API_VER<=0x07020000)
    typedef int mwSize;
  #endif 
#endif 


void mexFunction(
    int           nlhs,           /* number of expected outputs */
    mxArray       *plhs[],        /* array of pointers to output arguments */
    int           nrhs,           /* number of inputs */
    const mxArray *prhs[]         /* array of pointers to input arguments */
)

{
	char *s=NULL;
	char *cdelim="\x09, ";
	char *rdelim="\x10\x13;";
	char *ddelim=".";
	char *valid_delim = " ()[]{},;:\"|/\x20\x21\x22\x09\0x0a\0x0b\0x0c\0x0d\x00";	// valid delimiter
	uint8_t *u;	
	size_t slen = 0,k;
	
	if (nrhs<1) {
		mexPrintf("   STR2DOUBLE.MEX is a mex-implementation of STR2DOUBLE.M\n");
		mexPrintf("   Usage of STR2DOUBLE_MEX:\n");
		mexPrintf("\t[num,status,strarray] = str2double_mex(s,cdelim,rdelim,ddelim)\n");
		mexPrintf("   Input:\n\tf\tfilename\n");
		mexPrintf("   Output:\n\tHDR\theader structure\n\n");
		return; 
	}

	/* process input arguments */
	for (k = 0; k < nrhs; k++)
	{	
		const mxArray *arg = prhs[k];
		if (mxIsEmpty(arg))
#ifdef DEBUG		
			mexPrintf("arg[%i] Empty\n",k)
#endif
			;
		else if (mxIsCell(arg))
#ifdef DEBUG		
			mexPrintf("arg[%i] IsCell\n",k)
#endif
			;
		else if (mxIsStruct(arg)) {
#ifdef DEBUG		
			mexPrintf("arg[%i] IsStruct\n",k);
#endif
		}
#ifdef CHOLMOD_H
		else if (mxIsSparse(arg) && (k==1)) {
			rr = sputil_get_sparse(arg,&RR,&dummy,0);
		}
#endif 
		else if (mxIsNumeric(arg)) {
#ifdef DEBUG		
			mexPrintf("arg[%i] IsNumeric\n",k);
#endif
		}	
		else if (mxIsSingle(arg))
#ifdef DEBUG		
			mexPrintf("arg[%i] IsSingle\n",k)
#endif
			;
		else if (mxIsChar(arg)) {
#ifdef DEBUG		
			mexPrintf("arg[%i]=%s \n",k,mxArrayToString(prhs[k]));
#endif
		
			switch (k) {
			case 0:
				s = mxArrayToString(prhs[k]);
				slen = mxGetNumberOfElements(prhs[k]);
				break; 
			case 1:
				cdelim = mxArrayToString(prhs[k]);
				break; 
			case 2:
				rdelim = mxArrayToString(prhs[k]);
				break; 
			case 3:
				ddelim = mxArrayToString(prhs[k]);
				break; 
			}
		}
	}

	/*
		sanity checks 	
	*/

	size_t maxcol=0, maxrow=0, nr, nc;
	nc=0, nr=0;
	uint8_t t=0,flag=1;
	u = (uint8_t*) mxMalloc(slen+1);

	/* identify separators */
	for (k = 0; k < slen; k++) {
		if (strchr(cdelim,s[k]) != NULL)
			u[k] = 1;
		else if (strchr(rdelim,s[k]) != NULL)
			u[k] = 2;
		else 
			u[k] = 0; 	
	}
	
	/* count dimensions */
	for (k = 0; k < slen; ) {
		if (u[k]==2) {
			nr++;
			while ((u[k]==2) && s[k]) s[k++]=0;

			if (nc > maxcol) maxcol=nc;
			nc = 0; 
		}
		else if (u[k]==1) {
			nc++;
			while ((u[k]==1) && s[k]) s[k++]=0;
		}
		else 
			while ((u[k]==0) && s[k])
				k++;
	}
	if (nc > maxcol) maxcol=nc;
	maxcol++;
	maxrow = nr+1;

	/* allocate output memory */
	if (nlhs>2) plhs[2] = mxCreateCellMatrix(maxrow, maxcol);
	uint8_t  *v;
	if (nlhs>1) {
		plhs[1] = mxCreateLogicalMatrix(maxrow, maxcol);
		v = (uint8_t*)mxGetData(plhs[1]);	
		memset(v,1,maxrow*maxcol);
	}
	plhs[0] = mxCreateDoubleMatrix(maxrow, maxcol, mxREAL);
	double   *o = (double*)mxGetData(plhs[0]);
	for (k=0; k<maxrow*maxcol; k++) {
		o[k] = 0.0/0.0;
	}
	
	nr = 0; nc = 0; 
	t  = 1;
	for (k = 0; k < slen; ) {
		if (u[k]==2) {
			nr++;
			nc = 0;
			while (u[k]==2) k++;	
		}
		else if (u[k]==1) {
			nc++;
			while (u[k]==1) k++;
		}
		else if (!!t && !u[k]) {
			char *endptr=NULL;
			double val = strtod(s+k,&endptr);
			size_t idx = nr+nc*maxrow;
			if (*endptr && !isspace(*endptr)) {
				o[idx] = 0.0/0.0; 
				if (nlhs>1) v[idx] = 1; 
				if (nlhs>2) mxSetCell(plhs[2], idx, mxCreateString(s+k));
			}
			else {
				o[idx] = val; 
				if (nlhs>1) v[idx] = 0; 
			}
			while (!u[k]) k++;
		}
		else k++;
		t = u[k-1];
	}	

	mxFree(u); 
};


