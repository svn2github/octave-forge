/* Copyright (C) 2003  Kai Habel
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 
*/

/*
29. January 2003 - Kai Habel: first release

TODO:
* handle line terminator \r and \n\r (?) 
*/

#include "config.h"
#include <fstream>
#include <algorithm>
#include <queue>
#include <climits>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>
#include <octave/lo-ieee.h>

using namespace std;

bool sep_is_next(istringstream *linestrm, string sep) {

  bool ret = true;
  char c;
  
  *linestrm >> c;
  if (c != sep[0]) {
    ret = false;
    linestrm->putback(c);
  }
  return ret;
}

queue<Complex> read_textline(istringstream *linestrm, string sep) {

  queue<Complex> line;
  Complex cv = 0.0;
  unsigned long nchr = 0;

  while (!linestrm->eof() ) {
  
    nchr++;    
    if (sep_is_next(linestrm,sep)) {
    
      if (nchr == 1) line.push(0);
        // first line character is separator

      if (sep_is_next(linestrm,sep)) line.push(0);
        // double occurance of separator  

      if (linestrm->eof()) line.push(0);
        // last line character is sparator
      
    } else {
      linestrm->clear();
      cv = octave_read_double(*linestrm);
      if (linestrm->fail()) {
        // invalid charcter(s), try to find next separator
        linestrm->clear();
        while ( !(sep_is_next(linestrm, sep) || linestrm->eof()) )
	  linestrm->get(); 
	line.push(0);
      } else {
        line.push(cv);
      }    
    }
  }
  return line;
}


DEFUN_DLD (dlmread, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{data} =} dlmread (@var{file})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file},@var{sep})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file},@var{sep},@var{R0},@var{C0})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file},@var{sep},@var{range})\n\
Read the matrix @var{data} from a text file\n\
The @var{range} parameter must be a 4 element vector containing  the upper left and lower right corner\n\
[@var{R0},@var{C0},@var{R1},@var{C1}]\n\
The lowest index value is zero.\n\
@end deftypefn")

{
  octave_value_list retval;
  queue<ComplexColumnVector> lines;  
  int nargin = args.length();
  if (nargin < 1 || nargin > 4) {
    print_usage ();
    return retval;
  }

  if ( !args (0).is_string() ) {
    error ("dlmread: 1st argument must be a string");
    return retval;
  }
  
    // set default values
  string sep(",");
  unsigned long r0 = 0,c0 = 0,r1 = ULONG_MAX-1,c1 = ULONG_MAX-1;
  
  if (nargin > 1) {
    sep = args(1).string_value();
    if (sep.length() != 1) error("separator must be a single character");
  }
    
  if (nargin == 3) {
    ColumnVector range(args(2).vector_value());
    if (range.length() == 4) {
        // double --> unsigned int     
      r0 = static_cast<unsigned long> (range(0));
      c0 = static_cast<unsigned long> (range(1));
      r1 = static_cast<unsigned long> (range(2));
      c1 = static_cast<unsigned long> (range(3));
      if (lo_ieee_isinf(range(2))) r1 = ULONG_MAX-1;
      if (lo_ieee_isinf(range(3))) c1 = ULONG_MAX-1;
      
    } else {
      error("range must include [R1 C1 R2 C2]");
    }
    
  } else if (nargin == 4) {
    r0 = args(2).ulong_value();
    c0 = args(3).ulong_value();
  }
  
  unsigned long dr = r1 - r0 + 1;
  unsigned long dc = c1 - c0 + 1;
  
  string fname(args(0).string_value());
  ifstream file(fname.c_str());
  if (!file) {
    error("could not open file");
    return retval;
  }

    // find file length 
  file.seekg(0, ios::end);
  ifstream::pos_type flen = file.tellg();
  file.seekg(0, ios::beg);

  OCTAVE_LOCAL_BUFFER(char,line,(long int)flen);
  
  unsigned long nr = 0, nc = 0, curr_len = 0,colIdx;
  queue<Complex> lineq;
  
    //skip first r0 - 1 lines
  for (unsigned long i=0;i<r0;i++) {
    file.getline(line,flen,'\n');
  }
  
    // get first line
  file.getline(line,flen,'\n');
  do {
    istringstream lstrm(line); 
    lineq = read_textline(&lstrm,sep);
    
    curr_len = min(static_cast<unsigned long> (lineq.size()), dc);
    ComplexColumnVector col2(curr_len);
    
    for (colIdx = 0;colIdx < curr_len;colIdx++) {
      col2(colIdx) = lineq.front();
      lineq.pop();
    }
      // save current ColumnVector (current line) in queue
    lines.push(col2);
    
      // save maximum number of columns and number of rows
    nc = max(nc,curr_len);
    
     // early break when user limit R2 is reached, increase row counter
    if (nr++ > dr) break;
    
      // get next line
    file.getline(line,flen,'\n');
  } while(!file.eof());
  
  unsigned long cend, r, c;

  if (c0 <= nc) {
    ComplexMatrix cm(nr,nc-c0);
    ComplexColumnVector cv;
    
      // write all ColumnVecotors into Matrix 
    for (r = 0; r < nr;r++) {
      cv = lines.front();
      lines.pop();
      cend = min(dc, cv.length() - c0);
      for (c = 0; c < cend; c++)
        cm(r,c) = cv(c + c0);
    }
    retval(0) = cm;
  }
  
  return retval;
}
