// Copyright (C) 2002 Andreas Stahel
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

// Author:   <Andreas.Stahel@hta-bi.bfh.ch>

#include <iostream>
#include <fstream>
#include <cmath>
#include <string>

#include <octave/oct.h>
#include <octave/parse.h>
#include <octave/lo-ieee.h>
#ifndef OCTAVE_QUIT
# define OCTAVE_QUIT do {} while (0)
#endif
#ifdef USE_OCTAVE_NAN
#define lo_ieee_nan_value() octave_NaN
#endif

inline double max(double a, double b, double c)
{
  if (a < b) return ( b < c ? c : b );
  else return ( a < c ? c : a );
}

inline double min(double a, double b, double c)
{
  if (a > b) return ( b > c ? c : b );
  else return ( a > c ? c : a );
}

#define REF(x,k,i) x(int(elem(k,i))-1)

DEFUN_DLD (tsearch, args, nargout, "\
idx = tsearch(x,y,t,xi,yi)\n\
For t=delaunay(x,y), finds the index in t containing the points (xi,yi).\n\
For points outside the convex hull, idx is NaN.")
{
  const double eps=1.0e-12;

  octave_value_list retval;
  const int nargin = args.length ();
  if ( nargin != 5 ) {
    print_usage ("tsearch");
    return retval;
  }
  
  const ColumnVector x(args(0).vector_value());
  const ColumnVector y(args(1).vector_value());
  const Matrix elem(args(2).matrix_value());
  const ColumnVector xi(args(3).vector_value());
  const ColumnVector yi(args(4).vector_value());

  if (error_state) return retval;

  const int nelem = elem.rows();

  ColumnVector minx(nelem);
  ColumnVector maxx(nelem);
  ColumnVector miny(nelem);
  ColumnVector maxy(nelem);
  for(int k=0; k<nelem; k++) {
    minx(k)=min(REF(x,k,0),REF(x,k,1),REF(x,k,2))-eps;
    maxx(k)=max(REF(x,k,0),REF(x,k,1),REF(x,k,2))+eps;
    miny(k)=min(REF(y,k,0),REF(y,k,1),REF(y,k,2))-eps;
    maxy(k)=max(REF(y,k,0),REF(y,k,1),REF(y,k,2))+eps;
  }

  const int np = xi.length();
  ColumnVector values(np);

  double x0=0.0, y0=0.0;
  double a11=0.0, a12=0.0, a21=0.0, a22=0.0, det=0.0;

  int k = nelem; // k is a counter of elements
  for(int kp=0; kp<np; kp++) {
    const double xt = xi(kp); 
    const double yt = yi(kp);
    
    // check if last triangle contains the next point
    if (k < nelem) { 
      const double dx1 = xt - x0;
      const double dx2 = yt - y0;
      const double c1=( a22*dx1-a21*dx2)/det;
      const double c2=(-a12*dx1+a11*dx2)/det;
      if ( c1>=-eps && c2>=-eps && (c1+c2)<=(1+eps) ) {
	values(kp) = double(k+1);
	continue;
      }
    }
    
    // it doesn't, so go through all elements
    for (k = 0; k < nelem; k++) { 
      OCTAVE_QUIT;
      if ( xt>=minx(k) && xt<=maxx(k) && yt>=miny(k) && yt<=maxy(k) ) {
	// element inside the minimum rectangle: examine it closely
	x0  = REF(x,k,0);
	y0  = REF(y,k,0);
	a11 = REF(x,k,1)-x0;
	a12 = REF(y,k,1)-y0;
	a21 = REF(x,k,2)-x0;
	a22 = REF(y,k,2)-y0;
	det = a11*a22-a21*a12;
	
	// solve the system
	const double dx1=xt-x0;
	const double dx2=yt-y0;
	const double c1=( a22*dx1-a21*dx2)/det;
	const double c2=(-a12*dx1+a11*dx2)/det;
	if ((c1>=-eps) && (c2>=-eps) && ((c1+c2)<=(1+eps))) {
	  values(kp) = double(k+1);
	  break;
	}
      } //endif # examine this element closely
    } //endfor # each element

    if (k == nelem) values(kp) = lo_ieee_nan_value ();
    
  } //endfor # kp
  
  retval(0)=values;
  
  return retval;
}

// for large data set the algorithm is very slow
// one should presort (how?) either the elements of the points of evaluation
// to cut down the time needed to decide which triangle contains the 
// given point 

// e.g., build up a neighbouring triangle structure and use a simplex-like
// method to traverse it
