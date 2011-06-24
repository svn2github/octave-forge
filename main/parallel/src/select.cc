// Copyright (C) 2007, 2009 Olaf Till <olaf.till@uni-jena.de>

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
#include <octave/oct-stream.h>

#ifdef POSIX
#include <sys/select.h>
#else
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#endif
#include <errno.h>
#include <map>

DEFUN_DLD (select, args, nargout, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{n}, @var{ridx}, @var{widx}, @var{eidx}] =} select (@var{read_fids}, @var{write_fids}, @var{except_fids}, @var{timeout}[, @var{nfds}])\n\
Calls Unix @code{select}, see the respective manual.\n\
The following interface was chosen:\n\
@var{read_fids}, @var{write_fids}, @var{except_fids}: vectors of stream-ids.\n\
@var{timeout}: seconds, negative for infinite.\n\
@var{nfds}: optional, default is Unix' FD_SETSIZE (platform specific).\n\
An error is returned if nfds or a filedescriptor belonging to a stream-id\n\
plus one exceeds FD_SETSIZE.\n\
Return values are:\n\
@var{n}: number of ready streams.\n\
@var{ridx}, @var{widx}, @var{eidx}: index vectors of ready streams in\n\
@var{read_fids}, @var{write_fids}, and @var{except_fids}, respectively.\n\
@end deftypefn")
{
	/* This routine assumes that Octaves stream-id and the
	   corresponding filedescriptor of the system are the same
	   number. This should be the case in Octave >= 3.0.0. */
	octave_value_list retval;
	int nargin = args.length ();
	int i, fd, fid, nfds, n, act, argc;
	double argtout, *fvec;
	timeval tout;
	timeval *timeout = &tout;
	ColumnVector read_fids, write_fids, except_fids;

	if (nargin == 4)
		nfds = FD_SETSIZE;
	else if (nargin == 5) {
		if (! args(4).is_real_scalar ()) {
			error ("select: 'nfds' must be a real scalar.\n");
			return retval;
		}
		nfds = args(4).int_value ();
		if (nfds <= 0) {
			error ("select: 'nfds' should be greater than zero.\n");
			return retval;
		}
		if (nfds > FD_SETSIZE) {
			error ("select: 'nfds' exceeds systems maximum given by FD_SETSIZE.\n");
			return retval;
		}
	}
	else {
		error ("select: four or five arguments required.\n");
		return retval;
	}
	if (! args(3).is_real_scalar ()) {
		error ("select: 'timeout' must be a real scalar.\n");
		return retval;
	}
	if ((argtout = args(3).double_value ()) < 0)
		timeout = NULL;
	else {
		double ipart, fpart;
		fpart = modf (argtout, &ipart);
		tout.tv_sec = lrint (ipart);
		tout.tv_usec = lrint (fpart * 1000);
	}
	for (argc = 0; argc < 3; argc++) {
		if (! args(argc).is_empty ()) {
			if (! args(argc).is_real_type ()) {
				error ("select: first three arguments must be real vectors.\n");
				return retval;
			}
			if (args(argc).rows () != 1 &&
			    args(argc).columns () != 1) {
				error ("select: first three arguments must be real vectors.\n");
				return retval;
			}
			switch (argc) {
			case 0:	read_fids = ColumnVector
					(args(argc).vector_value ()); break;
			case 1: write_fids = ColumnVector
					(args(argc).vector_value ()); break;
			case 2: except_fids = ColumnVector
					(args(argc).vector_value ()); break;
			}
		}
	}

	fd_set rfds, wfds, efds;
	FD_ZERO (&rfds); FD_ZERO (&wfds); FD_ZERO (&efds);
	for (i = 0; i < read_fids.length (); i++) {
		fid = lrint (read_fids(i));
		fd = octave_stream_list::lookup (fid, "select") . 
			file_number ();
		if (error_state || fd < 0) {
			error ("select: invalid file-id");
			return retval;
		}
		if (fid >= FD_SETSIZE) {
			error ("select: filedescriptor >= FD_SETSIZE");
			return retval;
		}
		FD_SET (fid, &rfds);
	}
	for (i = 0; i < write_fids.length (); i++) {
		fid = lrint (write_fids(i));
		fd = octave_stream_list::lookup (fid, "select") . 
			file_number ();
		if (error_state || fd < 0) {
			error ("select: invalid file-id");
			return retval;
		}
		if (fid >= FD_SETSIZE) {
			error ("select: filedescriptor >= FD_SETSIZE");
			return retval;
		}
		FD_SET (fid, &wfds);
	}
	for (i = 0; i < except_fids.length (); i++) {
		fid = lrint (except_fids(i));
		fd = octave_stream_list::lookup (fid, "select") . 
			file_number ();
		if (error_state || fd < 0) {
			error ("select: invalid file-id");
			return retval;
		}
		if (fid >= FD_SETSIZE) {
			error ("select: filedescriptor >= FD_SETSIZE");
			return retval;
		}
		FD_SET (fid, &efds);
	}

	if ((n = select (nfds, &rfds, &wfds, &efds, timeout)) == -1) {
		std::string err;
		switch (errno) {
		case EBADF:
			err = "EBADF";
			break;
		case EINTR:
			err = "EINTR";
			break;
		case EINVAL:
			err = "EINVAL";
			break;
		default:
			err = "unknown error";
		}
		error ("select: unix select returned error: %s\n",
		       err.c_str ());
		return retval;
	}
	if (nargout > 3) {
		for (i = 0, act = 0; i < except_fids.length (); i++)
			if (FD_ISSET (lrint (except_fids(i)), &efds)) act++;
		RowVector eidx = RowVector (act);
		for (i = 0, fvec = eidx.fortran_vec ();
		     i < except_fids.length (); i++)
			if (FD_ISSET (lrint (except_fids(i)), &efds)) {
				*fvec = double (i + 1);
				fvec++;
			}
		retval(3) = eidx;
	}
	if (nargout > 2) {
		for (i = 0, act = 0; i < write_fids.length (); i++)
			if (FD_ISSET (lrint (write_fids(i)), &wfds)) act++;
		RowVector widx = RowVector (act);
		for (i = 0, fvec = widx.fortran_vec ();
		     i < write_fids.length (); i++)
			if (FD_ISSET (lrint (write_fids(i)), &wfds)) {
				*fvec = double (i + 1);
				fvec++;
			}
		retval(2) = widx;
	}
	if (nargout > 1) {
		for (i = 0, act = 0; i < read_fids.length (); i++)
			if (FD_ISSET (lrint (read_fids(i)), &rfds)) act++;
		RowVector ridx = RowVector (act);
		for (i = 0, fvec = ridx.fortran_vec ();
		     i < read_fids.length (); i++)
			if (FD_ISSET (lrint (read_fids(i)), &rfds)) {
				*fvec = double (i + 1);
				fvec++;
			}
		retval(1) = ridx;
	}

	retval(0) = n;

	return retval;
}
