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
#include <octave/oct-map.h>

DEFUN_DLD (__bw_prcv__, args, nargout, "__bw_prcv__ (pd)\n\
Reads one variable from pipe stream 'pd'.\n\
The variable must have been coded in Octaves binary format,\n\
including a header. This can be done by 'psend ()'.\n\
If EOF is met at start of reading, 0 is returned, so you\n\
can test if 'ismatrix (return_value)' as an alternative to\n\
call 'feof ()' afterwards. If EOF is met later in reading,\n\
it causes an error.\n\
Normally, a structure is returned with the variable under its name\n\
in a single field. Originally, with no output arguments, the variable was\n\
installed into memory, but this has been disabled.\n\
\n\
This function may change and is internal to the parallel package.\n")
{
	octave_value retval;
	Octave_map retstruct;

	if (args.length () != 1) {
		error ("__bw_prcv__: exactly one argument required\n");
		return retval;
	}
	octave_stream is = octave_stream_list::lookup (args(0), "__bw_prcv__");
	if (error_state) return retval;

	if (is.is_open ()) {
		std::string mode = is.mode_as_string (is.mode ());
		// 114: "r", 43: "+"
		if (! strchr (mode.c_str (), 114) &&
		    ! strchr (mode.c_str (), 43)) {
			error ("__bw_prcv__: stream not readable\n");
			return retval;
		}
#ifdef PATCHED_PIPE_CODE
		// If I understood right, Octaves pipe-ids have been
		// patched (at 15th June 2007 ?) to show "wb" and "rb"
		// instead of "w" and "b".

		// 98: "b"
		if (! strchr (mode.c_str (), 98)) {
			error ("__bw_prcv__: stream not binary\n");
			return retval;
		}
#endif
	}
	else {
		error ("__bw_prcv__: stream not open\n");
		return retval;
	}

	std::istream *tps = is.input_stream ();
	std::istream& ps = *tps;

	bool global = false;
	octave_value tc;
	std::string name;
	std::string doc;
	bool swap;
	oct_mach_info::float_format flt_fmt;

	// EOF at start of reading might happen in normal program flow.
	if (ps.peek () == EOF) {
		retval = 0;
		return retval;
	}

	// Any later EOF is not foreseen and should cause an error.

	// The next two functions called pretend to have been called
	// from 'load' in their error messages, read_binary_data also
	// wants to have the filename, but it may be a pipe ...
	if (read_binary_file_header (ps, swap, flt_fmt, false) < 0)
		return retval;
	name = read_binary_data (ps, swap, flt_fmt,
				 "",
				 global, tc, doc);
	// read_binary_data will give no error with EOF at start
	// of reading, but in this case it is an error, since
	// after the header exactly one variable is expected. This
	// is mended by asking for EOF here.
	if (ps.eof () || error_state || name.empty ()) {
		error ("__bw_prcv__: error in reading variable data\n");
		return retval;
	}
	if  (! tc.is_defined ()) {
		// What means this?
		error ("__bw_prcv__: error in reading variable\n");
		return retval;
	}

	retstruct.assign(name, tc);
	retval = retstruct;

	return retval;
}
