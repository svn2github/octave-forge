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

#include "swab.h"

#define BUFF_SIZE SSIZE_MAX

// COMM

DEFUN_DLD (recv, args, ,
  "recv (socket)\n\
\n\
Receive a variable from the computer specified by the row vector 'socket'.")
{
  octave_value retval;
  int type_id=0,sock;
  
  if(args.length () == 1)
    {
      Matrix m=args(0).matrix_value();
      struct pollfd *pollfd,*pollfd_d;
      int num,error_code,sock_c,num_d,nl,endian;
      
      sock=(int) m.data()[0];
      sock_c=(int) m.data()[1];
      endian=(int) m.data()[2];

      pollfd=(struct pollfd *)malloc(sizeof(struct pollfd));
      pollfd_d=(struct pollfd *)malloc(sizeof(struct pollfd));
      pollfd[0].fd=sock_c;
      pollfd_d[0].fd=sock;
      pollfd[0].events=0;
      pollfd[0].events=POLLIN|POLLERR|POLLHUP;
      pollfd_d[0].events=pollfd[0].events;
      pollfd_d[0].revents=0;

      num_d=0;
      while(!num_d){
	if(sock_c){
	  int pid;
	  pollfd[0].revents=0;
	  num=poll(pollfd,1,0);
	  if(num){
	    if(pollfd[0].revents && (pollfd[0].fd !=0)){
	      sockaddr_in r_addr;
	      struct hostent *hehe;
	      socklen_t len = sizeof(r_addr);
	      getpeername(pollfd[0].fd, (sockaddr*)&r_addr, &len );
	      hehe=gethostbyaddr((char *)&r_addr.sin_addr.s_addr,sizeof(r_addr.sin_addr), AF_INET);
	      if(pollfd[0].revents&POLLIN){
		pid=getpid();
		read(pollfd[0].fd,&nl,sizeof(int));
		error_code=ntohl(nl);
		write(pollfd[0].fd,&nl,sizeof(int));
		error("error occurred in %s\n\tsee %s:/tmp/octave_error-%s_%5d.log for detail",hehe->h_name,hehe->h_name,hehe->h_name,pid );
	      }
	      if(pollfd[0].revents&POLLERR){
		error("Error condition - %s",hehe->h_name );
	      }
	      if(pollfd[0].revents&POLLHUP){
		error("Hung up - %s",hehe->h_name );
	      }
	    }
	  }
	}
	num_d=poll(pollfd_d,1,1000);
      }
      if(pollfd_d[0].revents && (pollfd_d[0].fd !=0)){
	if(pollfd_d[0].revents&POLLIN){
	  read(sock,&nl,sizeof(int));
	  type_id=ntohl(nl);
	}
	if(pollfd_d[0].revents&POLLERR){
	  error("Error condition ");
	}
	if(pollfd_d[0].revents&POLLHUP){
	  error("Hung up " );
	}
      }

      if(type_id==3)
	{
	  int col=0,row=0,length=0,count=0,r_len=0;
	  unsigned long long int *conv;
	  double *p;
	  read(sock,&nl,sizeof(int));
	  row=ntohl(nl);
	  read(sock,&nl,sizeof(int));
	  col=ntohl(nl);
	  length=sizeof(double)*row*col;
	  Matrix m(row,col);
	  double* tmp = m.fortran_vec();
	  errno=0;
	  r_len=BUFF_SIZE;
	  while(count <length){
	    p=(double *)((int)tmp+count);
	    if((length-count) < BUFF_SIZE)
	      r_len=length-count;
	    count +=read(sock,p,r_len);
#if defined (__BYTE_ORDER)
	    if(endian != __BYTE_ORDER){
#elif defined (BYTE_ORDER)
	    if(endian != BYTE_ORDER){
#else
#  error "can not determine the byte order"
#endif
	      conv=(unsigned long long int *)((u_int32_t)p&0xfffffff8);
	      for(int i=0;i<count/8;i++)
		*conv++=swab64(conv);
	    }
	  }
	  retval= octave_value(m);
	}
      else if(type_id==1)
	{
	  double d;
	  unsigned long long int *conv;
	  read(sock,&d,sizeof(d));
#if defined (__BYTE_ORDER)
	  if(endian != __BYTE_ORDER){
#elif defined (BYTE_ORDER)
	  if(endian != BYTE_ORDER){
#else
#  error "can not determine the byte order"
#endif
	    conv=(unsigned long long int *)&d;
	    *conv=swab64(conv);
	  }
	  retval= octave_value(d);
	}
      else if(type_id==4)
	{
	  int col=0,row=0,length=0,count=0,r_len=0;
	  Complex *p;
	  unsigned long long int *conv;
	  read(sock,&nl,sizeof(int));
	  row=ntohl(nl);
	  read(sock,&nl,sizeof(int));
	  col=ntohl(nl);
	  length=sizeof(Complex)*row*col;
	  ComplexMatrix cm(row,col);
	  Complex* tmp = cm.fortran_vec();
	  errno=0;
	  r_len=BUFF_SIZE;
	  while(count <length){
	    p=(Complex  *)((int)tmp+count);
	    if((length-count) < BUFF_SIZE)
	      r_len=length-count;
	    count +=read(sock,p,r_len);
#if defined (__BYTE_ORDER)
	  if(endian != __BYTE_ORDER){
#elif defined (BYTE_ORDER)
	  if(endian != BYTE_ORDER){
#else
#  error "can not determine the byte order"
#endif
	      conv=(unsigned long long int *)((u_int32_t)p&0xfffffff8);
	      for(int i=0;i<count/8;i++){
		*conv++=swab64(conv);
	      }
	    }
	  }
	  retval= octave_value(cm);
	  
	}
      else if(type_id==2)
	{
	  Complex cx;
	  
	  read(sock,&cx,sizeof(cx));
#if defined (__BYTE_ORDER)
	  if(endian != __BYTE_ORDER){
#elif defined (BYTE_ORDER)
	  if(endian != BYTE_ORDER){
#else
#  error "can not determine the byte order"
#endif
	    long long int *conv;
	    conv=(long long int *)&cx;
	    *conv++=swab64(conv);
	    *conv=swab64(conv);
	  }
	  retval= octave_value(cx);
	  
	}
      else if(type_id==6)
	{
	  int col=0,row=0,length=0,count=0,r_len=0;
	  
	  read(sock,&nl,sizeof(int));
	  row=ntohl(nl);
	  read(sock,&nl,sizeof(int));
	  col=ntohl(nl);
	  length=sizeof(char)*row*col;
	  charMatrix cmx(row,col);
	  char* str = cmx.fortran_vec();
	  errno=0;
	  r_len=BUFF_SIZE;
	  while(count <length){
	    if((length-count) < BUFF_SIZE)
	      r_len=length-count;
	    count +=read(sock,(char *)((int)str+count),r_len);
	  }
	  retval= octave_value(cmx,1);
	  
	}
      else if(type_id==7)
	{
	  int i,length=0,key_len=0;
	  Octave_map m;
	  octave_value_list ov_list;
	  char *key;
	  
	  read(sock,&nl,sizeof(nl));
	  length=ntohl(nl);
	  for(i=0;i<length;i++){
	    read(sock,&nl,sizeof(int));
	    key_len=ntohl(nl);
	    key = (char *)calloc(sizeof(char),key_len+1);
	    read(sock,key,key_len);
	    ov_list=Frecv(args(0),0);
	    m.assign(key,ov_list(0)); 
	  }
	  retval=octave_value(m);
	}
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
