//Copyright (C) 2003 David Bateman
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation; either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see
// <http://www.gnu.org/licenses/>.
//
// In addition to the terms of the GPL, you are permitted to link this
// program with any Open Source program, as defined by the Open Source
// Initiative (www.opensource.org)

#include <iostream>
#include <iomanip>
#include <sstream>
#include <octave/oct.h>
#include <octave/pager.h>
#include <octave/quit.h>

static int
get_weight (const Array<char>& codeword, const Matrix& gen,
            int weight, int depth, int start, int n, int k)
{
  int retval = weight;

  for (int i = start; i < k ; i++)
  {
    OCTAVE_QUIT;

    Array<char> new_codeword (codeword);
    int tmp = 0;
    for (int j = 0; j < n; j++)
      if (new_codeword (j) ^= (char)gen(i,j))
        tmp++;
    if (tmp < retval)
      retval = tmp;
    if (depth < retval)
      retval = get_weight(new_codeword, gen, retval, depth+1, i+1, n, k);
  }
  return retval;
}

DEFUN_DLD (__gfweight__, args, ,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {@var{w} =} _gfweight (@var{gen})\n"
"\n"
"Returns the minimum distance @var{w} of the generator matrix @var{gen}.\n"
"The codeword length is @var{k}.\n"
"\n"
"This is an internal function of @dfn{gfweight}. You should use gfweight\n"
"rather than use this function directly.\n"
"@end deftypefn\n"
"@seealso{gfweight}")
{

  if (args.length() != 1) {
    error("_gfweight: wrong number of arguments");
    return octave_value();
  }

  Matrix gen = args(0).matrix_value();
  int k = gen.rows();
  int n = gen.columns();
  unsigned long long nsym = ((unsigned long long)1 << k);

  if (k > 128)
  {
    octave_stdout << "_gfweight: this is likely to take a very long time!!\n";
    flush_octave_stdout ();
  }

  Array<char> codeword (dim_vector (n, 1), 0);
  return octave_value((double)get_weight (codeword, gen, n - k + 1, 1,
                                          0, n, k));
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
