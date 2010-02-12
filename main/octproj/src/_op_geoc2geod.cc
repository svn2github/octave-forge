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
@deftypefn{Loadable Function}{[@var{lon},@var{lat},@var{h}] =}\
_op_geod2geoc(@var{X},@var{Y},@var{Z},@var{a},@var{e2})\n\
\n\
@cindex Geocentric to geodetic coordinates.\n\
\n\
This function converts cartesian tridimensional geodentric coordinates into \n\
geodetic using the PROJ.4 function pj_geocentric_to_geodetic().\n\
\n\
@var{X} is a column vector containing the X geocentric coordinate.\n\
@var{Y} is a column vector containing the Y geocentric coordinate.\n\
@var{Z} is a column vector containing the Z geocentric coordinate.\n\
@var{a} is a scalar containing the semi-major axis of the ellipsoid.\n\
@var{e2} is a scalar containing the squared first eccentricity of the \
ellipsoid.\n\
\n\
The coordinate vectors @var{X}, @var{Y} and @var{Z} must be all scalars or\n\
all column vectors (of the same size).\n\
The units of @var{X}, @var{Y}, @var{Z} and @var{a} must be the same.\n\
\n\
@var{lon} is a column vector containing the geodetic longitude, in radians.\n\
@var{lat} is a column vector containing the geodetic latitude, in radians.\n\
@var{h} is a column vector containing the ellipsoidal height, in the same\n\
units of @var{a},\n\
@seealso{_op_geod2geoc}\n\
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
DEFUN_DLD(_op_geoc2geod,args,,HELPTEXT)
{
    //error message
    char errorText[ERRORTEXT]="_op_geoc2geod:\n\t";
    //output list
    octave_value_list outputList;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //testing input parameters
    if(args.length()!=5)
    {
        //error text
        sprintf(&errorText[strlen(errorText)],
                "Incorrect number of input arguments\n\t"
                "See help _op_geoc2geod");
        //error message
        error(errorText);
    }
    else
    {
        //error code
        int* idError=NULL;
        //loop index
        size_t i=0;
        //geocentric coordinates
        ColumnVector x=args(0).column_vector_value();
        ColumnVector y=args(1).column_vector_value();
        ColumnVector z=args(2).column_vector_value();
        //ellipsoidal parameters
        double a=args(3).double_value();
        double e2=args(4).double_value();
        //number of elements
        size_t nElem=static_cast<size_t>(x.rows());
        //geodetic coordinates
        ColumnVector latOut(nElem);
        ColumnVector lonOut(nElem);
        ColumnVector hOut(nElem);
        //computation vectors
        double* lat=NULL;
        double* lon=NULL;
        double* h=NULL;
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //copy input data
        for(i=0;i<nElem;i++)
        {
            lonOut(i) = x(i);
            latOut(i) = y(i);
            hOut(i) = z(i);
        }
        //pointers to data
        lat = latOut.fortran_vec();
        lon = lonOut.fortran_vec();
        h = hOut.fortran_vec();
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //transformation
        if(pj_geocentric_to_geodetic(a,e2,nElem,1,lon,lat,h))
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
        outputList(0) = lonOut;
        outputList(1) = latOut;
        outputList(2) = hOut;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    return outputList;
}
