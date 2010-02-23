//-------------------------------------------------------------------
#pragma hdrstop
//-------------------------------------------------------------------
//   C-MEX implementation of STR2DOUBLE - this function is part of the NaN-toolbox. 
//   Actually, it also fixes a problem in str2double.m described here:
//   http://www-old.cae.wisc.edu/pipermail/help-octave/2007-December/007325.html
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
// usage:
//	[...] = str2double_mex(s)
//	[...] = str2double_mex(s,cdelim)
//	[...] = str2double_mex(s,cdelim,rdelim)
//	[...] = str2double_mex(s,cdelim,rdelim,ddelim)
//	[num,status,strarray] = str2double_mex(...)
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
//    http://biosig-consulting.com/matlab/NaN/
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
	char *s = NULL;
	char *cdelim = "\x09,";
	char *rdelim = "\x10\x13;";
	char *ddelim = NULL;
	char *valid_delim = " ()[]{},;:\"|/\x20\x21\x22\x09\0x0a\0x0b\0x0c\0x0d\x00";	// valid delimiter
	uint8_t *u;	
	size_t slen = 0,k;
	size_t maxcol=0, maxrow=0, nr, nc;
	
	if (nrhs<1) {
		mexPrintf("   STR2DOUBLE.MEX is a mex-implementation of STR2DOUBLE.M\n");
		mexPrintf("   Actually, it fixes the problem discussed here: http://www-old.cae.wisc.edu/pipermail/help-octave/2007-December/007325.html\n");
		mexPrintf("\n   Usage of STR2DOUBLE_MEX:\n");
		mexPrintf("\t[...] = str2double(s)\n");
		mexPrintf("\t[...] = str2double(s,cdelim)\n");
		mexPrintf("\t[...] = str2double(s,cdelim,rdelim)\n");
		mexPrintf("\t[...] = str2double(s,cdelim,rdelim,ddelim)\n");
		mexPrintf("\t[num,status,strarray] = str2double(...)\n");
		mexPrintf("   Input:\n\ts\tstring\n\tcdelim\tlist of column delimiters (default: \"<Tab>,\"\n\trdelim\tlist of row delimiter (defautlt: \"<LF><CR>;\")");
		mexPrintf("\n\tddelim\tdecimal delimiter (default: \".\"). This is useful if decimal delimiter is a comma (e.g. after Excel export in Europe)\n");
		mexPrintf("   Output:\n\tnum\tnumeric array\n\tstatus\tflag failing conversion\n\tstrarray\tcell array of strings contains strings of failed conversions\n");
		return; 
	}

	/* sanity check of input arguments */
	if (nrhs>0) {
		if (mxIsChar(prhs[0])) {	
			s = mxArrayToString(prhs[0]);
			slen = mxGetNumberOfElements(prhs[0]);
		}
		else 
			mexErrMsgTxt("arg1 is not a char array");
	}		
	if (nrhs>1) {
		if (mxIsChar(prhs[1])) 	
			cdelim = mxArrayToString(prhs[1]);
		else 
			mexErrMsgTxt("arg2 is not a char array");
	}		
	if (nrhs>2) {
		if (mxIsChar(prhs[2])) 	
			rdelim = mxArrayToString(prhs[2]);
		else 
			mexErrMsgTxt("arg3 is not a char array");
	}		
	if (nrhs>3) {
		if (mxIsChar(prhs[3]) && (mxGetNumberOfElements(prhs[3])==1) ) {
			ddelim = mxArrayToString(prhs[3]);
			for (k=0; k<slen; k++) {
				if (s[k]==ddelim[0]) 
					s[k] = '.'; 
			}
		}	
		else 
			mexErrMsgTxt("arg4 is not a single char");
	}		

	/* identify separators */
	u = (uint8_t*) mxMalloc(slen+1);
	for (k = 0; k < slen; k++) {
		if (strchr(cdelim,s[k]) != NULL)
			u[k] = 1;	// column delimiter
		else if (strchr(rdelim,s[k]) != NULL)
			u[k] = 2;	// row delimiter
		else 
			u[k] = 0; 	// ordinary character 
	}

#ifdef DEBUG		
	mexPrintf("<%s>\n[",s);
	for (k=0; k<slen; k++)
		mexPrintf("%i",u[k]);
	mexPrintf("]\n",s);
#endif
	
	/* count dimensions and set delimiter elements to 0 */
	nc=0, nr=0;
	if (u[slen-1]<2) {
		// when terminating char is not a row delimiter 
		nr = (slen>0);
		u[slen] = 2; 	
	}	
	for (k = 0; k < slen; ) {
		if (u[k]==2) {
			while ((u[k]==2) && s[k]) {
				s[k++]=0; 
				nr++;
			}

			if (nc > maxcol) maxcol=nc;
			nc = 0; 
		}
		else if (u[k]==1) {
			while ((u[k]==1) && s[k]) {
				s[k++]=0;
				nc++;
			}
		}
		else 
			while ((u[k]==0) && s[k]) k++;
	}
	if (nc > maxcol) maxcol=nc;
	maxcol += (slen>0);
	maxrow = nr;

#ifdef DEBUG		
	mexPrintf("[%i,%i]\n",maxrow,maxcol);
#endif

	/* allocate output memory */
	if (nlhs>2) plhs[2] = mxCreateCellMatrix(maxrow, maxcol);
	uint8_t *v = NULL;
	if (nlhs>1) {
		plhs[1] = mxCreateLogicalMatrix(maxrow, maxcol);
		v = (uint8_t*)mxGetData(plhs[1]);	
		memset(v,1,maxrow*maxcol);
	}
	plhs[0] = mxCreateDoubleMatrix(maxrow, maxcol, mxREAL);
	double *o = (double*)mxGetData(plhs[0]);
	for (k=0; k<maxrow*maxcol; k++) {
		o[k] = 0.0/0.0;
	}
	
	nr = 0; nc = 0; 
	size_t last=0; 
	for (k = 0; k <= slen; k++) {
		if (u[k]) {
			// delimiter triggers action 
			size_t idx = nr+nc*maxrow;
			if (last==k) {
				// empty field 
				o[idx] = 0.0/0.0; 
			}
			else {
				char *endptr = NULL;
				double val = strtod(s+last,&endptr);	// conversion 
				if (*endptr && !isspace(*endptr)) {
					// conversion failed 
					o[idx] = 0.0/0.0; 
					if (nlhs>2) mxSetCell(plhs[2], idx, mxCreateString(s+last));
				}
				else {
					// conversion successful 
					o[idx] = val; 
					if (nlhs>1) v[idx] = 0; 
				}
			}	
			nc++;	// next element 
			if (u[k]==2) {
				nr++;	// next row 
				nc = 0;
			}	
			last = k+1; 
		}
	}	
	mxFree(u); 
};

