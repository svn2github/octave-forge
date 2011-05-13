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
@deftypefn{Loadable Function}{[@var{X2},@var{Y2},@var{Z2}] =}\
_op_transform(@var{X1},@var{Y1},@var{Z1},@var{par1},@var{par2})\n\
\n\
@cindex Performs transformation between two coordinate systems.\n\
\n\
This function transforms X/Y/Z, lon/lat/h points between two coordinate\n\
systems 1 and 2 using the PROJ.4 function pj_transform().\n\
\n\
@var{X1} is a column vector containing the first coordinates in the source\n\
coordinate system. If @var{X1} is geodetic longitude, it must be passed in \
radians.\n\
@var{Y1} is a column vector containing the second coordinates in the source\n\
coordinate system. If @var{Y1} is geodetic latitude, it must be passed in \
radians.\n\
@var{Z1} is a column vector containing the third first coordinates in the\n\
source coordinate system.\n\
@var{par1} is a text string containing the projection parameters for the\n\
source system, in PROJ.4 format.\n\
@var{par2} is a text string containing the projection parameters for the\n\
destination system, in PROJ.4 format.\n\
\n\
The coordinate vectors @var{X1}, @var{Y1} and @var{Z1} must be all scalars or\n\
all column vectors (of the same size).\n\
\n\
@var{X2} is a column vector containing the first coordinates in the\n\
destination coordinate system. If @var{X2} is geodetic longitude, it is\n\
output in radians.\n\
@var{Y2} is a column vector containing the second coordinates in the\n\
destination coordinate system. If @var{Y2} is geodetic longitude, it is\n\
output in radians.\n\
@var{Z2} is a column vector containing the third coordinates in the\n\
destination coordinate system.\n\
\n\
@seealso{_op_fwd, _op_inv}\n\
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
DEFUN_DLD(_op_transform,args,,HELPTEXT)
{
    //error message
    char errorText[ERRORTEXT]="_op_transform:\n\t";
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
                "See help _op_transform");
        //error message
        error(errorText);
    }
    else
    {
        //loop index
        size_t i=0;
        //input coordinates from GNU Octave
        ColumnVector xIn=args(0).column_vector_value();
        ColumnVector yIn=args(1).column_vector_value();
        ColumnVector zIn=args(2).column_vector_value();
        //parameters strings
        std::string paramsStart=args(3).string_value();
        std::string paramsEnd=args(4).string_value();
        //number of imput data
        size_t nElem=static_cast<size_t>(xIn.rows());
        size_t nElemZ=static_cast<size_t>(zIn.rows());
        //output coordinates for GNU Octave
        ColumnVector xOut(nElem);
        ColumnVector yOut(nElem);
        ColumnVector zOut(nElemZ);
        //pointers to output data
        double* x=NULL;
        double* y=NULL;
        double* z=NULL;
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //copy input data in working arrays
        for(i=0;i<nElem;i++)
        {
            xOut(i) = xIn(i);
            yOut(i) = yIn(i);
            if(nElemZ)
            {
                zOut(i) = zIn(i);
            }
        }
        //pointers to output data
        x = xOut.fortran_vec();
        y = yOut.fortran_vec();
        if(nElemZ)
        {
            z = zOut.fortran_vec();
        }
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //transformation
        if(proj_transform(x,y,z,nElem,1,paramsStart.c_str(),paramsEnd.c_str(),
                          &errorText[strlen(errorText)]))
        {
            //error message
            error(errorText);
            //exit
            return outputList;
        }
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        //adding results to output list
        outputList(0) = xOut;
        outputList(1) = yOut;
        outputList(2) = zOut;
    }
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    //exit
    return outputList;
}
