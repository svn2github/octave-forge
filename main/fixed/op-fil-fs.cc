/*

Copyright (C) 2003 Motorola Inc
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

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma implementation
#endif

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <iostream>

#include <octave/config.h>

#include <octave/error.h>
#include <octave/oct-obj.h>
#include <octave/oct-stream.h>
#include <octave/ops.h>
#include <octave/ov.h>
#include <octave/ov-file.h>
#include <octave/ov-typeinfo.h>

#include "ov-fixed.h"

// file by fixed scalar ops.

DEFBINOP (lshift, file, fixed)
{
  CAST_BINOP_ARGS (const octave_file&, const octave_fixed&);

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
install_fil_fs_ops (void)
{
  INSTALL_BINOP (op_lshift, octave_file, octave_fixed, lshift);
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
