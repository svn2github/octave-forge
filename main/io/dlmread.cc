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
** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 
*/

/*
29. January 2003 - Kai Habel: first release

TODO:
* handle line terminator \r and \n\r 
* handle strings within data sane, like: 1.1,test,2,,
* handle range for reading
*/
#include "config.h"

#include <string>
#include <fstream>
//#include <iostream>
#include <algorithm>
#include <queue>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>

using namespace std;

int insert_zeros(string *line, string sep) {
  // find double occurance of separator and insert zeros 
  string::size_type pos = 0;
  while(1) {
    pos = line->find(sep+sep,pos);
    if (pos == string::npos) break;
    line->erase(pos,1);
    line->insert(pos,sep+"0");
    pos += sep.length()+1;
  }

  // find separator at line begin and end insert zeros
  pos = line->rfind(sep,sep.length()-1);
  if (pos != string::npos) line->insert(0,"0");
  pos = line->find(sep,line->length() - 1);
  if (pos != string::npos) line->insert(line->length(),"0");
  return 0;
}

unsigned long replace_separator(string *line, string sep) {

  // replace separator string with blank
  string::size_type pos = 0;
  unsigned long cols = 1;
  
  while(1) {
    pos = line->find(sep,pos);
    if (pos == string::npos) break;
    cols++;
    line->replace(pos++,1," ");
  }
  // return number of columns for this line
  return cols;
}


DEFUN_DLD (dlmread, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{data} =} dlmread (@var{file},@var{sep})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file})\n\
Read the matrix @var{data} from a text file\n\
@end deftypefn")

{
  octave_value_list retval;
  queue<ComplexColumnVector> lines;  
  int nargin = args.length();
  if (nargin < 1 || nargin > 2) {
    print_usage ("dlmread");
    return retval;
  }

  if ( !args (0).is_string() ) {
    error ("dlmread: 1st argument must be a string");
    return retval;
  }

  string sep(",");
  if (nargin > 1) {
    sep = args(1).string_value();
  }

  string fname(args(0).string_value());
  ifstream file(fname.c_str());
  if (!file) {
    error("could not open file");
    return retval;
  }

  file.seekg(0, ios::end);
  ifstream::pos_type rem,flen = file.tellg();
  file.seekg(0, ios::beg);
  rem = flen;
  char line[(long int)flen];

  string linestr;
  unsigned long nr = 0, nc = 0, ctmp = 0;

  while(1) {
    file.getline(line,flen,'\n');
    string linestr(line);
    rem -= linestr.length() + 1;
    if (rem<0) break;
   
    insert_zeros(&linestr, sep);
    ctmp = replace_separator(&linestr, sep);
    
    ComplexColumnVector col(ctmp);
    istringstream linestrm(linestr);
    for (unsigned i=0;i<ctmp;i++) {
      col(i) = octave_read_complex(linestrm);
    }
     
    lines.push(col);
    
    //save maximum number of columns and number of rows
    nc = max(nc,ctmp);
    nr++;
  }
  
  unsigned long r = 0;
  long c = 0;
  ComplexMatrix cm(nr,nc);
  ComplexColumnVector cv;

  for (r = 0; r < nr;r++) {
    cv = lines.front();
    lines.pop();
    for (c = 0; c<cv.length(); c++) {
      cm(r,c) = cv(c);
    }
  }
  retval(0) = cm;
  return retval;
}
