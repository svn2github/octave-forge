/* -*- coding: utf-8 -*- */
/* Copyright (C) 2009  José Luis García Pallero, <jgpallero@gmail.com>
 *
 * This file is part of OctPROJ.
 *
 * OctPROJ is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
/******************************************************************************/
/******************************************************************************/
#define HELPTEXT "\
-*- texinfo -*-\n\
@deftypefn{Loadable Function}{[@var{X},@var{Y},@var{Z}] =}\
_op_geod2geoc(@var{lon},@var{lat},@var{h},@var{a},@var{e2})\n\
\n\
@cindex Geodetic to geocentric coordinates.\n\
\n\
This function converts geodetic coordinates into cartesian tridimensional\n\
geocentric coordinates using the PROJ.4 function pj_geodetic_to_geocentric().\n\
\n\
@var{lon} is a column vector containing the geodetic longitude, in radians.\n\
@var{lat} is a column vector containing the geodetic latitude, in radians.\n\
@var{h} is a column vector containing the ellipsoidal height.\n\
@var{a} is a scalar containing the semi-major axis of the ellipsoid.\n\
@var{e2} is a scalar containing the squared first eccentricity of the \
ellipsoid.\n\
\n\
The coordinate vectors @var{lon}, @var{lat} and @var{h} must be all scalars\n\
or all column vectors (of the same size).\n\
The units of @var{h} and @var{a} must be the same.\n\
\n\
@var{X} is a column vector containing the X geocentric coordinate, in the same \
units of @var{a}.\n\
@var{Y} is a column vector containing the Y geocentric coordinate, in the same \
units of @var{a}.\n\
@var{Z} is a column vector containing the Z geocentric coordinate, in the same \
units of @var{a}.\n\
@seealso{_op_geoc2geod}\n\
@end deftypefn"
/******************************************************************************/
/******************************************************************************/
#include<octave/oct.h>
#include<proj_api.h>
#include<cstring>
#include<cstdlib>
/******************************************************************************/
/******************************************************************************/
#define ERRORTEXT 1000
/******************************************************************************/
/******************************************************************************/
DEFUN_DLD(_op_geod2geoc,args,,HELPTEXT)
{
    //error message
    char errorText[ERRORTEXT]="_op_geod2geoc:\n\t";
    //output list
    octave_value_list outputList;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //checking input arguments
    if(args.length()!=5)
    {
        //error text
        sprintf(&errorText[strlen(errorText)],
                "Incorrect number of input arguments\n\t"
                "See help _op_geod2geoc");
        //error message
        error(errorText);
    }
    else
    {
        //error code
        int* idError=NULL;
        //loop index
        size_t i=0;
        //geodetic coordinates
        ColumnVector lon=args(0).column_vector_value();
        ColumnVector lat=args(1).column_vector_value();
        ColumnVector h=args(2).column_vector_value();
        //ellipsoidal parameters
        double a=args(3).double_value();
        double e2=args(4).double_value();
        //number of elements
        size_t nElem=static_cast<size_t>(lon.rows());
        //geocentric coordinates
        ColumnVector xOut(nElem);
        ColumnVector yOut(nElem);
        ColumnVector zOut(nElem);
        //computation vectors
        double* x=NULL;
        double* y=NULL;
        double* z=NULL;
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //copy input data
        for(i=0;i<nElem;i++)
        {
            xOut(i) = lon(i);
            yOut(i) = lat(i);
            zOut(i) = h(i);
        }
        //pointers to output data
        x = xOut.fortran_vec();
        y = yOut.fortran_vec();
        z = zOut.fortran_vec();
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //transformation
        if(pj_geodetic_to_geocentric(a,e2,nElem,1,x,y,z))
        {
            //get error code
            idError = pj_get_errno_ref();
            //error text
            sprintf(&errorText[strlen(errorText)],"%s",pj_strerrno(*idError));
            //error message
            error(errorText);
            //exit
            return outputList;
        }
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //output parameters list
        outputList(0) = xOut;
        outputList(1) = yOut;
        outputList(2) = zOut;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    return outputList;
}
