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
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.

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
#include <arpa/inet.h>
#include <errno.h>
#include <netdb.h>
#include <unistd.h>

#define BUFF_SIZE SSIZE_MAX

// COMM

DEFUN_DLD (reval, args, ,
  "reval (commands,sockets)\n\
\n\
Evaluate 'commands' at the remote hosts specified by the matrix 'sockets'.")
{
  octave_value retval;

  if(args.length () ==2)
    {
      int sock,row=0,col=0,nsock=0,i,j,k;
      int error_code,count=0,r_len=0,nl;
      octave_value val=args(0);
      Matrix sock_m=args(1).matrix_value();
      charMatrix cm=val.char_matrix_value();
      char comm[256];
      
      nsock=sock_m.rows();

      row=val.rows();
      col=val.columns();

      if(sock_m.data()[0]==0){
	int num,pid;
	struct pollfd *pollfd;
	pollfd=(struct pollfd *)malloc(nsock*sizeof(struct pollfd));
	for(i=0;i<nsock;i++){
	  sock=(int)sock_m.data()[i+nsock];
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
		read(pollfd[k].fd,&nl,sizeof(int));
		error_code=ntohl(nl);
		write(pollfd[k].fd,&nl,sizeof(int));
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

      for(i=0;i<nsock;i++){
	sock=(int)sock_m.data()[i+nsock];
	if(sock!=0){
	  for(j=0;j<row;j++){
	    strncpy(comm,(cm.extract(j,0,j,col-1).data()),col);
	    comm[col]='\n';
	    comm[col+1]='\0';
	    nl=htonl(col);
	    write(sock,&nl,sizeof(int));
	    count=0;
	    r_len=BUFF_SIZE;
	    while(count <col){
	      if((col-count) < BUFF_SIZE)
		r_len=col-count;
	      count +=write(sock,(char *)((int)comm+count),r_len);
	    }

	    // Blocking Execution
//	    read(sock,&error_state,sizeof(int));
//	    if(error_state){
//	      error("Error occurred on %d" sock);
//	    }

	  }
	}
      }
    }
  else
    print_usage ("reval");

  return retval;

}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
