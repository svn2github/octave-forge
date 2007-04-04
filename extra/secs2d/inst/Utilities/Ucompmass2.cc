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

////////////////////////////////////////////
//   Ucompmass2 function
//   this function, though it does make use 
//   of liboctave, is not an octave command
//   the wrapper to make the command is defined
//   below
////////////////////////////////////////////


int Ucompmass2(const Octave_map &mesh, 
                       const ColumnVector &acoeff,
                       const ColumnVector &bcoeff,
                       SparseMatrix &SG )
{


double area = 0.0, Lloc;

Matrix p             = mesh.contents("p")(0).matrix_value();
Matrix t             = mesh.contents("t")(0).matrix_value();
Array<double> wjacdet= mesh.contents("wjacdet")(0).array_value();

octave_idx_type Nnodes            =  p.columns();
octave_idx_type Nelements         =  t.columns();

const double *pdata       = p.data();
const double *tdata       = t.data();
const double *wjacdetdata = wjacdet.data();

ColumnVector V(Nnodes,0.0),I(Nnodes,0);

octave_idx_type iglob[3];
for (int iel=0; iel<Nelements; iel++)
{
area = 0.0;
for (int k = 0; k < 3; k++){
	iglob[k] = octave_idx_type (tdata[k+iel*4])-1;
}
	for (octave_idx_type inode = 0; inode < 3; inode++)
 			V(iglob[inode]) += wjacdetdata[iel*3+inode]*acoeff(iglob[inode])*bcoeff(iel);
}

for (octave_idx_type inode=0; inode<Nnodes; inode++)
	I(inode)=inode;
	
SG = SparseMatrix(V,I,I,Nnodes,Nnodes,true);
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

DEFUN_DLD (Ucompmass2, args, ,
"  L = Ucompmass2 (mesh,coeffn,coeffe)\n \
\n \
Builds the FEM  matrix for the \n \
the discretization of a zero order term")
{
// The list of values to return.  See the declaration in oct-obj.h
octave_value_list retval;

ColumnVector acoeff=ColumnVector(args(1).vector_value());
ColumnVector bcoeff=ColumnVector(args(2).vector_value());
Octave_map mesh = args(0).map_value();

SparseMatrix SG;
                
Ucompmass2(mesh, acoeff, bcoeff, SG);

retval(0) = octave_value( SG );

return retval;
}
