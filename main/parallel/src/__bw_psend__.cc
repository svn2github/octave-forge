// Copyright (C) 2007 Olaf Till <olaf.till@uni-jena.de>

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
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

#include <octave/oct.h>
#include <octave/load-save.h>
#include <octave/ls-oct-binary.h>
#include <octave/oct-stream.h>

DEFUN_DLD (__bw_psend__, args, , "psend (pd, var)\n\
The contents of 'var' is sent through the pipe stream 'pd'\n\
under the name 'psend_var'.\n\
The variable is coded in Octaves binary format,\n\
a header is included. It can be read by 'prcv ()'.\n\
\n\
This function may change and is internal to the parallel package.\n")
{
	octave_value retval;
	octave_value tc;

	if (args.length () != 2) {
		error ("__bw_psend__: two arguments required\n");
		return retval;
	}

	octave_stream os = octave_stream_list::lookup (args(0), "__bw_psend__");
	if (error_state) {
		error ("__bw_psend__: no valid file id\n");
		return retval;
	}
	if (os.is_open ()) {
		std::string mode = os.mode_as_string (os.mode ());
		if (mode == "r" || mode == "rb") {
			error ("__bw_psend__: stream not writable\n");
			return retval;
		}
#ifdef PATCHED_PIPE_CODE_15TH_JUNE_07
		// If I understood right, Octaves pipe-ids have been
		// patched (at 15th June 2007 ?) to show "wb" and "rb"
		// instead of "w" and "b".

		// 98: "b"
		if (! strchr (mode.c_str (), 98)) {
			error ("__bw_psend__: stream not binary\n");
			return retval;
		}
#endif
	}
	else {
		error ("__bw_psend__: stream not open\n");
		return retval;
	}

	std::ostream *tps = os.output_stream ();
	std::ostream& ps = *tps;
	write_header (ps, LS_BINARY);
	save_binary_data (ps, args(1), "psend_var", "", false, false);

	return retval;
}
