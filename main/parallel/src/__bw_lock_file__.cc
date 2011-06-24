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

DEFUN_DLD (__bw_lock_file__, args, , "Open the file named in arg and put an advisory write lock on it.\n\
Internal function of parallel package, function may change.\n") {

  octave_value retval;

  int fd, ret;
  struct flock fl;

  while ((fd = open (args(0).char_matrix_value().row_as_string(0).c_str(),
		  O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR)) < 0 &&
	 errno == EINTR);
  if (fd < 0) {
    error ("lock_file: error opening file");
    return retval;
  }

  fl.l_type = F_WRLCK;
  fl.l_whence = SEEK_SET;
  fl.l_start = 0;
  fl.l_len = 0;

  while ((ret = fcntl (fd, F_SETLKW, &fl)) < 0 && errno == EINTR);
  if (ret < 0) {
    error ("lock_file: error locking file");
    return retval;
  }

  return octave_value (fd);

}
