/*

Copyright (C) 2002 Hayato Fujiwara

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

#include "defun-dld.h"
#include "dirfns.h"
#include "error.h"
#include "help.h"
#include "oct-map.h"
#include "systime.h"
#include "ov.h"
#include "oct-obj.h"
#include "utils.h"
#include "oct-env.h"

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/poll.h>
#include <netinet/in.h>
#include <errno.h>
#include <netdb.h>
#include <unistd.h>

#define BUFF_SIZE SSIZE_MAX

// COMM

DEFUN_DLD (sclose, args, ,
  "sclose (sockets)\n\
\n\
Close sockets")
{
  octave_value retval;
  errno=0;

  if(args.length () == 1)
    {
      int i,nsock=0,sock,k,err=0,nl;

      nsock=args(0).matrix_value().rows()*2;
      
      if((int)args(0).matrix_value().data()[0]==0){
	int num,pid;
	struct pollfd *pollfd;
	pollfd=(struct pollfd *)malloc(nsock*sizeof(struct pollfd));
	for(i=0;i<nsock;i++){
	  sock=(int)args(0).matrix_value().data()[i+nsock];
	  pollfd[i].fd=sock;
	  pollfd[i].events=0;
	  pollfd[i].events=POLLIN|POLLERR|POLLHUP;
	}
	
	num=poll(pollfd,nsock,0);
	if(num){
	  for(k=0;k<nsock;k++){
	    if(pollfd[k].revents && (pollfd[k].fd !=0)){
	      sockaddr_in r_addr;
	      struct hostent *hehe;
	      socklen_t len = sizeof(r_addr);
	      getpeername(pollfd[k].fd, (sockaddr*)&r_addr, &len );
	      hehe=gethostbyaddr((char *)&r_addr.sin_addr.s_addr,sizeof(r_addr.sin_addr), AF_INET);
	      
	      if(pollfd[k].revents&POLLIN){
		pid=getpid();

		if (read(pollfd[k].fd,&nl,sizeof(int)) < (ssize_t)sizeof(int))
		  error ("read error");
		if (! error_state)
		  if (write(pollfd[k].fd,&nl,sizeof(int)) < (ssize_t)sizeof(int))
		    error ("write error");
		error("error occurred in %s\n\tsee %s:/tmp/octave_error-%s_%5d.log for detail",hehe->h_name,hehe->h_name,hehe->h_name,pid );
	      }
	      if(pollfd[k].revents&POLLERR){
		error("Error condition - %s",hehe->h_name );
	      }
	      if(pollfd[k].revents&POLLHUP){
		error("Hung up - %s",hehe->h_name );
	      }
	    }
	  }
	}
      }

      for(i=nsock-1;i>=0;i--){
	sock=(int)args(0).matrix_value().data()[i];
	if(sock!=0){
	  if(close(sock)!=0)
	    err++;
	}
      }
      if(err)
	error("sclose error %d",err);
      retval=(double)err;
    }
  else
    print_usage ();

  return retval;

}


/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
