//-------------------------------------------------------------------
#pragma hdrstop
//-------------------------------------------------------------------
//   C-MEX implementation of SUMSKIPNAN - this function is part of the NaN-toolbox. 
//
//   This program is free software; you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation; either version 2 of the License, or
//   (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with this program; if not, write to the Free Software
//   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//
// sumskipnan2: sums all non-NaN values
//
// Input:
// - array to sum
// - dimension to sum (1=columns; 2=rows; doesn't work for dim>2!!)
//
// Output:
// - sums
// - count of valid elements (optional)
// - sums of squares (optional)
// - sums of squares of squares (optional)
//
// Author:  Patrick Houweling (phouweling@yahoo.com)
// Version: 1.0
// Date:    17 september 2003
//
// modified:
//   Alois Schloegl <a.schloegl@ieee.org>    
// 	$Revision$
// 	$Id$
//
//-------------------------------------------------------------------
//#include <stdlib>
#include "mex.h"
//-------------------------------------------------------------------
void mexFunction(int POutputCount,  mxArray* POutput[], int PInputCount, const mxArray *PInputs[])
{
    const int	*SZ;	    
    double* LInput;
    double* LInputI;
    double* LOutputSum;
    double* LOutputSumI;
    double* LOutputCount;
    double* LOutputSum2;
    double* LOutputSum4;
    double  x, x2;
    unsigned long   LCount, LCountI;
    double  LSum, LSum2, LSum4;

    unsigned		DIM = 1; 
    unsigned long	D1, D2, D3; 	// NN; 	//  	
    unsigned    	ND, ND2;	// number of dimensions: input, output
    unsigned long	ix1, ix2;	// index to input and output

    unsigned    	j, k, l;	// running indices 
    int 		*SZ2;		// size of output 	    

     	

    // check for proper number of input and output arguments
    if ((PInputCount <= 0) || (PInputCount > 2))
        mexErrMsgTxt("SumSkipNan2 requires 1 or 2 arguments.");
    if (POutputCount > 4)
        mexErrMsgTxt("SumSkipNan2 has 1 to 4 output arguments.");

    // get 1st argument
    if(!mxIsNumeric(PInputs[0]))
	mexErrMsgTxt("First argument must be NUMERIC.");
    if(!mxIsDouble(PInputs[0]))
	mexErrMsgTxt("First argument must be DOUBLE.");
    if(mxIsComplex(PInputs[0]) & (POutputCount > 2))
	mexErrMsgTxt("More than 2 output arguments only supported for REAL data ");
    LInput  = mxGetPr(PInputs[0]);
    LInputI = mxGetPi(PInputs[0]);

    // get 2nd argument
    if  (PInputCount == 2){
        if ((!mxIsNumeric(PInputs[1])) || (mxGetM(PInputs[1]) != 1) || (mxGetN(PInputs[1]) != 1))
            mexErrMsgTxt("Second argument must be scalar.");
        DIM = (unsigned)(mxGetScalar(PInputs[1]));
    }

    	ND = mxGetNumberOfDimensions(PInputs[0]);	
    	// NN = mxGetNumberOfElements(PInputs[0]);
    	SZ = mxGetDimensions(PInputs[0]);		

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

	if(mxIsComplex(PInputs[0]))
	{	POutput[0] = mxCreateNumericArray(ND2, SZ2, TYP, mxCOMPLEX);
		LOutputSum = mxGetPr(POutput[0]);
		LOutputSumI= mxGetPi(POutput[0]);
    	}
	else
	{	POutput[0] = mxCreateNumericArray(ND2, SZ2, TYP, mxREAL);
		LOutputSum = mxGetPr(POutput[0]);
    	}
    	if (POutputCount >= 2){
		POutput[1] = mxCreateNumericArray(ND2, SZ2, TYP, mxREAL);
        	LOutputCount = mxGetPr(POutput[1]);
    	}
    	if (POutputCount >= 3){
		POutput[2] = mxCreateNumericArray(ND2, SZ2, TYP, mxREAL);
        	LOutputSum2  = mxGetPr(POutput[2]);
    	}
    	if (POutputCount >= 4){
		POutput[3] = mxCreateNumericArray(ND2, SZ2, TYP, mxREAL);
        	LOutputSum4  = mxGetPr(POutput[3]);
    	}

	// OUTER LOOP: along dimensions > DIM
	for (l = 0; l<D3; l++) 	
    	{
		ix2 =   l*D1;	// index for output 
		ix1 = ix2*D2;	// index for input 

		// Inner LOOP: along dimensions < DIM
		for (k = 0; k<D1; k++, ix1++, ix2++) 	
		{
		        LCount = 0;
			LSum   = 0.0;
			LSum2  = 0.0;
			LSum4  = 0.0;
	        	    		
			// LOOP  along dimension DIM
	    		for (j=0; j<D2; j++) 	
			{
				x = LInput[ix1 + j*D1];
        	        	if (!mxIsNaN(x))
				{
					LCount++; 
					LSum += x; 
					x2 = x*x;
					LSum2 += x2; 
					LSum4 += x2*x2; 
				}
			}
			LOutputSum[ix2] = LSum;
            		if (POutputCount >= 2)
                		LOutputCount[ix2] = (double)LCount;
            		if (POutputCount >= 3)
                		LOutputSum2[ix2] = LSum2;
            		if (POutputCount >= 4)
                		LOutputSum4[ix2] = LSum4;

			if(mxIsComplex(PInputs[0]))
			{
				LSum = 0.0;	
	    			LCountI = 0;
				for (j=0; j<D2; j++) 	
				{
					x = LInputI[ix1 + j*D1];
        	        		if (!mxIsNaN(x))
					{
						LCountI++; 
						LSum += x; 
					}
				}
				LOutputSumI[ix2] = LSum;
				if (LCount != LCountI)
			            	mexErrMsgTxt("Number of NaNs is different for REAL and IMAG part");
			}	
		}
	}
	mxFree(SZ2);    	
}


