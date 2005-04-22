#include <octave/oct.h>
DEFUN_DLD (sumskipnan, args, ,"OCT-implementation of SUMSKIPNAN\n") 
//   OCT implementation of SUMSKIPNAN - this function is part of the NaN-toolbox. 
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
// sumskipnan: sums all non-NaN values
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
// Y = sumskipnan(x [,DIM])
// [Y,N,SSQ] = sumskipnan(x [,DIM])
// 
// DIM	dimension
//	1 sum of columns
//	2 sum of rows
//	default or []: first DIMENSION with more than 1 element
//
// Y	resulting sum
// N	number of valid (not missing) elements
// SSQ	sum of squares
//
//	$Id$
//    Copyright (C) 2005 by Alois Schloegl <a.schloegl@ieee.org>	
//    This is part of the NaN-toolbox 
//    http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/


{ 
#define ND 2
  int DIM = 0;  
  int j, k1, k2, k3, D1, D2, D3;
  int SZ[ND+1], SZ2[ND+1];
  double aux,s,n,s2,s4;

  octave_value_list retval; 

  if ( args.length() == 2 ) 
  {
	  Matrix xin2( args(1).matrix_value() );
	  DIM = (int)xin2(0);
  }
  else if ( args.length() > 2 ) 
  {
    error("this version of matrixdemo only takes one argument");
    return retval;
  }
  
  warning("SUMSKIPNAN.OCT supports only real double matrices.\n");
  
    	for (j = 0; (DIM < 1) && (j < ND); j++) 
		if (SZ[j]>1) DIM = j+1;

  	if (DIM < 1) DIM=1;		// in case DIM is still undefined 
	
	if ((DIM != 1) & (DIM !=2))
		error("SUMSKIPNAN.OCT: DIM must be 1 or 2.\n");

	// only real double matrices are supported; arrays, integer or complex matrices are not supported (yet)
  	Matrix xin1( args(0).matrix_value() );
  	SZ[0] = xin1.rows();
  	SZ[1] = xin1.cols();

	for (j=0; j<ND; j++)		// copy size of input;  
		SZ2[j] = SZ[j]; 	

  	SZ2[DIM-1] = 1;

   	for (j=0, D1=1; j<DIM-1; D1=D1*SZ2[j++]); 	// D1 is the number of elements between two elements along dimension  DIM  
	D2 = SZ[DIM-1];		// D2 contains the size along dimension DIM 	
    	for (j=DIM, D3=1;  j<ND; D3=D3*SZ2[j++]); 	// D3 is the number of blocks containing D1*D2 elements 

	
	// Currently, only matrices (2D-arrays) are supported. In future, also N-D arrays should be supported. 
  	Matrix xout1(SZ2[0],SZ2[1]);
  	Matrix xout2(SZ2[0],SZ2[1]);
  	Matrix xout3(SZ2[0],SZ2[1]);
//  	Matrix xout4(SZ2[0],SZ2[1]);

	// OUTER LOOP: along dimensions > DIM
	for (k3 = 0; k3<D3; k3++) 	
    	{
		// Inner LOOP: along dimensions < DIM
		for (k1 = 0; k1<D1; k1++) 	
		{
		  	s  = 0;
		  	n  = 0;
		  	s2 = 0;
//		  	s4 = 0;
		
			// LOOP  along dimension DIM
	    		for (k2=0; k2<D2; k2++) 	
			{
				// this is an ugly solution, 
				// to avoid this case check, one needs to know the memory layout of Matrix/Array
				if (DIM==1)
					aux = xin1(k2,k3);
				else // if (DIM==2)
					aux = xin1(k1,k2);
				
					
				if (aux==aux)	// test for NaN
				{ 
					s   += aux; 
					n++; 
					aux *= aux;
					s2  += aux; 
//					s4  += aux*aux; 
				}	
 			}
			xout1(k1,k3) = s;
			xout2(k1,k3) = n;
			xout3(k1,k3) = s2;
//			xout4(k1,k3) = s4;
		}
  	}  
  	retval.append(octave_value(xout1));
  	retval.append(octave_value(xout2));
  	retval.append(octave_value(xout3));
//  	retval.append(octave_value(xout4));
}

