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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
#include <netinet/in.h>
#include <errno.h>
#include <netdb.h>
#include <unistd.h>
#include <netinet/in.h>

#define BUFF_SIZE SSIZE_MAX

// COMM

DEFUN_DLD (connect, args, ,
  "connect (hosts)\n\
\n\
Connect hosts and return sockets.")
{

  int sock=0,col=0,row=0,i,j,len;
  double *sock_v=0;
  if (args.length () == 1)
    {
      int pid=0,nl;
      struct sockaddr_in *addr;
      struct hostent *he;
      octave_value hosts=args(0);
      charMatrix cm=hosts.char_matrix_value();
      char *host,*pt,myname[16];
      
      errno=0;
      gethostname(myname,15);
      row= cm.rows();
      col= cm.columns();
      cm= cm.transpose(); 
      
      sock_v=(double *)calloc(3,row*sizeof(double));
       

      for(i=1;i<row;i++){
	host=(char *)calloc(1,col+1);
	strncpy(host,&cm.data()[col*i],col);
	pt=strchr(host,' ');
	if(pt==NULL)
	  host[col]='\0';
	else
	  *pt='\0';
	
	sock=socket(PF_INET,SOCK_STREAM,0);
	if(sock==-1){
	  error("socket error ");
	}
	
	addr=(struct sockaddr_in *) calloc(1,sizeof(struct sockaddr_in));
	
	addr->sin_family=AF_INET;
	addr->sin_port=htons(12502);
	he=gethostbyname(host);
	if(he == NULL){
	  error("Unknown host %s",host);
	}
	memcpy(&addr->sin_addr,he->h_addr_list[0],he->h_length);
	
	for(j=0;j<10;j++){
	  if(connect(sock,(struct sockaddr *)addr,sizeof(*addr))==0){
	    break;
	  }else if(errno!=ECONNREFUSED){
	    error("connect error ");
	  }else {
	    usleep(5000);
	  }
	}
	if(!sock)
	  error("Unable to connect to %s: Connection refused",host);
	
	sock_v[i+row]=sock;
	
	free(addr);
	free(host);

	int num_nodes=row-1;

	pid=getpid();
	nl=htonl(num_nodes);
	write(sock,&nl,sizeof(int));
	nl=htonl(i);
	write(sock,&nl,sizeof(int));
	nl=htonl(pid);
	write(sock,&nl,sizeof(int));

	host=(char *)calloc(128,sizeof(char));
	for(j=0;j<row;j++){
	  strncpy(host,&cm.data()[col*j],col);
	  pt=strchr(host,' ');
	  if(pt==NULL)
	    host[col]='\0';
	  else
	    *pt='\0';
	  len=strlen(host)+1;
	  nl=htonl(len);
	  write(sock,&nl,sizeof(int));
	  write(sock,host,len);
	}
	free(host);
	int comm_len;
       	std::string directory = octave_env::getcwd ();
	comm_len=directory.length();
	nl=htonl(comm_len);
	write(sock,&nl,sizeof(int));
	write(sock,directory.c_str(),comm_len);
      }      
      usleep(100);

      for(i=1;i<row;i++){
	
	host=(char *)calloc(1,col+1);
	
	strncpy(host,&cm.data()[col*i],col);
	pt=strchr(host,' ');
	if(pt==NULL)
	  host[col]='\0';
	else
	  *pt='\0';
	
	sock=socket(PF_INET,SOCK_STREAM,0);
	if(sock==-1){
	  perror("socket : ");
	  exit(-1);
	}
	
	addr=(struct sockaddr_in *) calloc(1,sizeof(struct sockaddr_in));
	
	addr->sin_family=AF_INET;
	addr->sin_port=htons(12501);
	he=gethostbyname(host);
	if(he == NULL){
	  error("Unknown host %s",host);
	}
	memcpy(&addr->sin_addr,he->h_addr_list[0],he->h_length);
	while(1){
	  for(j=0;j<10;j++){
	    if(connect(sock,(struct sockaddr *)addr,sizeof(*addr))==0){
	      break;
	    }else if(errno!=ECONNREFUSED){
	      perror("connect : ");
	      exit(-1);
	    }else {
	      usleep(5000);
	    }
	  }
	  if(!sock)
	    error("Unable to connect to %s: Connection refused",host);
	  
	  int bufsize=262144;
	  socklen_t ol;
	  ol=sizeof(bufsize);
	  setsockopt(sock,SOL_SOCKET,SO_SNDBUF,&bufsize,ol);
	  setsockopt(sock,SOL_SOCKET,SO_RCVBUF,&bufsize,ol);
	  bufsize=1;
	  ol=sizeof(bufsize);
	  setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,&bufsize,ol);
	  

	  int len=0,result=0;;
	  //send pppid
	  nl=htonl(pid);
	  write(sock,&nl,sizeof(int));
	  //send name size
	  strncpy(myname,cm.data(),col);
	  pt=strchr(myname,' ');
	  if(pt==NULL)
	    myname[col]='\0';
	  else
	    *pt='\0';
	  len=strlen(myname);
	  nl=htonl(len);
	  write(sock,&nl,sizeof(int));
	  //send name
	  write(sock,myname,len+1);
	  //recv result code
	  read(sock,&nl,sizeof(int));
	  result=ntohl(nl);
	  if(result==0){
	    sock_v[i]=sock;
	    //recv endian
	    read(sock,&nl,sizeof(int));
	    sock_v[i+2*row]=ntohl(nl);
	    //send endian
#if defined (__BYTE_ORDER)
	    nl=htonl(__BYTE_ORDER);
#elif defined (BYTE_ORDER)
	    nl=htonl(BYTE_ORDER);
#else
#  error "can not determine the byte order"
#endif
	    write(sock,&nl,sizeof(int));
	    break;
	  }else{
	    close(sock);
	  }
	}
	
	free(addr);
	free(host);
      }

      char lf='\n';
      for(i=1;i<row;i++){
	write((int)sock_v[i+row],&lf,sizeof(char));
	//	cout << i+row <<endl;
      }
    }
  else
    {
      print_usage ();
      octave_value retval;
      return retval;
    }
      

  Matrix mx(row,3);
  double *tmp =mx.fortran_vec();
  for (i=0;i<3*row;i++)
    tmp[i]=sock_v[i];
  octave_value retval(mx);

  return retval;
}


/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
