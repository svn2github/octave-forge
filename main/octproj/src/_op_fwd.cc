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
@deftypefn{Loadable Function}{[@var{X},@var{Y}] =}\
_op_fwd(@var{lon},@var{lat},@var{params})\n\
\n\
@cindex Performs forward projection step.\n\
\n\
This function projects geodetic coordinates into cartesian projected\n\
coordinates in the defined cartographic projection using the PROJ.4 function \
pj_fwd().\n\
\n\
@var{lon} is a column vector containing the geodetic longitude, in radians.\n\
@var{lat} is a column vector containing the geodetic latitude, in radians.\n\
@var{params} is a text string containing the projection parameters in PROJ.4 \
format.\n\
\n\
The coordinate vectors @var{lon} and @var{lat} must be both scalars or both\n\
column vectors (of the same size).\n\
\n\
@var{X} is a column vector containing the X projected coordinates.\n\
@var{Y} is a column vector containing the Y projected coordinates.\n\
\n\
If a projection error occurs, the resultant coordinates for the affected\n\
points have both Inf value and a warning message is emitted (one for each\n\
erroneous point).\n\
@seealso{_op_inv, _op_transform}\n\
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
DEFUN_DLD(_op_fwd,args,,HELPTEXT)
{
    //error message
    char errorText[ERRORTEXT]="_op_fwd:\n\t";
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
                "See help _op_fwd");
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
        //geodetic coordinates
        ColumnVector lon=args(0).column_vector_value();
        ColumnVector lat=args(1).column_vector_value();
        //projection parameters
        std::string params=args(2).string_value();
        //number of elements
        size_t nElem=static_cast<size_t>(lon.rows());
        //projected coordinates
        ColumnVector xOut(nElem);
        ColumnVector yOut(nElem);
        //computation vectors
        double* x=NULL;
        double* y=NULL;
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //copy input data
        for(i=0;i<nElem;i++)
        {
            xOut(i) = lon(i);
            yOut(i) = lat(i);
        }
        //pointers to output data
        x = xOut.fortran_vec();
        y = yOut.fortran_vec();
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //projection
        idErr = proj_fwd(x,y,nElem,params.c_str(),&errorText[strlen(errorText)],
                         &projectionError);
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
                    if((x[i]==HUGE_VAL)||(y[i]==HUGE_VAL))
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
        outputList(0) = xOut;
        outputList(1) = yOut;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    return outputList;
}
