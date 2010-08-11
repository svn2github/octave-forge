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

DEFUN_DLD (select_sockets, args, nargout, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{n}, @var{idx}] =} select_sockets (@var{sockets}, @var{timeout}[, @var{nfds}])\n\
Calls Unix @code{select}.\n\
@var{sockets}: valid sockets matrix as returned by @code{connect}.\n\
@var{timeout}: seconds, negative for infinite.\n\
@var{nfds}: optional, default is Unix' FD_SETSIZE (platform specific).\n\
Passed to Unix @code{select} as the first argument --- see there.\n\
An error is returned if nfds or a watched filedescriptor \n\
plus one exceeds FD_SETSIZE.\n\
Return values are:\n\
@var{idx}: index vector to rows in @var{sockets} with pending input\n\
readable with @code{recv}.\n\
@var{n}: number of rows in @var{sockets} with pending input.\n\
@end deftypefn")
{
	octave_value_list retval;
	int nargin = args.length ();
	int i, fid, nfds, n, nr, act;
	double argtout, *fvec;
	timeval tout;
	timeval *timeout = &tout;
	ColumnVector read_fds;

	if (nargin == 2)
		nfds = FD_SETSIZE;
	else if (nargin == 3) {
		if (! args(2).is_real_scalar ()) {
			error ("'nfds' must be a real scalar.\n");
			return retval;
		}
		nfds = args(2).int_value ();
		if (nfds <= 0) {
			error ("'nfds' should be greater than zero.\n");
			return retval;
		}
		if (nfds > FD_SETSIZE) {
			error ("'nfds' exceeds systems maximum given by FD_SETSIZE.\n");
			return retval;
		}
	}
	else {
		error ("two or three arguments required.\n");
		return retval;
	}
	if (! args(1).is_real_scalar ()) {
		error ("'timeout' must be a real scalar.\n");
		return retval;
	}
	if ((argtout = args(1).double_value ()) < 0)
		timeout = NULL;
	else {
		double ipart, fpart;
		fpart = modf (argtout, &ipart);
		tout.tv_sec = lrint (ipart);
		tout.tv_usec = lrint (fpart * 1000);
	}
	if ((nr = args(0).matrix_value().rows()) < 2 ||
	    args(0).matrix_value().columns() != 3) {
		error ("First argument must be a valid sockets matrix as returned by 'connect'\n");
		return retval;
	}
	read_fds = ColumnVector (args(0).matrix_value().column(0));

	fd_set rfds;
	FD_ZERO (&rfds);
	for (i = 1; i < read_fds.length (); i++) {
		fid = lrint (read_fds(i));
		if (fid >= FD_SETSIZE) {
			error ("filedescriptor >= FD_SETSIZE");
			return retval;
		}
		FD_SET (fid, &rfds);
	}

	if ((n = select (nfds, &rfds, NULL, NULL, timeout)) == -1) {
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
		error ("unix select returned error: %s\n",
		       err.c_str ());
		return retval;
	}
	if (nargout > 1) {
		for (i = 1, act = 0; i < read_fds.length (); i++)
			if (FD_ISSET (lrint (read_fds(i)), &rfds)) act++;
		RowVector ridx = RowVector (act);
		for (i = 1, fvec = ridx.fortran_vec ();
		     i < read_fds.length (); i++)
			if (FD_ISSET (lrint (read_fds(i)), &rfds)) {
				*fvec = double (i + 1);
				fvec++;
			}
		retval(1) = ridx;
	}

	retval(0) = n;

	return retval;
}
