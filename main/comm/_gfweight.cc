/*

Copyright (C) 2003 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#include <iostream>
#include <iomanip>
#include <sstream>
#include <octave/oct.h>
#include <octave/pager.h>

DEFUN_DLD (_gfweight, args, ,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {@var{w} =} _gfweight (@var{gen})\n"
"\n"
"Returns the minimum distance @var{w} of the generator matrix @var{gen}.\n"
"The codeword length is @var{k}.\n"
"\n"
"This is an internal function of @dfn{gfweight}. You should use gfweight\n"
"rather than use this function directly.\n"
"@end deftypefn\n"
"@seealso{gfweight}") {
  octave_value retval;

  if (args.length() != 1) {
    error("_gfweight: wrong number of arguments");
    return retval;
  }

  Matrix gen = args(0).matrix_value();
  int k = gen.rows();
  int n = gen.columns();
  unsigned long long nsym = ((unsigned long long)1 << k);

  if (k > 64) {
    error("_gfweight: can only handle message sizes up to 64");
    return retval;
  } else if (k > 20)
    octave_stdout << "_gfweight: this is likely to take a very long time!!\n";

  int w = n;
  for (unsigned long long i=1; i<nsym; i++) {
    int wtmp = 0;
    for (int j=0; j<n; j++) {
      int rtmp = 0;
      for (int l=0; l<k; l++)
	if (i & ((unsigned long long)1<<l))
	  rtmp ^= (int)gen(l,j);
      wtmp += rtmp;
    }
    if (wtmp < w) 
      w = wtmp;
  }
  
  retval = octave_value((double)w);
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
