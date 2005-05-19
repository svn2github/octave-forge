/*

Copyright (C) 2003 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#ifndef HAVE_OCTAVE_29

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma implementation
#endif

#include <iostream>
#include "galois.h"
#include "ov-galois.h"
#include <octave/ov-file.h>


// file by galois ops.

DEFBINOP (lshift, file, galois)
{
  CAST_BINOP_ARGS (const octave_file&, const octave_galois&);

  octave_stream oct_stream = v1.stream_value ();

  if (oct_stream)
    {
      std::ostream *osp = oct_stream.output_stream ();

      if (osp)
	{
	  std::ostream& os = *osp;

	  v2.print_raw (os);
	}
      else
	error ("invalid file specified for binary operator `<<'");
    }

  return octave_value (oct_stream, v1.stream_number ());
}

void
install_fil_gm_ops (void)
{
  INSTALL_BINOP (op_lshift, octave_file, octave_galois, lshift);
}

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
