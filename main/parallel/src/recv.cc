// Copyright (C) 2002 Hayato Fujiwara

// Copyright (C) 2010, 2011 Olaf Till <olaf.till@uni-jena.de>

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

#include <sys/socket.h>
#include <sys/poll.h>
#include <netinet/in.h>
#include <netdb.h>

#if HAVE_UNISTD_H
#include <unistd.h>
#endif

DEFUN_DLD (recv, args, nargout, "recv (socket)\n\
\n\
Receive a variable from the computer specified by the row vector 'socket'.\n")
{
  octave_value retval;

  if (args.length () != 1)
    {
      error ("exactly one argument required\n");
      return retval;
    }

  Matrix socket = args(0).matrix_value ();

  if (error_state)
    return retval;

  if ((int) socket.data ()[2]) // I'm the master
    {
      // This is code from original send.cc by Hayato Fujiwara

      int num, pid, sock, nl, error_code;
      struct pollfd spollfd;

      sock = (int) socket.data ()[1];
      spollfd.fd = sock;
      spollfd.events = POLLIN;
	
      num = poll (&spollfd, 1, 0);
      if (num)
	{
	  if (spollfd.revents && (spollfd.fd !=0))
	    {
	      sockaddr_in r_addr;
	      struct hostent *hehe;
	      socklen_t len = sizeof (r_addr);
	      getpeername (spollfd.fd, (sockaddr*) &r_addr, &len);
	      hehe = gethostbyaddr ((char *) &r_addr.sin_addr.s_addr,
				    sizeof (r_addr.sin_addr), AF_INET);

	      if (spollfd.revents & POLLIN)
		{
		  pid = getpid ();
		  if (read (spollfd.fd, &nl, sizeof (int)) < sizeof (int))
		    error ("read error");
		  error_code = ntohl (nl);
		  if (write (spollfd.fd, &nl, sizeof (int)) < sizeof (int))
		    error ("write error");
		  error ("error occurred in %s\n\tsee "
			 "%s:/tmp/octave_error-%s_%5d.log for detail",
			 hehe->h_name, hehe->h_name, hehe->h_name, pid);
		}
	      if (spollfd.revents & POLLERR)
		error ("Error condition - %s", hehe->h_name);
	      if (spollfd.revents & POLLHUP)
		error("Hung up - %s", hehe->h_name);
	      if (spollfd.revents & POLLNVAL)
		error("fd not open - %s", hehe->h_name);
	    }
	}

      if (error_state)
	return retval;
    }


  octave_stream is = octave_stream_list::lookup
    (octave_value (socket(0, 0)), "recv");

  if (error_state) return retval;

  if (! is.is_open ())
    {
      error ("stream not open\n");
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

  // The next two functions called pretend to have been called
  // from 'load' in their error messages, read_binary_data also
  // wants to have the filename ...

  if (read_binary_file_header (ps, swap, flt_fmt, false) < 0)
    return retval;

  name = read_binary_data (ps, swap, flt_fmt, "", global, tc, doc);

  // read_binary_data will give no error with EOF at start
  // of reading, but in this case it is an error, since
  // after the header exactly one variable is expected. This
  // is mended by asking for EOF here.

  if (ps.eof () || error_state || name.empty ())
    {
      error ("error in reading variable data\n");
      return retval;
    }

  if  (! tc.is_defined ())
    {
      // What means this?
      error ("error in reading variable\n");
      return retval;
    }


  return retval = tc;
}
