## Copyright (C) 2001 Albert Danial <alnd@users.sf.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: [a,b,c,...] = textread(file, format, n);
##
## Reads data from the file using the provided format string.  The
## first return value will contain the first column of the file,
## the second return value gets the second column, et cetera.
## If n is given, the format string will be reused n times.  
## If n is omitted or negative, the entire file will be read.
##
## Example:  say the file 'info.txt' contains the following lines:
##    Bunny Bugs   5.5     age=30
##    Duck Daffy  -7.5e-5  age=27
##    Penguin Tux   6      age=10
## Columns from this file could be read with the line:
##   [Lname, Fname, x, a] = textread('info.txt', '%s %s %e age=%d');
## then,
##   Lname(3,:)  is 'Penguin'
##   Fname(3,:)  is 'Tux'
##   x(3)        is  6
##   a(3)        is 10
##
## Limitations:  fails if the format string contains literal
##               percent signs (ie, '%%'), or literal strings
##               containing characters 's' or 'c'.

function [...] = textread(file, format, n);

    if ((nargin == 2) || n < 0)
        n = 0;
    endif

    [fid, message] = fopen(file, "r");
    if (fid == -1)
        error(sprintf("textread('%s',...):  %s\n", file, message));
    endif

    # Step 1:  Break apart the format string into an array of formats, 
    #          one for each column.

    fmts = split(format, "%");          # fails if input file has embedded %'s
    first_fmt_len = size(fmts(1,:), 2); # the number of columns to expect
    if (sum(isspace(fmts(1,:))) == first_fmt_len) 
        # the first string is empty because format started w/%; skip it
        first_fmt_idx = 2;
    else
        # then the first format substring is not empty; need to use it
        first_fmt_idx = 1;
    endif
    nFields = size(fmts,1);


    # Step 2:  Read the contents of the file one term at a time.
    #          Place the terms into temporary octave matrices
    #          called 'aa', 'ab', et cetera.  Each pass through
    #          the format strings yields one new row in these working
    #          matrices.

    row = 1;
    while (!feof(fid))
        mat_name = "aa"; # iterate through "aa", "ab", "ac", ... "zz"
        for i = first_fmt_idx:nFields
            pfmt   = strcat("%", fmts(i,:));  # put % at start of format string
            [data] = fscanf(fid, pfmt, "C");
            if (index(pfmt, "%s")                      || 
                ((pfmt(1) == "%") && index(pfmt, "s")) || # eg, match %17s
                ((pfmt(1) == "%") && index(pfmt, "c")) )  # eg, match %17c
                # then this is a string or a group of chars
                eval(sprintf("%s(%d,1:%d) = data;", 
                             mat_name, row, size(data,2)));
            else                       # this is a scalar
                eval(sprintf("%s(%d) = data;", mat_name, row));
            endif
            mat_name = str_incr(mat_name, 2); # eg, "aa" becomes "ab"
        endfor
        ++row;

        if (n && row > n)
            break;
        endif 

    endwhile
    fclose(fid);

    # Step 3:  populate the return values with the contents of aa, ab, etc 

    mat_name = "aa";
    for i = 1:nargout
        vr_val( eval(mat_name) );
        mat_name = str_incr(mat_name, 2);
    endfor
    return

endfunction
