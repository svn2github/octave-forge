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
//
// References:
// [1]	TS-140 THE RECORD LAYOUT OF A DATA SET IN SAS TRANSPORT (XPORT) FORMAT
//	http://support.sas.com/techsup/technote/ts140.html
// [2] IBM floating point format 
//	http://en.wikipedia.org/wiki/IBM_Floating_Point_Architecture
//-------------------------------------------------------------------


#define TEST_CONVERSION 2  // 0: ieee754, 1: SAS converter (big endian bug), 2: experimental
#define DEBUG 0

#include <ctype.h>
#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "mex.h"

#if 0
#define malloc(a) mxMalloc(a)
#define calloc(a,b) mxCalloc(a,b)
#define realloc(a,b) mxRealloc(a,b)
#define free(a) mxFree(a)
#endif 

#ifdef tmwtypes_h
  #if (MX_API_VER<=0x07020000)
    typedef int mwSize;
    typedef int mwIndex;
  #endif 
#endif 


#define max(a,b)	(((a) > (b)) ? (a) : (b))


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


struct REAL_HEADER {
  char sas_symbol[2][8];
  char saslib[8];
  char sasver[8];
  char sas_os[8];
  char blanks[24];
  char sas_create[16];
};

struct SAS_XPORT_header {
  char sas_symbol[2][8];	/* should be "SAS     " */
  char saslib[8];		/* should be "SASLIB  " */
  char sasver[8];
  char sas_os[8];
  char sas_create[16];
  char sas_mod[16];
};

struct SAS_XPORT_member {
  char sas_symbol[8];
  char sas_dsname[8];
  char sasdata[8];
  char sasver[8];
  char sas_osname[8];
  char sas_create[16];
  char sas_mod[16];
};

struct SAS_XPORT_namestr {
    short   ntype;              /* VARIABLE TYPE: 1=NUMERIC, 2=CHAR    */
    short   nhfun;              /* HASH OF NNAME (always 0)            */
    short   nlng;               /* LENGTH OF VARIABLE IN OBSERVATION   */
    short   nvar0;              /* VARNUM                              */
    char    nname[8];		/* NAME OF VARIABLE                    */
    char    nlabel[40];		/* LABEL OF VARIABLE                   */
    char    nform[8];		/* NAME OF FORMAT                      */
    short   nfl;                /* FORMAT FIELD LENGTH OR 0            */
    short   nfd;                /* FORMAT NUMBER OF DECIMALS           */
    short   nfj;                /* 0=LEFT JUSTIFICATION, 1=RIGHT JUST  */
    char    nfill[2];           /* (UNUSED, FOR ALIGNMENT AND FUTURE)  */
    char    niform[8];		/* NAME OF INPUT FORMAT                */
    short   nifl;               /* INFORMAT LENGTH ATTRIBUTE           */
    short   nifd;               /* INFORMAT NUMBER OF DECIMALS         */
    int     npos;               /* POSITION OF VALUE IN OBSERVATION    */
    char    rest[52];           /* remaining fields are irrelevant     */
};

#if TEST_CONVERSION==1
void xpt2ieee(unsigned char *xport, unsigned char *ieee);
void ieee2xpt(unsigned char *ieee, unsigned char *xport);
int  cnxptiee(unsigned char *from, int fromtype, unsigned char *to, int totype);
#elif TEST_CONVERSION==2
double xpt2d(uint64_t x);
uint64_t d2xpt(double x);
#endif 

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
	char   *Mode = "r"; 
	FILE   *fid; 	
	size_t count = 0, NS = 0, HeadLen1=80*8, HeadLen2=0, sz2 = 0;
	char   H1[HeadLen1];
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
		return;
	}
	if ( PInputCount > 1) 
	if (mxGetClassID(PInputs[1])==mxCHAR_CLASS && mxGetNumberOfElements(PInputs[1])) {
		Mode = (char*)mxGetData(PInputs[1]);
	}
	
	fid = fopen(fn,Mode);
	if (fid < 0) {
	        mexErrMsgTxt("Error XPTOPEN: cannot open file\n");
	}	

#if 0 //DEBUG
	double f1 = -118.625, f2;
	uint64_t u1,u2; 
	u1 = d2xpt(-118.625); 
	f2 = xpt2d(u1);
	mexPrintf("%f\t%016Lx\t%016Lx\t%f\n",f1,u1,u1,f2);
	u1 = d2xpt(+118.625); 
	f2 = xpt2d(u1);
	mexPrintf("%f\t%016Lx\t%016Lx\t%f\n",f1,u1,u1,f2);
//	mexPrintf("%f  %x \n", −118.625, d2xpt(−118.625) );
	
return;	
#endif

	if (Mode[0]=='r' || Mode[0]=='a' ) {

		/* TODO: sanity checks */

		count += fread(H1,1,80*8,fid);		

		char tmp[5]; 
		memcpy(tmp,H1+7*80+54,4); 
		tmp[4]=0;
		NS = atoi(tmp);
		
		char *tmp2;
		sz2 = strtoul(H1+4*80-6, &tmp2, 10); 
		 
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
		
		size_t M = szData/recsize; 			

		mxArray **R = (mxArray**) malloc(NS*sizeof(mxArray*));
		const char **ListOfVarNames = (const char**)malloc(NS * sizeof(char*)); 
		char *VarNames = (char*)malloc(NS * 9);

		for (size_t k = 0; k < NS; k++) {
			size_t maxlen = b_endian_u16(*(int16_t*)(H2+k*sz2+4));

			ListOfVarNames[k] = VarNames+pos;
			int n = k*sz2+8;
			do {
				VarNames[pos++] = H2[n];	
			} while (isalnum(H2[++n]));	
			
			VarNames[pos++] = 0;

			if ((*(int16_t*)(H2+k*sz2)) == b_endian_u16(1) && (*(int16_t*)(H2+k*sz2+4)) == b_endian_u16(8) ) {
				R[k] = mxCreateDoubleMatrix(M, 1, mxREAL); 				
				for (size_t m=0; m<M; m++) {
					double d;
#if TEST_CONVERSION==0
					d = *(double*)(Data+m*recsize+POS);
#elif TEST_CONVERSION==1
					// FIXME: 
					xpt2ieee(Data+m*recsize+POS,(unsigned char*)&d);
#elif TEST_CONVERSION==2
					d = xpt2d(b_endian_u64(*(uint64_t*)(Data+m*recsize+POS)));
#endif
					*(mxGetPr(R[k])+m) = d;
				} 
			}
			else if ((*(int16_t*)(H2+k*sz2)) == b_endian_u16(2)) {
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
		
	}

//	if (Mode[0]=='w' || Mode[0]=='a' ) {
	if (Mode[0]=='w') {
	
		NS += mxGetNumberOfFields(PInputs[2]);	

		// generate default (fixed) header	
		if (Mode[0]=='w') {
			memset(H1,' ',80*8);
			memcpy(H1,L1,strlen(L1));
			memcpy(H1+80,L2,strlen(L2));

			memcpy(H1+80*3,L4,strlen(L4));
			memcpy(H1+80*4,L5,strlen(L5));
			memcpy(H1+80*5,L6,strlen(L6));

			memcpy(H1+80*7,L8,strlen(L8));
		}
		
		time_t t;
		time(&t); 
		char tt[20];
		strftime(tt, 17, DATEFORMAT, localtime(&t));
		memcpy(H1+80*2-16,tt,16);		
		memcpy(H1+80*2,tt,16);		
		memcpy(H1+80*6-16,tt,16);		
		memcpy(H1+80*6,tt,16);		
		 
		char tmp[17];
		sprintf(tmp,"%04i", NS);	// number of variables 
		memcpy(H1+80*7+54, tmp, 4);
		
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

		count  = fwrite(H1, 1, HeadLen1, fid);
		count += fwrite(H2, 1, HeadLen2, fid);
		/* write OBS header line */
		count += fwrite(LO, 1, strlen(LO), fid);
		for (mwIndex m = 0; m < M; m++) {
			for (int16_t k = 0; k < NS; k++) {

				if (*(int16_t*)(H2+k*sz2) == b_endian_u16(1)) {
					// numeric
#if TEST_CONVERSION==0
					double d = *(double*)(mxGetPr(F[k])+m);
					count += fwrite((void*)&d, 1, 8, fid);
#elif  TEST_CONVERSION==1
					// FIXME: 
					unsigned char temp[9];
					ieee2xpt((unsigned char *)(mxGetPr(F[k])+m), temp);
					count += fwrite(temp, 1, 8, fid);
#elif  TEST_CONVERSION==2
					uint64_t u64 = b_endian_u64(d2xpt(*(mxGetPr(F[k])+m)));
					count += fwrite(&u64, 1, 8, fid);
#endif
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

	const double NaN = 0.0/0.0;
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


