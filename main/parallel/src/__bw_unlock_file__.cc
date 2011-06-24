// Copyright (C) 2009 Olaf Till <olaf.till@uni-jena.de>

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

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

DEFUN_DLD (__bw_unlock_file__, args, , "Close fd in arg.\n\
Internal function of parallel package, function may change.\n") {

  octave_value retval;

  int ret;

  while ((ret = close (args(0).int_value())) < 0 && errno == EINTR);
  if (ret < 0) {
    error ("unlock_file: error closing file");
    return retval;
  }

  return retval;

}
