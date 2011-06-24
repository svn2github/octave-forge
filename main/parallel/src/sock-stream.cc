// Copyright (C) 2010, 2011 Olaf Till

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

#include <errno.h>

#include <oct-stream.h>
#include <oct-prcstrm.h>

static void handle_errno (const std::string msg, const int err_no)
{
  std::string err;

  switch (err_no)
    {
    case EINVAL:
      err = "EINVAL";
      break;
    case ENOMEM:
      err = "ENOMEM";
      break;
    case EACCES:
      err = "EACCES";
      break;
    case EAGAIN:
      err = "EAGAIN";
      break;
    case EEXIST:
      err = "EEXIST";
      break;
    case EFAULT:
      err = "EFAULT";
      break;
    case EFBIG:
      err = "EFBIG";
      break;
    case EINTR:
      err = "EINTR";
      break;
    case EISDIR:
      err = "EISDIR";
      break;
    case ELOOP:
      err = "ELOOP";
      break;
    case EMFILE:
      err = "EMFILE";
      break;
    case ENAMETOOLONG:
      err = "ENAMETOOLONG";
      break;
    case ENFILE:
      err = "ENFILE";
      break;
    case ENODEV:
      err = "ENODEV";
      break;
    case ENOENT:
      err = "ENOENT";
      break;
    case ENOSPC:
      err = "ENOSPC";
      break;
    case ENOTDIR:
      err = "ENOTDIR";
      break;
    case ENXIO:
      err = "ENXIO";
      break;
    case EPERM:
      err = "EPERM";
      break;
    case EROFS:
      err = "EROFS";
      break;
    case ETXTBSY:
      err = "ETXTBSY";
      break;
    case EBADF:
      err = "EBADF";
      break;
    case EDEADLK:
      err = "EDEADLK";
      break;
    case ENOLCK:
      err = "ENOLCK";
      break;
    default:
      err = "unknown error";
    }

  error ("%s: %s\n", msg.c_str (), err.c_str ());
}

int socket_to_oct_iostream (int sd)
{
  errno = 0;

  FILE *fid = fdopen (sd, "rb+");

  if (! fid)
    {
      handle_errno
	("could not get C stream from socket descriptor with 'fdopen'",
	 errno);

      return -1;
    }

  oct_mach_info::float_format flt_fmt =
    oct_mach_info::string_to_float_format ("ieee-le");

  std::ios::openmode md = std::ios::in | std::ios::out;

  octave_stream os =
    octave_stdiostream::create ("", fid, md, flt_fmt);

  if (! os)
    {
      error ("could not get Octave stream from C stream");

      return -1;
    }

  octave_stream_list::insert (os);

  return sd; // Octave assigns the same number as in 'sd'
}


/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
