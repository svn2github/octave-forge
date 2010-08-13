// Copyright (C) 2010 Olaf Till <olaf.till@uni-jena.de>

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#include <octave/oct.h>
#include <octave/load-save.h>
#include <octave/ls-oct-binary.h>
#include <octave/oct-stream.h>

DEFUN_DLD (send, args, , "send (X, sockets)\n\
\n\
Send the variable 'X' to the computers specified by matrix 'sockets'\n.")
{
  octave_value retval;

  if (args.length () != 2)
    {
      error ("two arguments required\n");

      return retval;
    }

  Matrix sockets = args(1).matrix_value ();

  if (error_state)
    return retval;

  int rows = sockets.rows ();

  double sid;

  for (int id = 0; id < rows; id++)
    {
      if ((sid = sockets(id, 0)) != 0)
	{
	  octave_stream os = octave_stream_list::lookup
	    (octave_value (sid), "send");

	  if (error_state)
	    {
	      error ("no valid stream id\n");

	      return retval;
	    }
	  if (! os.is_open ())
	    {
	      error ("stream not open\n");

	      return retval;
	    }

	  std::ostream *tps = os.output_stream ();
	  std::ostream& ps = *tps;

	  write_header (ps, LS_BINARY);

	  save_binary_data (ps, args(0), "a", "", false, false);

	  ps.flush ();
	}
    }

  return retval;
}
