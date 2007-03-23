/* Copyright (C) 2006 Charalampos C. Tsimenidis

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#include <octave/oct.h>
#include <octave/ov-fcn.h>

DEFUN_DLD (genqamdemod, args, ,
 "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y}  = } genqamdemod (@var{x}, @var{C})\n\
General quadrature amplitude demodulation. The complex envelope quadrature amplitude\n\
modulated signal @var{x}@ is demodulated using a constellation mapping specified by \n\
the 1D vector @var{C}.@\n\
@end deftypefn")

{
octave_value retval;
int i, j, m;
double tmp1, tmp2;	

if (args.length()<2)
{
  print_usage ();
  return retval;
}

int nr1 (args(0).rows()); 
int nc1 (args(0).columns()); 
int arg_is_empty1=empty_arg("genqamdemod", nr1, nc1); 
Matrix y(nr1,nc1); 

int nr2 (args(1).rows()); 
int nc2 (args(1).columns());
int M=(nr2>nc2)?nr2:nc2;

if (arg_is_empty1 < 0)
    return retval;
if (arg_is_empty1 > 0)
    return octave_value (Matrix ());

if (args(0).is_real_type() && args(1).is_real_type()) 
{ // Real-valued signal & constellation
	Matrix x(args(0).matrix_value());
	ColumnVector constellation(args(1).vector_value());
	for (i=0;i<nr1;i++)
	{
		for (j=0;j<nc1;j++)	
		{
			tmp1=fabs(x(i,j)-constellation(0));
			y(i,j)=0;
			for (m=1;m<M;m++)
			{				
				tmp2=fabs(x(i,j)-constellation(m));
				if (tmp2<tmp1)
				{
				   y(i,j)=m;
				   tmp1=tmp2;
				}
			}
		}
	}
} 
else if (args(0).is_complex_type() && args(1).is_complex_type())
{ // Complex-valued input & constellation
	ComplexMatrix x (args(0).complex_matrix_value());
	ComplexColumnVector constellation(args(1).complex_vector_value());
	for (i=0;i<nr1;i++)
	{
		for (j=0;j<nc1;j++)	
		{
			tmp1=abs(x(i,j)-constellation(0));
			y(i,j)=0;
			for (m=1;m<M;m++)
			{				
				tmp2=abs(x(i,j)-constellation(m));
				if (tmp2<tmp1)
				{
				   y(i,j)=m;
				   tmp1=tmp2;
				}
					
			}
		}
	}
}
else 
{
  print_usage ();
}
return retval=y;
}
