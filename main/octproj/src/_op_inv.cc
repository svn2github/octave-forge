/* -*- coding: utf-8 -*- */
/* Copyright (C) 2009, 2011  José Luis García Pallero, <jgpallero@gmail.com>
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
@deftypefn{Loadable Function}{[@var{lon},@var{lat}] =}\
_op_inv(@var{X},@var{Y},@var{params})\n\
\n\
@cindex Performs inverse projection step.\n\
\n\
This function unprojects cartesian projected coordinates (in a defined\n\
cartographic projection) into geodetic coordinates using the PROJ.4 function \
pj_inv().\n\
\n\
@var{X} is a column vector containing the X projected coordinates.\n\
@var{Y} is a column vector containing the Y projected coordinates.\n\
@var{params} is a text string containing the projection parameters in PROJ.4 \
format.\n\
\n\
The coordinate vectors @var{X} and @var{Y} must be both scalars or both\n\
column vectors (of the same size).\n\
\n\
@var{lon} is a column vector containing the geodetic longitude, in radians.\n\
@var{lat} is a column vector containing the geodetic latitude, in radians.\n\
\n\
If a projection error occurs, the resultant coordinates for the affected\n\
points have both Inf value and a warning message is emitted (one for each\n\
erroneous point).\n\
@seealso{_op_fwd, _op_transform}\n\
@end deftypefn"
/******************************************************************************/
/******************************************************************************/
#include<octave/oct.h>
#include<cstdio>
#include<cstring>
#include<cstdlib>
#include<cmath>
#include"projwrap.h"
/******************************************************************************/
/******************************************************************************/
#define ERRORTEXT 1000
/******************************************************************************/
/******************************************************************************/
DEFUN_DLD(_op_inv,args,,HELPTEXT)
{
    //error message
    char errorText[ERRORTEXT]="_op_inv:\n\t";
    //output list
    octave_value_list outputList;
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //checking input arguments
    if(args.length()!=3)
    {
        //error text
        sprintf(&errorText[strlen(errorText)],
                "Incorrect number of input arguments\n\t"
                "See help _op_inv");
        //error message
        error(errorText);
    }
    else
    {
        //error code
        int idErr=0;
        //error in projection
        int projectionError=0;
        //loop index
        size_t i=0;
        //projected coordinates
        ColumnVector X=args(0).column_vector_value();
        ColumnVector Y=args(1).column_vector_value();
        //projection parameters
        std::string params=args(2).string_value();
        //number of elements
        size_t nElem=static_cast<size_t>(X.rows());
        //geodetic coordinates
        ColumnVector lonOut(nElem);
        ColumnVector latOut(nElem);
        //computation vectors
        double* lon=NULL;
        double* lat=NULL;
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //copy input data
        for(i=0;i<nElem;i++)
        {
            lonOut(i) = X(i);
            latOut(i) = Y(i);
        }
        //pointers to output data
        lon = lonOut.fortran_vec();
        lat = latOut.fortran_vec();
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //projection
        idErr = proj_inv(lon,lat,nElem,1,params.c_str(),
                         &errorText[strlen(errorText)],&projectionError);
        //error checking
        if(idErr||projectionError)
        {
            //type of error
            if(projectionError)
            {
                //warning message
                warning(errorText);
                //positions of projection errors
                for(i=0;i<nElem;i++)
                {
                    //testing for HUGE_VAL
                    if((lon[i]==HUGE_VAL)||(lat[i]==HUGE_VAL))
                    {
                        //error text
                        warning("Projection error in point %d "
                                "(index starts at 1)",i+1);
                    }
                }
            }
            else
            {
                //error message
                error(errorText);
                //exit
                return outputList;
            }
        }
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //output parameters list
        outputList(0) = lonOut;
        outputList(1) = latOut;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    return outputList;
}
