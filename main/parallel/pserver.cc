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
#include "file-io.h"
#include "pt-plot.h"
#include "sighandlers.h"
#include "parse.h"
#include "cmd-edit.h"
#include "variables.h"
#include "toplev.h"
#include "sysdep.h"
#include "oct-prcstrm.h"
#include "oct-stream.h"
#include "oct-strstrm.h"
#include "oct-iostrm.h"
#include "quit.h"

#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/poll.h>
#include <netinet/in.h>
#include <errno.h>
#include <signal.h>
#include <netdb.h>
#include <unistd.h>
#include <setjmp.h>

#define BUFF_SIZE SSIZE_MAX

// Top level context (?)
jmp_buf toplevel;

static bool quitting_gracefully = false;

// Handle server SIGTERM SIGQUIT

static RETSIGTYPE
sigterm_handler (int /* sig */)
{
  int len=118;
  char hostname[120],pidname[128];
  gethostname(hostname,len);
  sprintf(pidname,".octave-%s.pid",hostname);
  remove (pidname);
  close_files ();

  std::cerr << "exiting, " <<hostname <<std::endl;
  cleanup_tmp_files ();
  exit(0);

}

static RETSIGTYPE
sigchld_handler(int /* sig */)
{
  int status;
  /* Reap all childrens */
  while (waitpid(-1, &status, WNOHANG) > 0)
    ;
  signal(SIGCHLD, sigchld_handler);
}

// XXX FIXME XXX -- this should really be static, but that causes
// problems on some systems.
SLStack<std::string> octave_atexit_functions;

void
do_octave_atexit_server (void)
{
  static bool deja_vu = false;

  while (! octave_atexit_functions.empty ())
    {
      octave_value_list fcn = octave_atexit_functions.pop ();

      feval (fcn, 0);

      flush_octave_stdout ();
    }

  if (! deja_vu)
    {
      deja_vu = true;

      command_editor::restore_terminal_state ();

      // XXX FIXME XXX -- is this needed?  Can it cause any trouble?
      raw_mode (0);

      close_plot_stream ();

      close_files ();

      cleanup_tmp_files ();

      flush_octave_stdout ();

      if (!quitting_gracefully && (interactive || forced_interactive))
        std::cout << "\n";
    }
}

void
clean_up_and_exit_server (int retval)
{
  do_octave_atexit_server ();

  exit (retval == EOF ? 0 : retval);
}

int
reval_loop (int sock)
{
  // Allow the user to interrupt us without exiting.
  int len;
  char *ev_str;
  std::string s;

  octave_save_signal_mask ();

  if (setjmp (toplevel) != 0)
    {
      raw_mode (0);

      std::cout << "\n";

      octave_restore_signal_mask ();
    }

  can_interrupt = true;

  octave_catch_interrupts ();

  // The big loop.

  char nl;
  read(sock,&nl,1);
  int retval,count,r_len,num,fin;
  struct pollfd *pollfd;
      
  pollfd=(struct pollfd *)malloc(sizeof(struct pollfd));
  pollfd[0].fd=sock;
  pollfd[0].events=0;
  pollfd[0].events=POLLIN|POLLERR|POLLHUP;

  do
    {
      pollfd[0].revents=0;
      num=poll(pollfd,1,-1);
      if(num){
	if(pollfd[0].revents && (pollfd[0].fd !=0)){
	  if(pollfd[0].revents&POLLIN){
	    fin=read(sock,&len,sizeof(int));
	    if(!fin)
	      clean_up_and_exit_server (0);
	  }
	  if(pollfd[0].revents&POLLERR){
	    std::cerr <<"Error condition "<<std::endl;
	    clean_up_and_exit_server (POLLERR);
	  }
	  if(pollfd[0].revents&POLLHUP){
	    std::cerr <<"Hung up "<<std::endl;
	    clean_up_and_exit_server (POLLHUP);
	  }
        }
      }
      ev_str=new char[len+1];
      count=0;
      r_len=BUFF_SIZE;
      while(count <len){
	if((len-count) < BUFF_SIZE)
	  r_len=len-count;
	count +=read(sock,(char *)((int)ev_str+count),r_len);
      }
      //      read(sock,ev_str,len);
      ev_str[len]='\0';

      s=(std::string)ev_str;
      eval_string(s,false,retval,1);
      delete(ev_str);
      if (error_state)
        {
	  write(sock,&error_state,sizeof(int));
	  read(sock,&error_state,sizeof(int));
     	  clean_up_and_exit_server (retval);
        }
      else
        {
          if (octave_completion_matches_called)
            octave_completion_matches_called = false;
          else
            command_editor::increment_current_command_number ();
        }
      // Blocking Execution
      //      write(sock,&error_state,sizeof(error_state));
    }
  while (retval == 0);

  return retval;
}

DEFUN_DLD (pserver,,,
  "pserver\n\
\n\
Connect hosts and return sockets.")
{
      FILE *pidfile=0;
      int ppid,len=118;
      char hostname[120],pidname[128],errname[128],bakname[128];
      struct stat fstat;
      
      gethostname(hostname,len);
      sprintf(pidname,".octave-%s.pid",hostname);
      if(stat(pidname,&fstat)==0){
	std::cerr << "octave : "<<hostname<<": server already running"<<std::endl;
	clean_up_and_exit (1);
      }

      if (fork())
        exit(0);
      
      /* Touch lock file. */
      ppid=getpid();
      pidfile = fopen (pidname, "w");
      fprintf(pidfile,"%d\n",ppid);
      fclose(pidfile);
      std::cout <<pidname<<std::endl;

      /* */
      signal(SIGCHLD, sigchld_handler);
      signal(SIGTERM,sigterm_handler);
      signal(SIGQUIT,sigterm_handler);

      /* Redirect stdin, stdout, and stderr to /dev/null. */
      freopen("/dev/null", "r", stdin);
      freopen("/dev/null", "w", stdout);

      sprintf(errname,"/tmp/octave_error-%s.log",hostname);
      if(stat(errname,&fstat)==0){
	sprintf(bakname,"/tmp/octave_error-%s.bak",hostname);
	rename(errname,bakname);
      }
      freopen(errname, "w", stderr);
      

      int sock=0,asock=0,dsock=0,dasock=0,pid=0;
      struct sockaddr_in *addr,rem_addr;;

      addr=(struct sockaddr_in *) calloc(1,sizeof(struct sockaddr_in));
      
      sock=socket(PF_INET,SOCK_STREAM,0);
      if(sock==-1){
	perror("socket ");
	int len=118;
	char hostname[120],pidname[128];
	gethostname(hostname,len);
	sprintf(pidname,".octave-%s.pid",hostname);
	remove (pidname);
	close_files ();
	clean_up_and_exit (1);
      }

      addr->sin_family=AF_INET;
      addr->sin_port=htons(12502);
      addr->sin_addr.s_addr=INADDR_ANY;
      
      if(bind(sock,(struct sockaddr *) addr,sizeof(*addr))!=0){
	perror("bind ");
	int len=118;
	char hostname[120],pidname[128];
	gethostname(hostname,len);
	sprintf(pidname,".octave-%s.pid",hostname);
	remove (pidname);
	close_files ();
	clean_up_and_exit (1);
      }
      free(addr);

      if(listen(sock,1)!=0){
	perror("listen ");
	clean_up_and_exit (1);
      }


      dsock=socket(PF_INET,SOCK_STREAM,0);
      if(dsock==-1){
	perror("socket : ");
	exit(-1);
      }
      
      addr=(struct sockaddr_in *) calloc(1,sizeof(struct sockaddr_in));
      
      addr->sin_family=AF_INET;
      addr->sin_port=htons(12501);
      addr->sin_addr.s_addr=INADDR_ANY;
      
      
      if(bind(dsock,(struct sockaddr *) addr,sizeof(*addr))!=0){
	perror("bind : ");
	exit(-1);
      }
      if(listen(dsock,SOMAXCONN)!=0){
	perror("listen : ");
	exit(-1);
      }
      free(addr);
      int param=1;
      socklen_t ol=sizeof(param);
      setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,&param,ol);
      setsockopt(dsock,SOL_SOCKET,SO_REUSEADDR,&param,ol);

      int val=1,num_nodes,me,i,j=0,pppid=0,rpppid=0,result=0;
      int *sock_v;
      char **host_list,rem_name[128];
      struct hostent *he;      

      ol=sizeof(val);

      for(;;)
	{
	  asock=accept(sock,0,0);
	  if(asock==-1){
	    perror("accept com");
	    clean_up_and_exit (1);
	  }
	  /* Normal production daemon.  Fork, and have the child process
             the connection.  The parent continues listening. */
	  
	  if((pid=fork())==-1)
	    {
	      perror("fork ");
	      clean_up_and_exit (1);
	    }
	  else if(pid==0) 
	    {
	      close(sock);
	      signal(SIGCHLD,SIG_DFL);
	      signal(SIGTERM,SIG_DFL);
	      signal(SIGQUIT,SIG_DFL);

	      val=1;
	      ol=sizeof(val);
	      setsockopt(asock,SOL_SOCKET,SO_REUSEADDR,&val,ol);
	      
	      read(asock,&num_nodes,sizeof(int));
	      read(asock,&me,sizeof(int));
	      read(asock,&pppid,sizeof(int));
	      sock_v=(int *)calloc((num_nodes+1)*2,sizeof(int));
	      host_list=(char **)calloc(num_nodes,sizeof(char *));
	      for(i=0;i<=num_nodes;i++){
		read(asock,&len,sizeof(int));
		host_list[i]=(char *)calloc(len,sizeof(char *));
		read(asock,host_list[i],len);
	      }

	      sprintf(errname,"/tmp/octave_error-%s_%5d.log",hostname,pppid);
	      if(stat(errname,&fstat)==0){
		sprintf(bakname,"/tmp/octave_error-%s_%5d.bak",hostname,pppid);
		rename(errname,bakname);
	      }
	      freopen(errname, "w", stderr);

	      for(i=0;i<me;i++){
		//      recv;
		
		len=sizeof(rem_addr);

		while(1){
		  dasock=accept(dsock,(sockaddr *)&rem_addr,(socklen_t *)&len);
		  if(dasock==-1){
		    perror("accept dat ");
		    exit(-1);
		  }
		  int bufsize=BUFF_SIZE;
		  socklen_t ol;
		  ol=sizeof(bufsize);
		  setsockopt(dasock,SOL_SOCKET,SO_SNDBUF,&bufsize,ol);
		  setsockopt(dasock,SOL_SOCKET,SO_RCVBUF,&bufsize,ol);
		  bufsize=1;
		  ol=sizeof(bufsize);
		  setsockopt(dasock,SOL_SOCKET,SO_REUSEADDR,&bufsize,ol);
		  
		  //recv pppid
		  read(dasock,&rpppid,sizeof(int));
		  //recv name size
		  read(dasock,&len,sizeof(int));
		  //recv name
		  read(dasock,rem_name,len+1);
		  rem_name[len]='\0';

		  for(j=0;j<me;j++){
		    if(strcmp(rem_name,host_list[j])==0){
		      sock_v[j]=dasock;
		      result=0;
		      break;
		    }else{
		      result=-1;
		    }
		  }
		  //send result code
		  if(result==0){
		    if(pppid==rpppid){
		      result=0;
		      write(dasock,&result,sizeof(int));
		      break;
		    }
		  }else{
		    result=-1;
		    write(dasock,&result,sizeof(int));
		    close(dasock);
		    sleep(1);
		  }
		}
	      }
	      //	      close(dsock);
	      //me
	      errno=0;

	      for(i=(me+1);i<=num_nodes;i++){
		dsock=-1;
		// connect;
		dsock=socket(PF_INET,SOCK_STREAM,0);
		if(dsock==-1){
		  perror("socket : ");
		  exit(-1);
		}
		addr=(struct sockaddr_in *) calloc(1,sizeof(struct sockaddr_in));
		
		addr->sin_family=AF_INET;
		addr->sin_port=htons(12501);
		he=gethostbyname(host_list[i]);
		if(he == NULL){
		  error("Unknown host %s",host_list[i]);
		}
		memcpy(&addr->sin_addr,he->h_addr_list[0],he->h_length);
		while(1){
		  for(j=0;j<10;j++){
		    if(connect(dsock,(struct sockaddr *)addr,sizeof(*addr))==0){
		      break;
		    }else if(errno!=ECONNREFUSED){
		      perror("connect : ");
		      exit(-1);
		    }else {
		      usleep(5000);
		    }
		  }
		  int bufsize=262144;
		  socklen_t ol;
		  ol=sizeof(bufsize);
		  setsockopt(dsock,SOL_SOCKET,SO_SNDBUF,&bufsize,ol);
		  setsockopt(dsock,SOL_SOCKET,SO_RCVBUF,&bufsize,ol);
		  bufsize=1;
		  ol=sizeof(bufsize);
		  setsockopt(dsock,SOL_SOCKET,SO_REUSEADDR,&bufsize,ol);
		  
		  //send pppid
		  write(dsock,&pppid,sizeof(int));
		  //send name size
		  len=strlen(host_list[me]);
		  write(dsock,&len,sizeof(int));
		  //send name
		  write(dsock,host_list[me],len+1);
		  //recv result code
		  read(dsock,&result,sizeof(int));

		  if(result==0){
		    sock_v[i]=dsock;
		    break;
		  }else{
		    close(dsock);
		  }
		}
		free(addr);
	      }
	      /*   for(i=0;i<=num_nodes;i++){
		free(host_list[i]);
	      }
	      free(host_list);
	      */
 	      //normal act
	      install_signal_handlers ();
      
	      //	      initialize_command_input ();
	      
	      //	      if (! inhibit_startup_message)
	      //std::cout << OCTAVE_STARTUP_MESSAGE "\n" << std::endl;
	      
	      char * s;
	      int stat;

	      s=(char *)calloc(32,sizeof(char));
	      sprintf(s,"sockets=[%d,0]",sock_v[0]);
	      eval_string(std::string(s),true,stat);
	      for(i=1;i<=num_nodes;i++){
		sprintf(s,"sockets=[sockets;%d,0]",sock_v[i]);
		eval_string(std::string(s),true,stat);
	      }
		
	      //	      command_history::read (false);
	      
	      // If there is an extra argument, see if it names a file to read.
	      // Additional arguments are taken as command line options for the
	      // script.
	      
	      interactive = false;
	      
//	      switch_to_buffer (create_buffer (get_input_from_net (asock)));
	      
	      // Force input to be echoed if not really interactive, but the user
	      // has forced interactive behavior.
	      
	      if (! interactive && forced_interactive)
		{
		  command_editor::blink_matching_paren (false);
		  
		  // XXX FIXME XXX -- is this the right thing to do?
		  
		  bind_builtin_variable ("echo_executing_commands",
					 static_cast<double> (ECHO_CMD_LINE));
		}
      
	      if (! interactive)
		line_editing = false;

//	      int retval = main_loop ();

	      char *newdir;
	      int newdir_len;
	      read(asock,&newdir_len,sizeof(int));
	      newdir=(char *)calloc(sizeof(char),newdir_len+1);
	      read(asock,newdir,newdir_len);
	      int cd_ok=octave_env::chdir (newdir);
	      if(cd_ok !=0){
		octave_env::chdir ("/tmp");
	      }
	      int retval = reval_loop(asock);
	      
	      if (retval == 1 && ! error_state)
		retval = 0;
	      
	      close(asock);

	      clean_up_and_exit_server (retval);
	      
	    }
	  
	  close(asock);
	  
	}
      close(sock);
      exit(-1);
      
}
