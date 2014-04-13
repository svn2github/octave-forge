// Copyright (C) 2014 Markus Bergholz <markuman@gmail.com>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

#include "mex.h"
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <ctype.h>

int column_index_from_string(const char *s)
{
  int ret=0;
  for (; *s; s++)
    {
      if (!isupper(*s))
        return -1;
      ret = ret*26 + *s-'A' +1;
      if (ret<0) //overflow
        return -1;
    }
  return ret;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  if(nrhs!=1)
    {
      mexErrMsgIdAndTxt("IO:arrayProduct:nrhs", "Only one input allowed.");
    }
  else if ( !mxIsChar(prhs[0]))
    {
      mexErrMsgIdAndTxt("IO:arrayProduct:nrhs", "Input must be a string.");
    }
  else
    {
      char *str;
      str = (char *) mxCalloc(mxGetN(prhs[0])+1, sizeof(char));
      mxGetString(prhs[0], str, mxGetN(prhs[0])+1);
      if (strlen(str)>3)
        {
          mexErrMsgIdAndTxt("IO:arrayProduct:nrhs", "Input string is too long.");
        }
      else
        {
          int i = column_index_from_string(str);
          if (i<0)
            mexErrMsgIdAndTxt("IO:arrayProduct:nrhs", "Illegal characters.");
          else
            {
              plhs[0] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, mxREAL);
              double *index;
              index = mxGetPr(plhs[0]);
              index[0] = i;
            }
        }
    }
}
