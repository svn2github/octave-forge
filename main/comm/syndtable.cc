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

Array<int> get_errs (const int& nmin, const int& nmax, const int &nerrs)
{
  Array<int> pos;

  if (nerrs == 1) {
    pos.resize(nmax-nmin);
    for (int i = nmin; i < nmax; i++)
      pos(i-nmin) = (1<<i);
  } else {
    for (int i = nmin; i < nmax - nerrs + 1; i++) {
      Array<int> new_pos = get_errs(i+1, nmax, nerrs-1);
      int l = pos.length();
      pos.resize(l+new_pos.length());
      for (int j=0; j<new_pos.length(); j++)
	pos(l+j) = (1<<i) + new_pos(j);
    }
  }
  return pos;
}

DEFUN_DLD (syndtable, args, nargout,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {@var{t} =} syndtable (@var{h})\n"
"\n"
"Create the syndrome decoding table from the parity check matrix @var{h}.\n"
"Each row of the returned matrix @var{t} represents the error vector in\n"
"a recieved symbol for a certain syndrome. The row selected is determined\n"
"by a conversion of the syndrome to an integer representation, and using\n"
"this to reference each row of @var{t}.\n"
"@end deftypefn\n"
"@seealso{hammgen,cyclgen}")
{
  octave_value retval;
  int nargin = args.length();

  if (nargin != 1) {
    error ("syndtable: incorrect number of arguments");
    return retval;
  }

  if (!args(0).is_real_matrix()) {
    error ("syndtable: parity check matrix must be a real matrix");
    return retval;
  }

  Matrix h = args(0).matrix_value();
  int m = h.rows();
  int n = h.columns();
  int nrows = (1 << m);

  // Check that the data in h is valid in GF(2)
  for (int i = 0; i < m; i++)
    for (int j = 0; j < m; j++)
      if (((h(i,j) != 0) && (h(i,j) != 1)) || 
	  ((h(i,j) - (double)((int)h(i,j))) != 0)) {
	error ("syndtable: parity check matrix contains invalid data");
	return retval;
      }

  RowVector filled(nrows,0);
  Matrix table(nrows,n,0);
  int nfilled = nrows;
  int nerrs = 1;

  // The first row of the table is for no errors
  nfilled--;
  filled(0) = 1;

  while (nfilled != 0) {
    // Get all possible combinations of nerrs bit errors in n bits
    Array<int> errpos = get_errs(0, n, nerrs);

    // Calculate the syndrome with the error vectors just calculated
    Array<int> syndrome(errpos.length(),0);
    for (int i = 0; i < m; i++)
      for (int j = 0;  j < errpos.length(); j++)
	for (int k = 0;  k < n; k++)
	  syndrome(j) ^= (errpos(j) & ((int)h(i,k) << k)  ? (1<<(m-i-1)) : 0);
    
    // Now use the syndrome as the rows indices to put the error vectors
    // in place
    for (int j = 0;  j < syndrome.length(); j++)
      if ((syndrome(j) < nrows) && !filled(syndrome(j))) {
	filled(syndrome(j)) = 1;
	nfilled--;
	for (int i = 0; i < n; i++) 
	  table(syndrome(j),i) = ((errpos(j) & (1 << i)) != 0);
      }
    nerrs++;
  }

  retval = octave_value(table);
  return retval;
}
