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


#define ALPHABET "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

static int map[256];

void init_map(void)
{
    unsigned i;
    for (i = 0; ALPHABET[i]; i++) {
        map[(unsigned char)ALPHABET[i]] = i + 1;
    }
}

char *column_index_to_string(int c, char *s)
{
    int i, x;
    if (c < 1 || c > 18278) {
        return NULL;
    }

    for (i = 0; (c) && i < 3; i++) {
        c -= 1;
        x = c % 26;
        s[2 - i] = ALPHABET[x];
        c /= 26;
    }
    memmove(s, s + 3 - i , i);
    s[i] = '\0';
    return s;
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{


    if(nrhs!=1) {
	mexErrMsgIdAndTxt("IO:arrayProduct:nrhs", "One INPUT argument, no more nor less!");
    } else if ( !mxIsDouble(prhs[0]) ||  mxIsComplex(prhs[0])) {
	mexErrMsgIdAndTxt("IO:arrayProduct:nrhs", "INPUT argument has to be double and no complex number!");
    } else {

      double *raw;
      int *index;
      raw = mxGetPr (prhs[0]);
      index[0]=raw[0];

      char str[4];
      plhs[0]=mxCreateString(column_index_to_string(index[0], str));

   }

}
