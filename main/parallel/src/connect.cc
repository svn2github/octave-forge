/*

Copyright (C) 2002 Hayato Fujiwara
Copyright (C) 2010, 2011 Olaf Till <olaf.till@uni-jena.de>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; If not, see <http://www.gnu.org/licenses/>.

*/

// TODO: error handling is a mess

#include "config.h"

#include <octave/oct.h>
#include <oct-env.h>

#include <sys/socket.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/in.h> // reported necessary for FreeBSD-8

#if HAVE_UNISTD_H
#include <unistd.h>
#endif

#include "sock-stream.h"

static
void read_if_no_error (int fd, void *buf, size_t count, int est)
{
  if (! est)
    if (read (fd, buf, count) < (ssize_t)count)
      error ("read error");
}

static
void write_if_no_error (int fd, const void *buf, size_t count, int est)
{
  if (! est)
    if (write (fd, buf, count) < (ssize_t)count)
      error ("write error");
}

DEFUN_DLD (connect, args, ,
  "connect (hosts)\n\
\n\
Connect hosts and return sockets.")
{
  octave_value retval;
  int sock = 0, cols = 0, rows = 0, i, j, len, not_connected;
  double *sock_v = 0;
  if (args.length () == 1)
    {
      int pid = 0, nl;
      struct sockaddr_in *addr;
      struct hostent *he;
      octave_value hosts = args(0);
      charMatrix cm = hosts.char_matrix_value ();
      char *host, *pt;
      
      errno = 0;
      rows = cm.rows ();
      cols = cm.columns ();
      cm = cm.transpose (); 
      
      sock_v = (double *) calloc (3, rows * sizeof (double));
       

      for (i = 1; i < rows; i++)
	{
	  host = (char *) calloc (1, cols + 1);
	  strncpy (host, &cm.data ()[cols * i], cols);
	  pt = strchr (host, ' ');
	  if (pt == NULL)
	    host[cols] = '\0';
	  else
	    *pt = '\0';
	
	  sock = socket (PF_INET, SOCK_STREAM, 0);
	  if (sock == -1)
	    {
	      error ("socket error ");
	    }

	  addr=(struct sockaddr_in *) calloc(1,sizeof(struct sockaddr_in));

	  addr->sin_family = AF_INET;
	  addr->sin_port = htons (12502);
	  he = gethostbyname (host);
	  if(he == NULL)
	    {
	      error ("Unknown host %s", host);
	    }
	  memcpy (&addr->sin_addr, he->h_addr_list[0], he->h_length);

	  not_connected = 1;
	  for (j = 0; j < N_CONNECT_RETRIES; j++)
	    {
	      if((not_connected = connect (sock, (struct sockaddr *) addr,
					   sizeof (*addr))) == 0)
		break;
	      else if (errno != ECONNREFUSED)
		error("connect error ");
	      else
		usleep(5000);
	    }

	  free (addr);
	  free (host);

	  if (not_connected)

	    error ("Unable to connect to %s: Connection refused", host);

	  else
	    {
	      sock_v[i + rows] = sock;

	      int num_nodes = rows - 1;

	      pid = getpid ();
	      nl = htonl (num_nodes);
	      write_if_no_error (sock, &nl, sizeof (int), error_state);
	      nl = htonl (i);
	      write_if_no_error (sock, &nl, sizeof (int), error_state);
	      nl = htonl (pid);
	      write_if_no_error (sock, &nl, sizeof (int), error_state);
	      host = (char *) calloc (128, sizeof (char));
	      for(j = 0; j < rows; j++)
		{
		  strncpy (host, &cm.data ()[cols * j], cols);
		  pt = strchr (host, ' ');
		  if(pt == NULL)
		    host[cols] = '\0';
		  else
		    *pt='\0';
		  len = strlen (host) + 1;
		  nl = htonl (len);
		  write_if_no_error (sock, &nl, sizeof (int), error_state);
		  write_if_no_error (sock, host, len, error_state);
		}
	      free (host);
	      int comm_len;
#ifdef OCTAVE_LE_3_2_4
	      std::string directory = octave_env::getcwd ();
#else
	      std::string directory = octave_env::get_current_directory ();
#endif
	      comm_len = directory.length ();
	      nl = htonl (comm_len);
	      write_if_no_error (sock, &nl, sizeof (int), error_state);
	      write_if_no_error (sock, directory.c_str (), comm_len,
				 error_state);
	    }

	  if (error_state)
	    {
	      free (sock_v);
	      return retval;
	    }
	}

      usleep (100); // why?

      for (i = 1; i < rows; i++)
	{
	  host = (char *) calloc (1, cols + 1);

	  strncpy (host, &cm.data ()[cols * i], cols);
	  pt = strchr (host, ' ');
	  if (pt == NULL)
	    host[cols] = '\0';
	  else
	    *pt = '\0';

	  sock = socket (PF_INET, SOCK_STREAM, 0);
	  if (sock == -1)
	    {
	      perror ("socket : ");
	      exit(-1);
	    }

	  addr = (struct sockaddr_in *) calloc (1, sizeof (struct sockaddr_in));

	  addr->sin_family = AF_INET;
	  addr->sin_port = htons (12501);
	  he = gethostbyname (host);
	  if (he == NULL)
	    error ("Unknown host %s", host);
	  memcpy (&addr->sin_addr, he->h_addr_list[0], he->h_length);

	not_connected = 1;
	for (j = 0; j < N_CONNECT_RETRIES; j++)
	  {
	    if((not_connected =
	      connect (sock, (struct sockaddr *) addr, sizeof (*addr))) == 0)
	      break;
	    else if (errno != ECONNREFUSED)
	      perror("connect error ");
	    else
	      usleep(5000);
	  }
	if (not_connected)

	  error ("Unable to connect to %s: Connection refused", host);

	else
	  {
	    int bufsize = BUFF_SIZE;
	    socklen_t ol;
	    ol = sizeof (bufsize);
	    setsockopt (sock, SOL_SOCKET, SO_SNDBUF, &bufsize, ol);
	    setsockopt (sock, SOL_SOCKET, SO_RCVBUF, &bufsize, ol);
	    bufsize = 1;
	    ol = sizeof (bufsize);
	    setsockopt (sock, SOL_SOCKET, SO_REUSEADDR, &bufsize, ol);

	    int len = 0, result = 0;
	    // send pppid
	    nl = htonl (pid);
	    write_if_no_error (sock, &nl, sizeof (int), error_state);
	    // send name size
	    strncpy (host, cm.data (), cols);
	    pt = strchr (host, ' ');
	    if (pt == NULL)
	      host[cols] = '\0';
	    else
	      *pt = '\0';
	    len = strlen (host);
	    nl = htonl (len);
	    write_if_no_error (sock, &nl, sizeof (int), error_state);
	    // send name
	    write_if_no_error (sock, host, len + 1, error_state);
	    // recv result code
	    read_if_no_error (sock, &nl, sizeof (int), error_state);
	    result = ntohl (nl);
	    if (result == 0)
	      {
		sock_v[i] = sock;
		sock_v[i + 2 * rows] = 1; // means "I'm the master"
		socket_to_oct_iostream (sock);
	      }
	    else
	      close(sock);
	  }

	free(addr);
	free(host);

	if (error_state)
	  {
	    free (sock_v);
	    return retval;
	  }
	}

      char lf = '\n';
      for (i = 1; i < rows; i++)
	write_if_no_error ((int) sock_v[i + rows], &lf, sizeof (char),
			   error_state);

      if (error_state)
	{
	  free (sock_v);
	  return retval;
	}

      Matrix mx (rows, 3);
      double *tmp = mx.fortran_vec ();
      for (i = 0; i < 3 * rows; i++)
	tmp[i] = sock_v[i];
      retval = octave_value (mx);

      free (sock_v);

      return retval;
    }
  else
    {
      print_usage ();
      return retval;
    }
}


/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
