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
* add support for NaN
* handle line separators \r or \n\r
*/

#include "config.h"

#include <string>
#include <fstream>
#include <iostream>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>

using namespace std;

DEFUN_DLD (dlmread, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{data} =} dlmread (@var{file},@var{sep})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file})\n\
Read the matrix @var{data} from a text file\n\
@end deftypefn")

{
  octave_value_list retval;
    
  int nargin = args.length();
  if (nargin < 1 || nargin > 2) {
    print_usage ("dlmread");
    return retval;
  }

  if ( !args (0).is_string() ) {
    error ("dlmread: 1st arguments must be a strings");
    return retval;
  }

  string sep(",");
  if (nargin > 1) {
    sep = args(1).string_value();
  }

  string fname(args(0).string_value());
  ifstream file(fname.c_str());
  if (!file) error("could not open file");
  file.seekg(0, ios::end);
  ifstream::pos_type flen = file.tellg();
  file.seekg(0, ios::beg);
  
  char data[(long int)flen];
  file.read(data,flen);
  string datastr(data,flen);
  string::size_type len_sep = sep.length();
  string::size_type pos = 0;
  string::size_type end = datastr.length() - 1;
  unsigned long n = 1, nr = 0, nc = 0;

    // replace '\n' with separator string
  while(1) {
    pos = datastr.find("\n",pos);
    if (pos == string::npos) break;
    nr++;
    if (pos < end) {
      if (len_sep == 1)
        datastr.replace(pos++,1,sep);
      else {
        datastr.erase(pos,1);
        datastr.insert(pos,sep);
        pos+=len_sep;
        end = datastr.length() - 1;
      }
    } else {
        // remove '\n' at file end
      datastr.erase(pos++,1);
    }
  }
  
    // fill in zeros between multiple occurance of separators
  string spat = sep + sep;
  string rpat = sep + "0";
  string::size_type len_rpat = rpat.length();
  pos = 0;
  while(1) {
    pos = datastr.find(spat,pos);
    if (pos == string::npos) break;
    datastr.erase(pos,1);
    datastr.insert(pos,rpat);
    pos += len_rpat;
  }

    // check for separators at begin and end
  pos = datastr.find(sep,0);
  if (pos != string::npos) datastr.insert(0,"0");
  pos = datastr.find(sep,datastr.length() - 1);
  if (pos != string::npos) datastr.insert(datastr.length(),"0");

    // replace separators with blanks
  pos = 0;
  while(1) {
    pos = datastr.find(sep,pos);
    if (pos == string::npos) break;
    n++;
    if (len_sep == 1)
      datastr.replace(pos++,1," ");
    else {
      datastr.erase(pos,len_sep);
      datastr.insert(pos++," ");
    }
  }
    // write data into Matrix via stringstream
  nc = n/nr;
  istringstream datastrm(datastr);
  Matrix m(nr,nc);
  unsigned long r,c; 
  for (r=0;r<nr;r++) {
    for (c=0;c<nc;c++) {
      datastrm >> m(r,c);
    }
  }    
  retval(0) = m;
  return retval;
}
