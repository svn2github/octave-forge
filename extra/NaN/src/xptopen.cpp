//-------------------------------------------------------------------
//   C-MEX implementation of kth element - this function is part of the NaN-toolbox. 
//
//   usage: x = xptopen(filename)
//   usage: x = xptopen(filename,'r')
//		read filename and return variables in struct x

//   usage: xptopen(filename,'w',x)
//		save fields of struct x in filename  

//   usage: x = xptopen(filename,'a',x)
//		append fields of struct x to filename  
//
//   References: 
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
//    $Id$
//    Copyright (C) 2010 Alois Schloegl <a.schloegl@ieee.org>
//    This function is part of the NaN-toolbox
//    http://biosig-consulting.com/matlab/NaN/
//
// References:
// [1]	TS-140 THE RECORD LAYOUT OF A DATA SET IN SAS TRANSPORT (XPORT) FORMAT
//	http://support.sas.com/techsup/technote/ts140.html
// [2] IBM floating point format 
//	http://en.wikipedia.org/wiki/IBM_Floating_Point_Architecture
// [3] see http://old.nabble.com/Re%3A-IBM-integer-and-double-formats-p20428979.html
// [4] STATA File Format
//	http://www.stata.com/help.cgi?dta 
//	http://www.stata.com/help.cgi?dta_113
//-------------------------------------------------------------------

/*
SPSS file format
// http://cvs.savannah.gnu.org/pspp/doc/data-file-format.texi?root=pspp&content-type=text%2Fplain
*/

#define TEST_CONVERSION 2  // 0: ieee754, 1: SAS converter (big endian bug), 2: experimental
#define DEBUG 0

#include <ctype.h>
#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "mex.h"

#ifdef tmwtypes_h
  #if (MX_API_VER<=0x07020000)
    typedef int mwSize;
    typedef int mwIndex;
  #endif 
#endif 

#define NaN  		(0.0/0.0)
#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))


#ifdef __linux__
/* use byteswap macros from the host system, hopefully optimized ones ;-) */
#include <byteswap.h>
#endif 

#ifndef _BYTESWAP_H
/* define our own version - needed for Max OS X*/
#define bswap_16(x)   \
	((((x) & 0xff00) >> 8) | (((x) & 0x00ff) << 8))

#define bswap_32(x)   \
	 ((((x) & 0xff000000) >> 24) \
        | (((x) & 0x00ff0000) >> 8)  \
	| (((x) & 0x0000ff00) << 8)  \
	| (((x) & 0x000000ff) << 24))

#define bswap_64(x) \
      	 ((((x) & 0xff00000000000000ull) >> 56)	\
      	| (((x) & 0x00ff000000000000ull) >> 40)	\
      	| (((x) & 0x0000ff0000000000ull) >> 24)	\
      	| (((x) & 0x000000ff00000000ull) >> 8)	\
      	| (((x) & 0x00000000ff000000ull) << 8)	\
      	| (((x) & 0x0000000000ff0000ull) << 24)	\
      	| (((x) & 0x000000000000ff00ull) << 40)	\
      	| (((x) & 0x00000000000000ffull) << 56))
#endif  /* _BYTESWAP_H */


#if __BYTE_ORDER == __BIG_ENDIAN
#define l_endian_u16(x) ((uint16_t)bswap_16((uint16_t)(x)))
#define l_endian_u32(x) ((uint32_t)bswap_32((uint32_t)(x)))
#define l_endian_u64(x) ((uint64_t)bswap_64((uint64_t)(x)))
#define l_endian_i16(x) ((int16_t)bswap_16((int16_t)(x)))
#define l_endian_i32(x) ((int32_t)bswap_32((int32_t)(x)))
#define l_endian_i64(x) ((int64_t)bswap_64((int64_t)(x)))

#define b_endian_u16(x) ((uint16_t)(x))
#define b_endian_u32(x) ((uint32_t)(x))
#define b_endian_u64(x) ((uint64_t)(x))
#define b_endian_i16(x) ((int16_t)(x))
#define b_endian_i32(x) ((int32_t)(x))
#define b_endian_i64(x) ((int64_t)(x))

#elif __BYTE_ORDER==__LITTLE_ENDIAN
#define l_endian_u16(x) ((uint16_t)(x))
#define l_endian_u32(x) ((uint32_t)(x))
#define l_endian_u64(x) ((uint64_t)(x))
#define l_endian_i16(x) ((int16_t)(x))
#define l_endian_i32(x) ((int32_t)(x))
#define l_endian_i64(x) ((int64_t)(x))

#define b_endian_u16(x) ((uint16_t)bswap_16((uint16_t)(x)))
#define b_endian_u32(x) ((uint32_t)bswap_32((uint32_t)(x)))
#define b_endian_u64(x) ((uint64_t)bswap_64((uint64_t)(x)))
#define b_endian_i16(x) ((int16_t)bswap_16((int16_t)(x)))
#define b_endian_i32(x) ((int32_t)bswap_32((int32_t)(x)))
#define b_endian_i64(x) ((int64_t)bswap_64((int64_t)(x)))

#endif /* __BYTE_ORDER */


double xpt2d(uint64_t x);
uint64_t d2xpt(double x);

/*
	compare first n characters of two strings, ignore case  
 */
int strncmpi(const char* str1, const char* str2, size_t n)
{	
	unsigned int k=0;
	int r=0;
	while (!r && str1[k] && str2[k] && (k<n)) {
		r = tolower(str1[k]) - tolower(str2[k]);
		k++; 
	}	
	return(r); 	 	
}

void mexFunction(int POutputCount,  mxArray* POutput[], int PInputCount, const mxArray *PInputs[]) 
{
	const char L1[] = "HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000  ";
	const char L2[] = "SAS     SAS     SASLIB 6.06     bsd4.2                          13APR89:10:20:06";
	const char L3[] = "";
	const char L4[] = "HEADER RECORD*******MEMBER  HEADER RECORD!!!!!!!000000000000000001600000000140  ";
	const char L5[] = "HEADER RECORD*******DSCRPTR HEADER RECORD!!!!!!!000000000000000000000000000000  ";
	const char L6[] = "SAS     ABC     SASLIB 6.06     bsd4.2                          13APR89:10:20:06";
	const char L7[] = "";
	const char L8[] = "HEADER RECORD*******NAMESTR HEADER RECORD!!!!!!!000000000200000000000000000000  ";
	const char LO[] = "HEADER RECORD*******OBS     HEADER RECORD!!!!!!!000000000000000000000000000000  ";

	const  char DATEFORMAT[] = "%d%b%y:%H:%M:%S";
	char   *fn = NULL; 
	char   Mode[3] = "r"; 
	FILE   *fid; 	
	size_t count = 0, NS = 0, HeadLen0=80*8, HeadLen2=0, sz2 = 0, M=0;
	char   H0[HeadLen0];
	char   *H2 = NULL;
	
	// check for proper number of input and output arguments
	if ( PInputCount > 0 && mxGetClassID(PInputs[1])==mxCHAR_CLASS) {
		size_t buflen = (mxGetM(PInputs[0]) * mxGetN(PInputs[0]) * sizeof(mxChar)) + 1;
		fn = (char*)malloc(buflen); 
		mxGetString(PInputs[0], fn, buflen);
	}
	else {
		mexPrintf("XPTOPEN read and writes the SAS Transport Format (*.xpt)\n");
		mexPrintf("\n\tX = xptopen(filename)\n");
		mexPrintf("\tX = xptopen(filename,'r')\n");
		mexPrintf("\t\tread filename and return variables in struct X\n");
		mexPrintf("\n\tX = xptopen(filename,'w',X)\n");
		mexPrintf("\t\tsave fields of struct X in filename.\n\n");
		mexPrintf("\tThe fields of X must be column vectors of equal length.\n");
		mexPrintf("\tEach vector is either a numeric vector or a cell array of strings.\n");
		mexPrintf("\nSupported data formats: SAS-XPT (rw), STATA(r).\n");
		mexPrintf("\nThe SAS-XPT format stores Date/Time as numeric value counting the number of days since 1960-01-01.\n\n");
		return;
	}
	if ( PInputCount > 1) 
	if (mxGetClassID(PInputs[1])==mxCHAR_CLASS && mxGetNumberOfElements(PInputs[1])) {
		mxGetString(PInputs[1],Mode,3);
		Mode[2]=0;
	}

	fid = fopen(fn,Mode);
	if (fid < 0) {
	        mexErrMsgTxt("Error XPTOPEN: cannot open file\n");
	}	

	if (Mode[0]=='r' || Mode[0]=='a' ) {

		count += fread(H0,1,80*8,fid);		
		enum FileFormat {
			noFile, unknown, ARFF, SASXPT, SPSS, STATA
		};
		enum FileFormat TYPE; 		/* type of file format */
		uint8_t		LittleEndian;   /* 1 if file is LittleEndian data format and 0 for big endian data format*/  


		TYPE = unknown; 
		if (!memcmp(H0,"$FL2@(#) SPSS DATA FILE",8)) {
		/*
			SPSS file format 
		*/
			TYPE = SPSS;	
			switch (*(uint32_t*)(H0+64)) {
			case 0x00000002:
			case 0x00000003:
		    		LittleEndian = 1;
		    		NS = l_endian_u32(*(uint32_t*)(H0+68));
		    		M  = l_endian_u32(*(uint32_t*)(H0+80));
			    	break;
			case 0x02000000:
			case 0x03000000:
		    		LittleEndian = 0;
		    		NS = b_endian_i32(*(uint32_t*)(H0+68));
		    		M  = b_endian_i32(*(uint32_t*)(H0+80));
			    	break;
			default: 
				TYPE = unknown;   	
			}
		}

		if (TYPE == SPSS) 
			;
		else if ((H0[0]==113 || H0[0]==114) && (H0[1]==1 || H0[1]==2) && H0[2]==1 && H0[3]==0) { 
		/*
			STATA File Format
			http://www.stata.com/help.cgi?dta 
			http://www.stata.com/help.cgi?dta_113
		*/
			TYPE = STATA;
			// Header 119 bytes 	
	    		LittleEndian = H0[1]==2;
	    		if (LittleEndian) {
	    			NS = l_endian_u16(*(uint16_t*)(H0+4));
	    			M = l_endian_u32(*(uint32_t*)(H0+6));
	    		}
	    		else {
	    			NS = b_endian_u16(*(uint16_t*)(H0+4));
	    			M  = b_endian_u32(*(uint32_t*)(H0+6));
	    		}

	    		// Descriptors 
	    		int fmtlen = (H0[0]==113) ? 12 : 49; 
	    		fseek(fid,109,SEEK_SET);
	    		size_t HeadLen2 = 2+NS*(1+33+2+fmtlen+33+81);
			char *H1 = (char*)malloc(HeadLen2);
			fread(H1,1,HeadLen2,fid); 

			// expansion fields
			char typ; int32_t len,c;
			char flagSWAP = (((__BYTE_ORDER == __BIG_ENDIAN) && LittleEndian) || ((__BYTE_ORDER == __LITTLE_ENDIAN) && !LittleEndian));
			do { 
				fread(&typ,1,1,fid);
				fread(&len,4,1,fid);
				if (flagSWAP) bswap_32(len); 
				fseek(fid,len,SEEK_CUR);
			} while (len);				
			uint8_t *typlist = (uint8_t*)H1;
/*
			char *varlist = H1+NS;
			char *srtlist;
			char *fmtlist = H1+NS*36+2;			
			char *lbllist = H1+NS*(36+fmtlen)+2;			
*/
		
			mxArray **R = (mxArray**) malloc(NS*sizeof(mxArray*));
			size_t *bi = (size_t*) malloc((NS+1)*sizeof(size_t*));
			const char **ListOfVarNames = (const char**)malloc(NS * sizeof(char*)); 
			bi[0] = 0;
			for (size_t k = 0; k < NS; k++) {
				size_t sz;
				ListOfVarNames[k] = H1+NS+33*k;
				switch (typlist[k]) {
				case 0xfb: sz = 1; break; 
				case 0xfc: sz = 2; break; 
				case 0xfd: sz = 4; break; 
				case 0xfe: sz = 4; break; 
				case 0xff: sz = 8; break;
				otherwise: sz = typlist[k];
				} 
				bi[k+1] = bi[k]+sz;
			}
			
			// data 
			uint8_t *data = (uint8_t *) malloc(bi[NS] * M);
			fread(data, bi[NS], M, fid);
			
			char *f = (char*)malloc(bi[NS]+1);
			for (size_t k = 0; k < NS; k++) {
				switch (typlist[k]) {
				case 0xfb: 
					R[k] = mxCreateDoubleMatrix(M, 1, mxREAL); 
					for (size_t m = 0; m < M; m++) {
						int8_t d = *(int8_t*)(data+bi[k]+m*bi[NS]);
						((double*)mxGetData(R[k]))[m] = (d>100) ? NaN : d;
					}
					break; 
				case 0xfc: 
					R[k] = mxCreateDoubleMatrix(M, 1, mxREAL); 
					if (flagSWAP) for (size_t m = 0; m < M; m++) {
						int16_t d = (int16_t) bswap_16(*(uint16_t*)(data+bi[k]+m*bi[NS]));
						((double*)mxGetData(R[k]))[m] = (d>32740) ? NaN : d;
					}
					else for (size_t m = 0; m < M; m++) {
						int16_t d = *(int16_t*)(data+bi[k]+m*bi[NS]);
						((double*)mxGetData(R[k]))[m] = (d>32740) ? NaN : d;
					}
					break; 
				case 0xfd: 
					R[k] = mxCreateDoubleMatrix(M, 1, mxREAL); 
					if (flagSWAP) for (size_t m = 0; m < M; m++) {
						int32_t d = (int32_t)bswap_32(*(uint32_t*)(data+bi[k]+m*bi[NS]));
						((double*)mxGetData(R[k]))[m] = (d>2147483620) ? NaN : d;
					}
					else for (size_t m = 0; m < M; m++) {
						int32_t d = *(int32_t*)(data+bi[k]+m*bi[NS]);
						((double*)mxGetData(R[k]))[m] = (d>2147483620) ? NaN : d;
					}
					break; 
				case 0xfe: 
					R[k] = mxCreateNumericMatrix(M, 1, mxSINGLE_CLASS, mxREAL); 
					if (flagSWAP) for (size_t m = 0; m < M; m++) {
						((uint32_t*)mxGetData(R[k]))[m] = bswap_32(*(uint32_t*)(data+bi[k]+m*bi[NS]));;  
					}
					else for (size_t m = 0; m < M; m++) {
						((uint32_t*)mxGetData(R[k]))[m] = *(uint32_t*)(data+bi[k]+m*bi[NS]);  
					}
					break; 
				case 0xff: 
					R[k] = mxCreateDoubleMatrix(M, 1, mxREAL); 
					if (flagSWAP) for (size_t m = 0; m < M; m++) {
						((uint64_t*)mxGetData(R[k]))[m] = bswap_64(*(uint64_t*)(data+bi[k]+m*bi[NS]));  
					}
					else for (size_t m = 0; m < M; m++) {
						((uint64_t*)mxGetData(R[k]))[m] = *(uint64_t*)(data+bi[k]+m*bi[NS]);
					}
					break;
				default:
					R[k] =	mxCreateCellMatrix(M, 1);
					size_t sz = typlist[k];
					for (size_t m = 0; m < M; m++) {
						memcpy(f, data+bi[k]+m*bi[NS], sz);
						f[sz] = 0;
						mxSetCell(R[k], m, mxCreateString(f));
					}	
				} 
			}
			if (f) free(f); 
			if (H1) free(H1);
			if (bi) free(bi);
			
			/* convert into output */
			POutput[0] = mxCreateStructMatrix(1, 1, NS, ListOfVarNames);
			for (size_t k = 0; k < NS; k++) {
				 mxSetField(POutput[0], 0, ListOfVarNames[k], R[k]);
			}

			if (ListOfVarNames) free(ListOfVarNames);
		}

		else if (H0[0]=='%' || H0[0]=='@') {
		/*
			 ARFF
		*/
			TYPE = ARFF;	
			rewind(fid);
			char *H000 = NULL;
			count = 0;
			while (!feof(fid)) {
				HeadLen0 = HeadLen0*2;
				H000 = (char*)realloc(H000,HeadLen0);
				count += fread(H000+count,1,HeadLen0-count,fid);
			} 
			
			char *line = strtok(H000,"\x0a\x0d");
			int status = 0; 
			while (line) {
				if (!strncmpi(line,"@relation",9)) {	
					status = 1;
				}					

				else if (status == 1 && !strncmpi(line,"@attribute",10)) {	
					NS++;
					
				}	

				else if (status == 1 && !strncmpi(line,"@data",5)) {	
					status = 2;		
				}
				
				line = strtok(NULL,"\x0a\x0d");
			}			
			
			if (H000) free(H000);

		}	

		else if (!memcmp(H0,"HEADER RECORD*******LIBRARY HEADER RECORD!!!!!!!000000000000000000000000000000",78)) {
		/*
			 SAS Transport file format (XPORT)
		*/
			TYPE = SASXPT;	
			
			/* TODO: sanity checks */

			char tmp[5]; 
			memcpy(tmp,H0+7*80+54,4); 
			tmp[4] = 0;
			NS = atoi(tmp);
		
			char *tmp2;
			sz2 = strtoul(H0+4*80-6, &tmp2, 10); 
			 
			HeadLen2 = NS*sz2;
			if (HeadLen2 % 80) HeadLen2 = (HeadLen2 / 80 + 1) * 80; 	

			/* read namestr header, and header line "OBS" */
			H2 = (char*) realloc(H2, HeadLen2+81);
			count  += fread(H2,1,HeadLen2+80,fid);		

			/* size of single record */ 		
			size_t pos=0, recsize = 0, POS = 0;
			for (size_t k = 0; k < NS; k++) 
				recsize += b_endian_u16(*(int16_t*)(H2+k*sz2+4));

			/* read data section */			 
			size_t szData = 0; 
			uint8_t *Data = NULL; 
			while (!feof(fid)) {
				size_t szNew = max(16,szData*2);
				Data         = (uint8_t*)realloc(Data,szNew);
				szData      += fread(Data+szData,1,szNew-szData,fid);
			}
		
			M = szData/recsize; 			

			mxArray **R = (mxArray**) malloc(NS*sizeof(mxArray*));
			const char **ListOfVarNames = (const char**)malloc(NS * sizeof(char*)); 
			char *VarNames = (char*)malloc(NS * 9);

			for (size_t k = 0; k < NS; k++) {
				size_t maxlen = b_endian_u16(*(int16_t*)(H2+k*sz2+4));

				ListOfVarNames[k] = VarNames+pos;
				int n = k*sz2+8;
				int flagDate = (!memcmp(H2+n+48,"DATE    ",8) || !memcmp(H2+n+48,"MONNAME ",8));
				do {
					VarNames[pos++] = H2[n];	
				} while (isalnum(H2[++n]) && (n < k*sz2+16));	
			

				VarNames[pos++] = 0;

				if ((*(int16_t*)(H2+k*sz2)) == b_endian_u16(1) && (*(int16_t*)(H2+k*sz2+4)) == b_endian_u16(8) ) {
					// numerical data
					R[k] = mxCreateDoubleMatrix(M, 1, mxREAL); 
					for (size_t m=0; m<M; m++) {
						double d = xpt2d(b_endian_u64(*(uint64_t*)(Data+m*recsize+POS)));

//						if (flagDate) d += 715876;  // add number of days from 0000-Jan-01 to 1960-Jan-01

						*(mxGetPr(R[k])+m) = d;
							
					}
				}
				else if ((*(int16_t*)(H2+k*sz2)) == b_endian_u16(2)) {
					// character string 
					R[k] = mxCreateCellMatrix(M, 1);
					char *f = (char*)malloc(maxlen+1);
					for (size_t m=0; m<M; m++) {
						memcpy(f, Data+m*recsize+POS, maxlen);
						f[maxlen] = 0;
						mxSetCell(R[k], m, mxCreateString(f));
					}
					if (f) free(f);
				}
				POS += maxlen;
			}

			POutput[0] = mxCreateStructMatrix(1, 1, NS, ListOfVarNames);
			for (size_t k = 0; k < NS; k++) {
				 mxSetField(POutput[0], 0, ListOfVarNames[k], R[k]);
			}
	
			if (VarNames) 	    free(VarNames);
			if (ListOfVarNames) free(ListOfVarNames);
			if (Data)	    free(Data); 
			/* end of reading SAS format */
		}
			
		else {
			fclose(fid);
			mexErrMsgTxt("file format not supported");
			return; 
		}


		
	}

//	if (Mode[0]=='w' || Mode[0]=='a' ) {
	if (Mode[0]=='w') {
	
		NS += mxGetNumberOfFields(PInputs[2]);	

		// generate default (fixed) header	
		if (Mode[0]=='w') {
			memset(H0,' ',80*8);
			memcpy(H0,L1,strlen(L1));
			memcpy(H0+80,L2,strlen(L2));

			memcpy(H0+80*3,L4,strlen(L4));
			memcpy(H0+80*4,L5,strlen(L5));
			memcpy(H0+80*5,L6,strlen(L6));

			memcpy(H0+80*7,L8,strlen(L8));
		}
		
		time_t t;
		time(&t); 
		char tt[20];
		strftime(tt, 17, DATEFORMAT, localtime(&t));
		memcpy(H0+80*2-16,tt,16);		
		memcpy(H0+80*2,tt,16);		
		memcpy(H0+80*5+8,fn,min(8,strcspn(fn,".\x00")));		
		memcpy(H0+80*5+32,"XPTOPEN.MEX (OCTAVE/MATLAB)",27);		
		memcpy(H0+80*6-16,tt,16);		
		memcpy(H0+80*6,tt,16);		
		 
		char tmp[17];
		sprintf(tmp,"%04i", NS);	// number of variables 
		memcpy(H0+80*7+54, tmp, 4);
		
		if (sz2==0) sz2 = 140;
		if (sz2 < 136)  
			mexErrMsgTxt("error XPTOPEN: incorrect length of namestr field");

		/* generate variable NAMESTR header */
		HeadLen2 = NS*sz2;
		if (HeadLen2 % 80) HeadLen2 = (HeadLen2 / 80 + 1) * 80; 	
		H2 = (char*) realloc(H2,HeadLen2);
		memset(H2,0,HeadLen2);
		
		mwIndex M = 0;
		mxArray **F = (mxArray**) malloc(NS*sizeof(mxArray*));
		char **Fstr = (char**) malloc(NS*sizeof(char*));
		size_t *MAXLEN = (size_t*) malloc(NS*sizeof(size_t*));
		for (int16_t k = 0; k < NS; k++) {
			Fstr[k] = NULL;
			MAXLEN[k]=0; 
			F[k] = mxGetFieldByNumber(PInputs[2],0,k);
			if (k==0) M = mxGetM(F[k]);
			else if (M != mxGetM(F[k])) {
				if (H2) free(H2); 
				if (F)  free(F); 
				mexErrMsgTxt("Error XPTOPEN: number of elements (rows) do not fit !!!");
			}
			
			if (mxIsChar(F[k])) { 
				*(int16_t*)(H2+k*sz2) = b_endian_u16(2);
				*(int16_t*)(H2+k*sz2+4) = b_endian_u16(mxGetN(F[k]));
			}
			else if (mxIsCell(F[k])) {
				size_t maxlen = 0;  
				for (mwIndex m = 0; m<M; m++) {	
					mxArray *f = mxGetCell(F[k],m);			
					if (mxIsChar(f) || mxIsEmpty(f)) {
						size_t len = mxGetNumberOfElements(f);
						if (maxlen<len) maxlen = len;
					} 
				}
				Fstr[k] = (char*) malloc(maxlen+1);	
				*(int16_t*)(H2+k*sz2) = b_endian_u16(2);
				*(int16_t*)(H2+k*sz2+4) = b_endian_u16(maxlen);
				MAXLEN[k] = maxlen;
			}
			else {
				*(int16_t*)(H2+k*sz2) = b_endian_u16(1);
				*(int16_t*)(H2+k*sz2+4) = b_endian_u16(8);
			}	 
			*(int16_t*)(H2+k*sz2+6) = b_endian_u16(k);
			strncpy(H2+k*sz2+8,mxGetFieldNameByNumber(PInputs[2],k),8);
		}

		count  = fwrite(H0, 1, HeadLen0, fid);
		count += fwrite(H2, 1, HeadLen2, fid);
		/* write OBS header line */
		count += fwrite(LO, 1, strlen(LO), fid);
		for (mwIndex m = 0; m < M; m++) {
			for (int16_t k = 0; k < NS; k++) {

				if (*(int16_t*)(H2+k*sz2) == b_endian_u16(1)) {
					// numeric
					uint64_t u64 = b_endian_u64(d2xpt(*(mxGetPr(F[k])+m)));
					count += fwrite(&u64, 1, 8, fid);
				}	

/*				else if (mxIsChar(F[k])) { 
					*(int16_t*)(H2+k*sz2) = b_endian_u16(2);
					*(int16_t*)(H2+k*sz2+4) = b_endian_u16(mxGetN(F[k]));
				}
*/
				else if (mxIsCell(F[k])) {
					size_t maxlen = MAXLEN[k];
					mxArray *f = mxGetCell(F[k],m);
					mxGetString(f, Fstr[k], maxlen+1);
					count += fwrite(Fstr[k], 1, maxlen, fid); 
				}
			}
		}
/*
		// padding to full multiple of 80 byte: 
		// FIXME: this might introduce spurios sample values
		char d = count%80;
		while (d--) fwrite("\x20",1,1,fid);	
*/
		// free memory 
		for (size_t k=0; k<NS; k++) if (Fstr[k]) free(Fstr[k]); 
		if (Fstr)   free(Fstr); 
		if (MAXLEN) free(MAXLEN); 
		Fstr = NULL; 
	}
	fclose(fid); 
	
	if (H2) free(H2); 
	H2 = NULL;
	
	return; 
}


/*
	XPT2D converts from little-endian IBM to little-endian IEEE format 
*/

double xpt2d(uint64_t x) {
	// x is little-endian 64bit IBM floating point format 
	char c = *((char*)&x+7) & 0x7f;
	uint64_t u = x;
	*((char*)&u+7)=0;

#if __BYTE_ORDER == __BIG_ENDIAN

	mexErrMsgTxt("IEEE-to-IBM conversion on big-endian platform not supported, yet");

#elif __BYTE_ORDER==__LITTLE_ENDIAN

#if DEBUG 
	mexPrintf("xpt2d(%016Lx): [0x%x]\n",x,c);
#endif

	// missing values 
	if ((c==0x2e || c==0x5f || (c>0x40 && c<0x5b)) && !u ) 
		return(NaN);
	
	int s,e;
	s = *(((char*)&x) + 7) & 0x80;		// sign
	e = (*(((char*)&x) + 7) & 0x7f) - 64;	// exponent
	*(((char*)&x) + 7) = 0; 		// mantisse x 

#if DEBUG 
	mexPrintf("%x %x %016Lx\n",s,e,x);
#endif 

	double y = ldexp(x, e*4-56);
	if (s) return(-y);
	else   return( y);

#endif 
}


/*
	D2XPT converts from little-endian IEEE to little-endian IBM format 
*/

uint64_t d2xpt(double x) {
	uint64_t s,m;
	int e;

#if __BYTE_ORDER == __BIG_ENDIAN

	mexErrMsgTxt("IEEE-to-IBM conversion on big-endian platform not supported, yet");


#elif __BYTE_ORDER==__LITTLE_ENDIAN

	if (x != x) return(0x2eLL << 56);	// NaN - not a number 

	if (fabs(x) == 1.0/0.0) return(0x5fLL << 56); 	// +-infinity

	if (x == 0.0) return(0); 

	if (x > 0.0) s=0; 
	else s=1;

	x = frexp(x,&e); 

#if DEBUG 
	mexPrintf("d2xpt(%f)\n",x);
#endif 
	// see http://old.nabble.com/Re%3A-IBM-integer-and-double-formats-p20428979.html
	m = *(uint64_t*) &x;
	*(((char*)&m) + 6) &= 0x0f; //
	if (e) *(((char*)&m) + 6) |= 0x10; // reconstruct implicit leading '1' for normalized numbers 
	m <<= (3-(-e & 3));
	*(((char*)&m) + 7)  = s ? 0x80 : 0;
	e = (e + (-e & 3)) / 4 + 64;
	
	if (e >= 128) return(0x5f); // overflow 
	if (e < 0) {
		uint64_t h = 1<<(4*-e - 1);
		m = m / (2*h) + (m & h && m & (3*h-1) ? 1 : 0);
		e = 0;
	}
	return (((uint64_t)e)<<56 | m);

#endif 

} 


