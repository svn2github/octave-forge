// Copyright (C) 2008 Olaf Till <olaf.till@uni-jena.de>

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

#include <unistd.h>
#include <signal.h>

DEFUN_DLD (__exit__, args, , 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} __exit__ (status)\n\
This is a wrapper over the POSIX _exit() system call. Calling this function\n\
will terminate the running process immediatelly, bypassing normal Octave\n\
terminating sequence. It is suitable to terminate a forked process. It\n\
should be considered expert-only and not to be used in normal code.\n\
@end deftypefn") 
{
  _exit (args.length () > 0 ? args(0).int_value () : 0);
}
