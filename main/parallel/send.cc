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
#include <map>

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

DEFUN_DLD (send, args, ,
  "send (X,sockets)\n\
\n\
Send the variable 'x' to the computers specified by matrix 'sockets'.")
{
  octave_value retval;
  
  typedef std::map<std::string, octave_value_list>::iterator iterator;
  typedef std::map<std::string, octave_value_list>::const_iterator const_iterator;

  if(args.length () ==2)
    {
      octave_value val=args(0);
      Matrix sock_m=args(1).matrix_value();
      int sock,i,k,error_code;
      int nsock=sock_m.rows();
      int type_id=0; //=val.type_id();

      if((int)sock_m.data()[0]==0){
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
		read(pollfd[k].fd,&error_code,sizeof(int));
		write(pollfd[k].fd,&error_code,sizeof(int));
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

      if(val.is_real_matrix() && !(val.is_char_matrix()))
	{
	  Matrix m=val.matrix_value();
	  int row=m.rows();
	  int col=m.columns();
	  int length=0,count,r_len;
	  
	  const double *tmp=m.data();
	  type_id=3;
	  for (i=0;i<nsock;i++){
	    sock=(int)sock_m.data()[i];
	    if(sock!=0){
	      write(sock,&type_id,sizeof(type_id));
	      write(sock,&row,sizeof(row));
	      write(sock,&col,sizeof(col));
	      length=sizeof(double)*col*row;
	      errno=0;
	      count=0;
	      r_len=BUFF_SIZE;
	      while(count <length){
		if((length-count) < BUFF_SIZE)
		  r_len=length-count;
		count +=write(sock,(double *)((int)tmp+count),r_len);
	      }

	    //	      write(sock,m.data(),length);
	    }
	  }
	  
	}
      else if(val.is_real_scalar())
	{
	  double d=val.double_value();
	  int length=sizeof(d);
	  
	  type_id=1;
	  for (i=0;i<nsock;i++){
	    sock=(int)sock_m.data()[i];
	    if(sock!=0){
	      write(sock,&type_id,sizeof(type_id));
	      write(sock,&d,length);
	    }
	  }
	}
      else if(val.is_complex_matrix())
	{
	  ComplexMatrix m=val.complex_matrix_value();
	  int row=m.rows();
	  int col=m.columns();
	  int length=0,count,r_len;
	  
	  type_id=4;
	  const Complex *tmp=m.data();
	  for (i=0;i<nsock;i++){
	    sock=(int)sock_m.data()[i];
	    if(sock!=0){
	      write(sock,&type_id,sizeof(type_id));
	      write(sock,&row,sizeof(row));
	      write(sock,&col,sizeof(col));
	      length=sizeof(Complex)*col*row;
	      count=0;
	      r_len=BUFF_SIZE;
	      while(count <length){
		if((length-count) < BUFF_SIZE)
		  r_len=length-count;
		count +=write(sock,(Complex *)((int)tmp+count),r_len);
	      }
	      //	      write(sock,m.data(),length);
	    }
	  }
	}
      else if(val.is_complex_scalar())
	{
	  Complex cx=val.complex_value();
	  int length=sizeof(cx);
	  
	  type_id=2;
	  for (i=0;i<nsock;i++){
	    sock=(int)sock_m.data()[i];
	    if(sock!=0){
	      write(sock,&type_id,sizeof(type_id));
	      write(sock,&cx,length);
	    }
	  }
	}
      else if(val.is_char_matrix())
	{
	  int row=val.rows();
	  int col=val.columns();
	  int length=sizeof(char)*row*col,count,r_len;
	  charMatrix cmx=val.char_matrix_value();
	  
	  type_id=6;
	  const char *tmp=cmx.data();
	  for (i=0;i<nsock;i++){
	    sock=(int)sock_m.data()[i];
	    if(sock!=0){
	      write(sock,&type_id,sizeof(type_id));
	      write(sock,&row,sizeof(row));
	      write(sock,&col,sizeof(col));
	      count=0;
	      r_len=BUFF_SIZE;
	      while(count <length){
		if((length-count) < BUFF_SIZE)
		  r_len=length-count;
		count +=write(sock,(char *)((int)tmp+count),r_len);
	      }
	      //	      write(sock,cmx.data(),length);
	    }
	  }
	}
      else if(val.is_map())
	{
	  Octave_map map=val.map_value();
	  octave_value_list ov_list;
	  const_iterator p = map.begin();
	  iterator end=map.end();
	  int i,length=map.length(),key_len=0;
	  std::string key=p->first;
	  
  	  for (i=0;i<nsock;i++){
  	    sock=(int)sock_m.data()[i];
	    ov_list(1)=octave_value(sock_m.row(i));
	    type_id=7;
	    if(sock!=0){
	      write(sock,&type_id,sizeof(type_id));
	      write(sock,&length,sizeof(length));
	      for(i=0;i<length;i++){
		key_len=key.length();
		write(sock,&key_len,sizeof(key_len));
		ov_list(0)=map[key](0);
		write(sock,key.c_str(), key_len);
		Fsend(ov_list,0);
		p++;
		if(p==end)
		  break;
		key=p->first;
	      }
	    }
	  }
	}
      else
	error("unsupported type %d",type_id);
    }
  else
    print_usage ("send");
  
  return retval;
  
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
