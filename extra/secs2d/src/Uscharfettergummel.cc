/*
  % This file is part of 
  %
  %            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
  %         -------------------------------------------------------------------
  %            Copyright (C) 2004-2006  Carlo de Falco
  %
  %
  %
  %  SECS2D is free software; you can redistribute it and/or modify
  %  it under the terms of the GNU General Public License as published by
  %  the Free Software Foundation; either version 2 of the License, or
  %  (at your option) any later version.
  %
  %  SECS2D is distributed in the hope that it will be useful,
  %  but WITHOUT ANY WARRANTY; without even the implied warranty of
  %  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %  GNU General Public License for more details.
  %
  %  You should have received a copy of the GNU General Public License
  %  along with SECS2D; if not, write to the Free Software
  %  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
  %  USA
*/

#include <iostream>
#include <octave/oct.h>
#include <octave/oct-map.h>
#include "Ubern.h"

////////////////////////////////////////////
//   Ufastscharfettergummel function
//   this function, though it does make use 
//   of liboctave, is not an octave command
//   the wrapper to make the command is defined
//   below
////////////////////////////////////////////



int Uscharfettergummel(const Octave_map &mesh, 
                       const ColumnVector &v, 
                       const ColumnVector &acoeff, 
                       SparseMatrix &SG )
{
  
  
  double area = 0.0, Lloc[9],bp01,bp02,bp12,bm01,bm02,bm12;
  
  Matrix p             = mesh.contents("p")(0).matrix_value();
  Matrix t             = mesh.contents("t")(0).matrix_value();
  Matrix e             = mesh.contents("e")(0).matrix_value();
  Array<double> wjacdet= mesh.contents("wjacdet")(0).array_value();
  Array<double> shg    = mesh.contents("shg")(0).array_value();
  
  octave_idx_type Nnodes            =  p.columns();
  octave_idx_type Nelements         =  t.columns();
  octave_idx_type Nsides            =  e.columns();
  
  const double *pdata       = p.data();
  const double *tdata       = t.data();
  const double *wjacdetdata = wjacdet.data();
  const double *shgdata     = shg.data();
  
  ColumnVector I(Nelements*9);
  ColumnVector J(Nelements*9);
  ColumnVector V(Nelements*9);
  
  octave_idx_type counter=0,iglob[3];
  
  for (int iel=0; iel<Nelements; iel++)
    {
      area = 0.0;
      for (int k = 0; k < 3; k++){
	area += wjacdetdata[iel*3 + k];
	iglob[k] = octave_idx_type (tdata[k+iel*4])-1;
      }
      area *= (acoeff.data())[iel];
      
      for (int inode = 0; inode < 3; inode++)
	for (int jnode = 0; jnode < 3; jnode++)
	  Lloc[jnode+inode*3] = 0.0;
      
      for (int inode = 0; inode < 3; inode++)
	{
	  for (int jnode = inode; jnode < 3; jnode++)
	    {
	      for(int k = 0; k < 2; k++){
		Lloc[jnode+inode*3] += shgdata[k+inode*2+iel*3*2]*shgdata[k+jnode*2+iel*3*2]*area;
		if (inode != jnode)
		  Lloc[inode+jnode*3] = Lloc[jnode+inode*3];
	      }
	    }
	  
	}
      
      Ubern(v(iglob[1])-v(iglob[0]),bp01,bm01);
      Ubern(v(iglob[2])-v(iglob[0]),bp02,bm02);
      Ubern(v(iglob[2])-v(iglob[1]),bp12,bm12);	
      
      
      bp01 = bp01*Lloc[1];
      bm01 = bm01*Lloc[1];
      bp02 = bp02*Lloc[2];
      bm02 = bm02*Lloc[2];
      bp12 = bp12*Lloc[2+1*3];
      bm12 = bm12*Lloc[2+1*3];
      
      Lloc[0] = -bm01-bm02;
      Lloc[1] = bp01;
      Lloc[2] = bp02;
      
      Lloc[1*3]   = bm01;
      Lloc[1*3+1] = -bp01-bm12; 
      Lloc[1*3+2] = bp12;
      
      Lloc[2*3]   = bm02;
      Lloc[2*3+1] = bm12;
      Lloc[2*3+2] = -bp02-bp12;
      
      for (int inode = 0; inode < 3; inode++)
	{
	  for (int jnode = 0; jnode < 3; jnode++)
	    {
	      I(counter)=iglob[inode];
	      J(counter)=iglob[jnode]; 
	      V(counter++)= Lloc[inode*3 + jnode];
	    }
	}
    }
  
  
  SG = SparseMatrix(V,I,J,Nnodes,Nnodes,true);
  return 0;
}


////////////////////////////////////
//   WRAPPER
////////////////////////////////////
// DEFUN_DLD and the macros that it 
// depends on are defined in the
// files defun-dld.h, defun.h,
// and defun-int.h.
//
// Note that the third parameter 
// (nargout) is not used, so it is
// omitted from the list of arguments 
// to DEFUN_DLD in order to avoid
// the warning from gcc about an 
// unused function parameter. 
////////////////////////////////////

DEFUN_DLD (Uscharfettergummel, args, ,
	   "  SG=Ufastscharfettergummel(mesh,v,acoeff)\n \
\n \
\n \
Builds the Scharfetter-Gummel  matrix for the \n \
the discretization of the LHS \n \
of the Drift-Diffusion equation:\n \
\n \
$ -\\div (a(x) (\\grad u -  u \\grad v'(x) ))= f $\n \
\n \
where a(x) is piecewise constant\n \
and v(x) is piecewise linear, so that \n \
v'(x) is still piecewise constant\n \
b is a constant independent of x\n \
and u is the unknown\n \
")
{
  // The list of values to return.  See the declaration in oct-obj.h
  octave_value_list retval;

  ColumnVector v=ColumnVector(args(1).vector_value()),
    acoeff=ColumnVector(args(2).vector_value());


  Octave_map mesh = args(0).map_value();

  SparseMatrix SG;

                
  Uscharfettergummel(mesh,v, acoeff, SG);


  retval(0) = octave_value( SG );

  return retval;
}
