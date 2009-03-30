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
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#include <octave/oct.h>
#include <octave/load-save.h>
#include <octave/ls-oct-binary.h>
#include <octave/oct-stream.h>

DEFUN_DLD (__bw_psend__, args, , "psend (pd, name[, value])\n\
Sends variable named in 'name' through pipe stream 'pd'.\n\
With 'value' given and having boolean value 'true', the\n\
contents of the second argument itself is sent under the name\n\
'psend_var'.\n\
The variable is coded in Octaves binary format,\n\
a header is included. It can be read by 'prcv ()'.\n\
\n\
This function may change and is internal to the parallel package.\n")
{
	std::string name;
	std::string help;
	int global;
	octave_value retval;
	octave_value tc;
	bool contents;

	if (args.length () == 2) 
		contents = false;
	else if (args.length () == 3) {
		if (! args(2).is_real_scalar ()) {
			error ("psend: third variable, if given, must be a real scalar.\n");
			return retval;
		}
		contents = args(2).scalar_value ();
	} else {
		error ("psend: two or three arguments required\n");
		return retval;
	}

	if (contents) {
		name = "psend_var";
		tc = args(1);
		help = "";
		global = false;
	}
	else {
		if (args(1).is_string ()) name = args(1).string_value ();
		else {
			error ("psend: if named variable is to be sent, second argument must be a string\n");
			return retval;
		}
		symbol_record *var = curr_sym_tab->lookup (name);
	        if (! var) {
			error ("psend: no such variable %s\n", name.c_str ());
			return retval;
		}
		tc = var->def ();
		help = var->help ();
		global = var->is_linked_to_global ();
	}
	if (! tc.is_defined ()) {
		// What means this?
		error ("psend: variable not defined\n");
		return retval;
	}
		
	octave_stream os = octave_stream_list::lookup (args(0), "psend");
	if (error_state) {
		error ("psend: no valid file id\n");
		return retval;
	}
	if (os.is_open ()) {
		std::string mode = os.mode_as_string (os.mode ());
		if (mode == "r" || mode == "rb") {
			error ("psend: stream not writable\n");
			return retval;
		}
#ifdef PATCHED_PIPE_CODE_15TH_JUNE_07
		// If I understood right, Octaves pipe-ids have been
		// patched (at 15th June 2007 ?) to show "wb" and "rb"
		// instead of "w" and "b".

		// 98: "b"
		if (! strchr (mode.c_str (), 98)) {
			error ("psend: stream not binary\n");
			return retval;
		}
#endif
	}
	else {
		error ("psend: stream not open\n");
		return retval;
	}

	std::ostream *tps = os.output_stream ();
	std::ostream& ps = *tps;
	write_header (ps, LS_BINARY);
	save_binary_data (ps, tc, name, help, global, false);

	return retval;
}
