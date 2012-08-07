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

#include <sys/socket.h>
#include <sys/poll.h>
#include <netinet/in.h>
#include <netdb.h>

#if HAVE_UNISTD_H
#include <unistd.h>
#endif

DEFUN_DLD (send, args, , "send (X, sockets)\n\
\n\
Send the variable 'X' to the computers specified by matrix 'sockets'\n.")
{
  octave_value retval;

  if (args.length () != 2)
    {
      error ("two arguments required\n");

      return retval;
    }

  Matrix sockets = args(1).matrix_value ();

  if (error_state)
    return retval;

  int rows = sockets.rows ();

  if ((int) sockets.data ()[2 * rows]) // I'm the master
    {
      // This is code from original send.cc by Hayato Fujiwara

      int num, pid, sock, nl, error_code;
      struct pollfd *pollfd;
      pollfd = (struct pollfd *) malloc (rows * sizeof (struct pollfd));
      for(int i = 0; i < rows; i++)
	{
	  sock = (int) sockets.data ()[i + rows];
	  pollfd[i].fd = sock;
	  pollfd[i].events = POLLIN;
	}
	
      num = poll (pollfd, rows, 0);
      if (num)
	{
	  for (int k = 0; k < rows; k++)
	    {
	      if (pollfd[k].revents && (pollfd[k].fd !=0))
		{
		  sockaddr_in r_addr;
		  struct hostent *hehe;
		  socklen_t len = sizeof (r_addr);
		  getpeername (pollfd[k].fd, (sockaddr*) &r_addr, &len);
		  hehe = gethostbyaddr ((char *) &r_addr.sin_addr.s_addr,
					sizeof (r_addr.sin_addr), AF_INET);

		  if (pollfd[k].revents & POLLIN)
		    {
		      pid = getpid ();
		      if (read (pollfd[k].fd, &nl, sizeof (int)) <
			  sizeof (int))
			{
			  error ("read error");
			  break;
			}
		      error_code = ntohl (nl);
		      if (write (pollfd[k].fd, &nl, sizeof (int)) <
			  sizeof (int))
			{
			  error ("write error");
			  break;
			}
		      error ("error occurred in %s\n\tsee "
			     "%s:/tmp/octave_error-%s_%5d.log for detail",
			     hehe->h_name, hehe->h_name, hehe->h_name, pid);
		    }
		  if (pollfd[k].revents & POLLERR)
		    {
		      error ("Error condition - %s", hehe->h_name);
		      break;
		    }
		  if (pollfd[k].revents & POLLHUP)
		    {
		      error("Hung up - %s", hehe->h_name);
		      break;
		    }
		  if (pollfd[k].revents & POLLNVAL)
		    {
		      error("fd not open - %s", hehe->h_name);
		      break;
		    }
		}
	    }
	}

	free (pollfd);

	if (error_state)
	  return retval;
    }

  double sid;

  for (int id = 0; id < rows; id++)
    {
      if ((sid = sockets(id, 0)) != 0)
	{
	  octave_stream os = octave_stream_list::lookup
	    (octave_value (sid), "send");

	  if (error_state)
	    {
	      error ("no valid stream id\n");

	      return retval;
	    }
	  if (! os.is_open ())
	    {
	      error ("stream not open\n");

	      return retval;
	    }

	  std::ostream *tps = os.output_stream ();
	  std::ostream& ps = *tps;

	  write_header (ps, LS_BINARY);

	  save_binary_data (ps, args(0), "a", "", false, false);

	  ps.flush ();
	}
    }

  return retval;
}
