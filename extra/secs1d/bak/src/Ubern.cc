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
%  along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
*/

#include <iostream>
#include <octave/oct.h>

////////////////////////////////////////////
//   Ubern function
//   this function, though it does make use 
//   of liboctave, is not an octve command
//   the wrapper to make the command is defined
//   below
////////////////////////////////////////////


int Ubern(const double x, double &bp, double &bn )
{

double xlim=1e-2;
int ii;
double fp,fn,df,segno;
double ax;

ax=fabs(x);


if (ax == 0.0) {
bp=1.;
bn=1.;
goto theend ;
}

if (ax > 80.0){
if (x >0.0){
  bp=0.0;
  bn=x;
  goto theend ;
}else{
  bp=-x;
  bn=0.0;
  goto theend ;
}
}

if (ax > xlim){
bp=x/(exp(x)-1.0);
bn=x+bp;
goto theend ;
}

ii=1;
fp=1.0;fn=1.0;df=1.0;segno=1.0;
while (fabs(df) > 2.2204e-16){
ii++;
segno= -segno;
df=df*x/ii;
fp=fp+df;
fn=fn+segno*df;
bp=1/fp;
bn=1/fn;
}


theend:
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

DEFUN_DLD (Ubern, args, ,
" [bp,bn]=Ubern(x)\n \
computes Bernoulli function\n \
B(x)=x/(exp(x)-1) corresponding to \n \
to input values Z and -Z, recalling that\n \
B(-Z)=Z+B(Z)\n")
{
  // The list of values to return.  See the declaration in oct-obj.h
  octave_value_list retval;


  NDArray X ( args(0).array_value() );
  octave_idx_type lx = X.length();

  NDArray BP(X),BN(X);  
 
  for (octave_idx_type jj=0; jj<lx; jj++)
    Ubern(X(jj),BP(jj),BN(jj));

  retval (0) = BP;
  retval (1) = BN;
  
  return retval	;
  
}

