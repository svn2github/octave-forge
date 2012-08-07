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

#include <octave/oct.h>

#include <oct-env.h>
#include <file-io.h>
#include <sighandlers.h>
#include <parse.h>
#include <cmd-edit.h>
#include <toplev.h>

#include <sys/socket.h>
#include <iostream>
#include <sys/stat.h>
#include <sys/poll.h>
#include <errno.h>
#include <netdb.h>
#include <netinet/in.h> // reported necessary for FreeBSD-8

#if HAVE_UNISTD_H
#include <unistd.h>
#endif

#include "sock-stream.h"

#include "config.h"

#ifndef OCTAVE_LE_3_2_4

// Octave > 3.2.4 does not have these in a header file, but in
// sighandlers.cc, and uses gnulib:: for these. So this is copied from
// Octave-3.2.4.
#define BLOCK_SIGNAL(sig, nvar, ovar) \
  do \
    { \
      sigemptyset (&nvar); \
      sigaddset (&nvar, sig); \
      sigemptyset (&ovar); \
      sigprocmask (SIG_BLOCK, &nvar, &ovar); \
    } \
  while (0)

#if !defined (SIGCHLD) && defined (SIGCLD)
#define SIGCHLD SIGCLD
#endif

// FIXME: Octave-3.2.4 had HAVE_POSIX_SIGNALS in config.h, newer
// Octave has not (probably due to using gnulib?). We have not this
// test in configure now, but assume HAVE_POSIX_SIGNALS defined.
#define BLOCK_CHILD(nvar, ovar) BLOCK_SIGNAL (SIGCHLD, nvar, ovar)
#define UNBLOCK_CHILD(ovar) sigprocmask (SIG_SETMASK, &ovar, 0)
// #else
// #define BLOCK_CHILD(nvar, ovar) ovar = sigblock (sigmask (SIGCHLD))
// #define UNBLOCK_CHILD(ovar) sigsetmask (ovar)

#endif

/* children are not killed on parent exit; for that octave_child_list
   can not be used and an own SIGCHLD handler is needed */

static
bool pserver_child_event_handler (pid_t pid, int ev)
{
  return 1; // remove child from octave_child_list
}

static
void read_or_exit (int fd, void *buf, size_t count)
{
  if (read (fd, buf, count) < (ssize_t)count)
    {
      error ("read error");
      _exit (1);
    }
}

static
void write_or_exit (int fd, const void *buf, size_t count)
{
  if (write (fd, buf, count) < (ssize_t)count)
    {
      error ("write error");
      _exit (1);
    }
}

void
reval_loop (int sock)
{
  // The big loop.

  int len = 0;
  char *ev_str;
  std::string s;

  char dummy;
  read_or_exit (sock, &dummy, sizeof (char));
  int p_err, count, r_len, num, fin, nl;
  struct pollfd *pollfd;

  pollfd = (struct pollfd *) malloc (sizeof (struct pollfd));
  pollfd[0].fd = sock;
  pollfd[0].events = POLLIN;

  while (true) // function does not return
    {
      pollfd[0].revents = 0;
      num = poll (pollfd, 1, -1);
      if (num)
	{
	  if (pollfd[0].revents && (pollfd[0].fd != 0))
	    {
	      if (pollfd[0].revents & POLLIN)
		{
		  read_or_exit (sock, &nl, sizeof(int));
		  len = ntohl (nl);
		}
	      if (pollfd[0].revents & POLLERR)
		{
		  std::cerr << "Error condition " << std::endl;
		  _exit (POLLERR);
		}
	      if (pollfd[0].revents & POLLHUP)
		{
		  std::cerr << "Hung up " << std::endl;
		  _exit (POLLHUP);
		}
	      if (pollfd[0].revents & POLLNVAL)
		{
		  std::cerr << "fd not open " << std::endl;
		  _exit (POLLNVAL);
		}
	    }
	}
      ev_str = new char[len + 1];
      count = 0;
      r_len = BUFF_SIZE;
      while (count < len)
	{
	  if ((len - count) < BUFF_SIZE)
	    r_len = len - count;
	  count += (fin = read (sock, (ev_str + count), r_len));
	  if (fin <= 0)
	    {
	      error ("read error");
	      _exit (1);
	    }
	}
      ev_str[len] = '\0';

      s = (std::string) ev_str;
      eval_string (s, false, p_err, 0);

      delete (ev_str);
      nl = 0;
      if (error_state)
        {
	  nl = 1;
	  error_state = 0;
        }
      else if (p_err)
	nl = 1;
      if (nl)
	{
	  nl = htonl (nl);
	  write_or_exit (sock, &nl, sizeof (int));
	  read_or_exit (sock, &nl, sizeof (int));
	}
      else
        {
          if (octave_completion_matches_called)
            octave_completion_matches_called = false;
          else
            command_editor::increment_current_command_number ();
        }
    }

}

DEFUN_DLD (pserver,,,
  "pserver\n\
\n\
Connect hosts and return sockets.")
{
      FILE *pidfile = 0;
      int ppid, len = 118;
      char hostname[120], pidname[128], errname[128], bakname[128];
      struct stat fstat;

      gethostname (hostname, len);
      sprintf (pidname, "/tmp/.octave-%s.pid", hostname);
      if (stat (pidname, &fstat) == 0)
	{
	  std::cerr << "octave : " << hostname << ": server already running"
		    << std::endl;
	  clean_up_and_exit (1);
	}

      // initialize exit function
      feval ("__pserver_exit__", octave_value (hostname), 0);

      if (fork())
        clean_up_and_exit (0);

      // register exit function
      feval ("atexit", octave_value ("__pserver_exit__"), 0);

      /* Touch lock file, mark for deletion. */
      ppid = getpid ();
      mark_for_deletion (pidname);
      pidfile = fopen (pidname, "w");
      fprintf (pidfile, "%d\n", ppid);
      fclose (pidfile);
      std::cout << pidname << std::endl;

      // avoid dumping octave_core if killed by a signal
      feval ("sigterm_dumps_octave_core", octave_value (0), 0);
      feval ("sighup_dumps_octave_core", octave_value (0), 0);

      /* Redirect stdin and stdout to /dev/null. */
      if (! freopen ("/dev/null", "r", stdin))
	{
	  perror ("freopen ");
	  clean_up_and_exit (1);
	}
      if (! freopen ("/dev/null", "w", stdout))
	{
	  perror ("freopen ");
	  clean_up_and_exit (1);
	}

      sprintf (errname, "/tmp/octave_error-%s.log", hostname);
      if (stat (errname, &fstat) == 0)
	{
	  sprintf (bakname, "/tmp/octave_error-%s.bak", hostname);
	  rename (errname, bakname);
	}
      if (! freopen (errname, "w", stderr))
	{
	  perror ("freopen ");
	  clean_up_and_exit (1);
	} 

      int sock = 0, asock = 0, dsock = 0, dasock = 0, pid = 0;
      struct sockaddr_in *addr, rem_addr;;

      addr = (struct sockaddr_in *) calloc (1, sizeof (struct sockaddr_in));

      sock = socket (PF_INET, SOCK_STREAM, 0);
      if (sock == -1)
	{
	  perror ("socket ");
	  int len = 118;
	  char hostname[120], pidname[128];
	  gethostname (hostname, len);
	  sprintf (pidname, ".octave-%s.pid", hostname);
	  remove (pidname);
	  close_files ();
	  clean_up_and_exit (1);
	}

      addr->sin_family = AF_INET;
      addr->sin_port = htons (12502);
      addr->sin_addr.s_addr = INADDR_ANY;

      if (bind (sock, (struct sockaddr *) addr, sizeof (*addr)))
	{
	  perror ("bind ");
	  int len = 118;
	  char hostname[120], pidname[128];
	  gethostname (hostname, len);
	  sprintf (pidname, ".octave-%s.pid", hostname);
	  remove (pidname);
	  close_files ();
	  clean_up_and_exit (1);
	}
      free (addr);

      if (listen (sock, 1))
	{
	  perror ("listen ");
	  clean_up_and_exit (1);
	}


      dsock = socket (PF_INET, SOCK_STREAM, 0);
      if (dsock == -1)
	{
	  perror ("socket : ");
	  clean_up_and_exit (-1);
	}

      addr = (struct sockaddr_in *) calloc (1, sizeof (struct sockaddr_in));

      addr->sin_family = AF_INET;
      addr->sin_port = htons (12501);
      addr->sin_addr.s_addr = INADDR_ANY;


      if (bind (dsock, (struct sockaddr *) addr, sizeof (*addr)))
	{
	  perror ("bind : ");
	  clean_up_and_exit (-1);
	}
      if (listen (dsock, SOMAXCONN))
	{
	  perror ("listen : ");
	  clean_up_and_exit (-1);
	}
      free (addr);
      int param = 1;
      socklen_t ol = sizeof (param);
      setsockopt (sock, SOL_SOCKET, SO_REUSEADDR, &param, ol);
      setsockopt (dsock, SOL_SOCKET, SO_REUSEADDR, &param, ol);

      int val = 1, num_nodes, me, i, j = 0, pppid = 0, rpppid = 0, result = 0,
	nl;
      int *sock_v;
      char **host_list,rem_name[128];
      struct hostent *he;      

      ol = sizeof (val);

      for(;;)
	{
	  asock = accept (sock, 0, 0);
	  if (asock == -1)
	    {
	      perror ("accept com");
	      clean_up_and_exit (1);
	    }
	  /* Normal production daemon.  Fork, and have the child process
             the connection.  The parent continues listening. */

	  // remove non-existing children from octave_child_list
	  OCTAVE_QUIT;

	  sigset_t nset, oset, dset;

	  BLOCK_CHILD (nset, oset);
	  BLOCK_SIGNAL (SIGTERM, nset, dset);
	  BLOCK_SIGNAL (SIGHUP, nset, dset);

	  // restores all signals to state before BLOCK_CHILD
#define RESTORE_SIGNALS(ovar) UNBLOCK_CHILD(ovar)

	  if ((pid = fork ()) == -1)
	    {
	      perror ("fork ");
	      clean_up_and_exit (1);
	    }
	  else if (pid == 0) 
	    {
	      close (sock);
	      signal (SIGCHLD, SIG_DFL);
	      signal (SIGTERM, SIG_DFL);
	      signal (SIGQUIT, SIG_DFL);

	      RESTORE_SIGNALS (oset);

	      val = 1;
	      ol = sizeof (val);
	      setsockopt (asock, SOL_SOCKET, SO_REUSEADDR, &val, ol);

	      read_or_exit (asock, &nl, sizeof (int));
	      num_nodes = ntohl (nl);
	      read_or_exit (asock, &nl, sizeof (int));
	      me = ntohl (nl);
	      read_or_exit (asock, &nl, sizeof (int));
	      pppid = ntohl (nl);
	      sock_v = (int *) calloc ((num_nodes + 1) * 3, sizeof (int));
	      host_list = (char **) calloc (num_nodes + 1, sizeof (char *));
	      for (i = 0; i <= num_nodes; i++)
		{
		  read_or_exit (asock, &nl, sizeof (int));
		  len = ntohl (nl);
		  host_list[i] = (char *) calloc (len, sizeof (char));
		  read_or_exit (asock, host_list[i], len);
		}

	      sprintf (errname, "/tmp/octave_error-%s_%05d.log", hostname,
		       pppid);
	      if (stat (errname, &fstat) == 0)
		{
		  sprintf (bakname, "/tmp/octave_error-%s_%05d.bak", hostname,
			   pppid);
		  rename (errname, bakname);
		}
	      if (! freopen (errname, "w", stderr))
		{
		  perror ("freopen ");
		  _exit (1);
		}

	      for (i = 0; i < me; i++)
		{
		  //      recv;

		  len=sizeof(rem_addr);

		  while (1)
		    {
		      dasock = accept (dsock, (sockaddr *) &rem_addr,
				       (socklen_t *) &len);
		      if (dasock == -1)
			{
			  perror("accept dat ");
			  _exit(-1);
			}
		      int bufsize = BUFF_SIZE;
		      socklen_t ol;
		      ol = sizeof (bufsize);
		      setsockopt (dasock, SOL_SOCKET, SO_SNDBUF, &bufsize, ol);
		      setsockopt (dasock, SOL_SOCKET, SO_RCVBUF, &bufsize, ol);
		      bufsize = 1;
		      ol = sizeof (bufsize);
		      setsockopt (dasock, SOL_SOCKET, SO_REUSEADDR, &bufsize,
				  ol);

		      // recv pppid (of connecting process at master)
		      read_or_exit (dasock, &nl, sizeof (int));
		      rpppid = ntohl (nl);
		      // recv name size
		      read_or_exit (dasock, &nl, sizeof (int));
		      len = ntohl (nl);
		      // recv name
		      read_or_exit (dasock, rem_name, len + 1);
		      rem_name [len] = '\0';

		      for (j = 0; j < me; j++)
			if (strcmp (rem_name, host_list[j]) == 0)
			  {
			    sock_v[j] = dasock;
			    result = 0;
			    break;
			  }
			else
			  result=-1;
		      // send result code
		      if (result == 0)
			{
			  if (pppid == rpppid)
			    {
			      nl = htonl (result);
			      write_or_exit (dasock, &nl, sizeof (int));
			      socket_to_oct_iostream (dasock);
			      break;
			    }
			  // And else? Shouldn't this test have been
			  // made before? What is the policy if a
			  // different process at the master meddles in?
			}
		      else
			{
			  result = -1;
			  nl = htonl (result);
			  write_or_exit (dasock, &nl, sizeof (int));
			  close (dasock);
			  sleep (1);
			}
		    }
		  if (error_state)
		    _exit (-1);
		}

	      errno = 0;

	      for (i = me + 1; i <= num_nodes; i++)
		{
		  dsock = -1;
		  // connect;
		  dsock = socket (PF_INET, SOCK_STREAM, 0);
		  if (dsock == -1)
		    {
		      perror ("socket : ");
		      _exit(-1);
		    }
		  addr = (struct sockaddr_in *)
		    calloc (1, sizeof (struct sockaddr_in));

		  addr->sin_family = AF_INET;
		  addr->sin_port = htons (12501);
		  he = gethostbyname (host_list[i]);
		  if (he == NULL)
		    error("Unknown host %s",host_list[i]);
		  memcpy (&addr->sin_addr, he->h_addr_list[0], he->h_length);
		  while (1)
		    {
		      for (j = 0; j < N_CONNECT_RETRIES; j++)
			if (connect (dsock, (struct sockaddr *) addr,
				     sizeof (*addr))==0)
			  break;
			else if (errno != ECONNREFUSED)
			  {
			    perror ("connect : ");
			    _exit(-1);
			  }
			else
			  usleep(5000);
		      int bufsize = BUFF_SIZE;
		      socklen_t ol;
		      ol = sizeof (bufsize);
		      setsockopt (dsock, SOL_SOCKET, SO_SNDBUF, &bufsize, ol);
		      setsockopt (dsock, SOL_SOCKET, SO_RCVBUF, &bufsize, ol);
		      bufsize = 1;
		      ol = sizeof (bufsize);
		      setsockopt (dsock, SOL_SOCKET, SO_REUSEADDR, &bufsize,
				  ol);

		      // send pppid
		      nl = htonl (pppid);
		      write_or_exit (dsock, &nl, sizeof (int));
		      // send name size
		      len = strlen (host_list[me]);
		      nl = htonl (len);
		      write_or_exit (dsock, &nl, sizeof (int));
		      // send name
		      write_or_exit (dsock, host_list[me], len + 1);
		      // recv result code
		      read_or_exit (dsock, &nl, sizeof (int));
		      result = ntohl (nl);

		      if (result == 0)
			{
			  sock_v[i] = dsock;
			  socket_to_oct_iostream (dsock);
			  break;
			}
		      else
			close (dsock);
		    }
		  free (addr);
		  if (error_state)
		    _exit (-1);
		}
	      for (i = 0; i <= num_nodes; i++)
		free (host_list[i]);
	      free (host_list);

	      char * s;
	      int stat;

	      s = (char *) calloc (32, sizeof (char));
	      sprintf (s, "sockets=zeros(%d,3)", num_nodes + 1);
	      eval_string (std::string (s), true, stat);
	      for (i = 0; i <= num_nodes; i++)
		{
		  sprintf (s, "sockets(%d,:)=[%d,0,%d]", i + 1, sock_v[i],
			   sock_v[i + 2 * (num_nodes + 1)]);
		  eval_string (std::string (s), true, stat);
	      }

	      free (sock_v);

	      interactive = false;

	      line_editing = false;

	      char *newdir;
	      int newdir_len;
	      read_or_exit (asock, &nl, sizeof (int));
	      newdir_len = ntohl (nl);
	      newdir = (char *) calloc (sizeof (char), newdir_len + 1);
	      read_or_exit (asock, newdir, newdir_len);
	      int cd_ok = octave_env::chdir (newdir);
	      if (! cd_ok)
		octave_env::chdir ("/tmp");

	      reval_loop (asock); // does not return
	    }

	  // parent

	  octave_child_list::insert (pid, pserver_child_event_handler);

	  RESTORE_SIGNALS (oset);

	  close (asock);
	}
      close (sock);
      clean_up_and_exit (-1);
}
