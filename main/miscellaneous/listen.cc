#ifndef DEBUG
#define DEBUG 0
#endif

#include <iomanip>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/wait.h>
#include <signal.h>

#include <octave/oct.h>
#include <octave/parse.h>
#include <octave/variables.h>
#include <octave/unwind-prot.h>


static RETSIGTYPE
sigchld_handler(int /* sig */)
{
  int status;
  /* Reap all childrens */
#if DEBUG
  std::cout << "reaping all children" << std::endl;
#endif
  while (waitpid(-1, &status, WNOHANG) > 0)
    ;
#if DEBUG
  std::cout << "done reaping children" << std::endl;
#endif
  //  signal(SIGCHLD, sigchld_handler);
}

static RETSIGTYPE
sigterm_handler(int /* sig */)
{
  exit(0);
}

static void
daemonize(void)
{
  if (fork()) exit(0);
  signal(SIGTERM,sigterm_handler);
  signal(SIGQUIT,sigterm_handler);

  freopen("/dev/null", "r", stdin);
  freopen("/dev/null", "w", stdout);
  freopen("/dev/null", "w", stderr);
}



static octave_value get_octave_value(char *name)
{
  octave_value def;

  // Copy variable from octave
  symbol_record *sr = top_level_sym_tab->lookup (name);
  if (sr) def = sr->def();

  return def;
}


static void channel_error (const int channel, const char *str)
{
#if DEBUG
  std::cout << "sending error !!!e (" << strlen(str) << ") " << str << std::endl;
#endif
  unsigned long int len = strlen(str);
  write(channel,"!!!e",4);
  unsigned long int t = htonl(len); write(channel,&t,4);
  write(channel,str,len);
}

static bool reads (const int channel, void * buf, int n)
{
#if DEBUG
  // std::cout << "entering reads loop with size " << n << std::endl;
#endif
  while (1) {
    int chunk = read(channel, buf, n);
#if DEBUG
    if (chunk == 0) std::cout << "read socket returned 0" << std::endl;
    if (chunk < 0) std::cout << "read socket: " << strerror(errno) << std::endl;
#endif
    if (chunk <= 0) return false;
    n -= chunk;
#if DEBUG
    // if (n == 0) std::cout << "done reads loop" << std::endl;
#endif
    if (n == 0) return true;
    (char *)buf += chunk;
  }
}

static bool writes (const int channel, const void * buf, int n)
{
#if DEBUG
  // std::cout << "entering writes loop" << std::endl;
#endif
  while (1) {
    int chunk = write(channel, buf, n);
#if DEBUG
    if (chunk == 0) std::cout << "write socket returned 0" << std::endl;
    if (chunk < 0) std::cout << "write socket: " << strerror(errno) << std::endl;
#endif
    if (chunk <= 0) return false;
    n -= chunk;
#if DEBUG
    // if (n == 0) std::cout << "done writes loop" << std::endl;
#endif
    if (n == 0) return true;
    (char *)buf += chunk;
  }
}

static void
process_commands(int channel)
{
  // XXX FIXME XXX check read/write return values
  assert(sizeof(unsigned long int) == 4);
  char command[5];
  char def_buffer[16536];
  bool ok;
  char *buffer;
#if DEBUG
  std::cout << "waiting for command" << std::endl;
#endif

  // XXX FIXME XXX do we need to specify the buffer size?
  //  int bufsize=sizeof(def_buffer);
  //  socklen_t ol;
  //  ol=sizeof(bufsize);
  //  setsockopt(channel,SOL_SOCKET,SO_SNDBUF,&bufsize,ol);
  //  setsockopt(channel,SOL_SOCKET,SO_RCVBUF,&bufsize,ol);

  // XXX FIXME XXX prepare to capture long jumps, because if
  // we dont, then errors in octave might escape to the prompt

  command[4] = '\0';
  while (reads(channel, &command, 4)) {
    // XXX FIXME XXX do whatever is require to check if function files
    // have changed; do we really want to do this for _every_ command?
    // Maybe we need a 'reload' command.
#if DEBUG
    std::cout << "received command " << command << std::endl;
#endif
    
    // Check for magic command code
    if (command[0] != '!' || command[1] != '!' || command[2] != '!') {
      std::cout << "communication error: closing connection" << std::endl;
      break;
    }

    // Get command length
    int len;
    if (!reads(channel, &len, 4)) break;
    len = ntohl(len);

    // Read the command buffer, allocating a new one if the default
    // is too small.
    if (len > (signed)sizeof(def_buffer)-1) {
      // XXX FIXME XXX use octave allocators
      // XXX FIXME XXX unwind_protect
      buffer = new char[len+1];
      if (buffer == NULL) {
	// Requested command is too large --- skip to the next command
	// XXX FIXME XXX maybe we want to kill the connection instead?
	channel_error(channel,"out of memory");
	ok = true;
#if DEBUG
	std::cout << "skip big command loop" << std::endl;
#endif
	while (ok && len > (signed)sizeof(def_buffer)) {
	  ok = reads(channel, def_buffer, sizeof(def_buffer));
	  len -= sizeof(def_buffer);
	}
#if DEBUG
	std::cout << "done skip big command loop" << std::endl;
#endif
	if (!ok) break;
	ok = reads(channel, def_buffer, sizeof(def_buffer));
	if (!ok) break;
	continue;
      }
    } else {
      buffer = def_buffer;
    }
    ok = reads(channel, buffer, len);
    buffer[len] = '\0';

    // Process the command
    if (ok) switch (command[3]) {
    case 'm': // send the named matrix 
      {
	// XXX FIXME XXX this can be removed: app can do send(name,value)
#if DEBUG
	std::cout << "sending " << buffer << std::endl;
#endif
	unsigned long t;
	
	// read the matrix contents
	octave_value def = get_octave_value(buffer);
	if(!def.is_defined() || !def.is_real_matrix()) 
	  channel_error(channel,"not a matrix");
	Matrix m = def.matrix_value();
	
	// write the matrix transfer header
	ok = writes(channel,"!!!m",4);                // matrix message
	t = htonl(12 + sizeof(double)*m.rows()*m.columns());
	if (ok) ok = writes(channel,&t,4);            // length of message
	t = htonl(m.rows()); 
	if (ok) ok = writes(channel,&t,4);            // rows
	t = htonl(m.columns()); 
	if (ok) ok = writes(channel,&t,4);            // columns
	t = htonl(len); 
	if (ok) ok = writes(channel, &t, 4);          // name length
	if (ok) ok = writes(channel,buffer,len);      // name
	
	// write the matrix contents
	const double *v = m.data();                   // data
	if (ok) ok = writes(channel,v,sizeof(double)*m.rows()*m.columns());
#if DEBUG
	if (ok)
	  std::cout << "sent " << m.rows()*m.columns() << std::endl;
	else
	  std::cout << "failed " << m.rows()*m.columns() << std::endl;
#endif
      }
      break;
      
    case 'x': // silently execute the command
      {
#if DEBUG
	if (len > 500) 
	  {
	    // XXX FIXME XXX can we limit the maximum output width for a
	    // string?  The setprecision() io manipulator doesn't do it.
	    // In the meantime, a hack ...
	    char t = buffer[400]; buffer[400] = '\0';
	    std::cout << "evaluating (" << len << ") " 
		 << buffer << std::endl 
		 << "..." << std::endl 
		 << buffer+len-100 << std::endl;
	    buffer[400] = t;
	  }
	else
	  {
	    std::cout << "evaluating (" << len << ") " << buffer << std::endl;
	  }
#endif
	int parse_status = 0;
	error_state = 0;
	eval_string(buffer, true, parse_status, 0);
#if DEBUG
	std::cout << "parse_status = " << parse_status << ", error_state = " << error_state << std::endl << std::flush;
#endif
	if (parse_status != 0 || error_state)
	  {
	    error_state = 0;
	    bind_global_error_variable();
	    octave_value def = get_global_value("__error_text__");
	    std::string str = def.string_value();
#if DEBUG
	    std::cout << "error is " << str << std::endl;
#endif
	    channel_error(channel,str.c_str());
	    clear_global_error_variable(NULL);
	  }
      }
      break;
      
    case 'c': // execute the command and capture stdin/stdout
      std::cout << "capture command not yet implemented" << std::endl;
      break;
      
    default:
      std::cout << "ignoring command " << command << std::endl;
      break;
    }

    if (buffer != def_buffer) delete[] buffer;
#if DEBUG
    std::cout << "done!" << std::endl;
#endif
    if (!ok) break;
  }
}


int channel = -1;

DEFUN_DLD(send,args,,"\
send(str)\n\
  Send a command on the current connection\n\
send(name,value)\n\
  Send a binary value with the given name on the current connection\n\
")
{
  bool ok;
  unsigned long t;
  octave_value_list ret;
  int nargin = args.length();
  if (nargin < 1 || nargin > 2)
    {
      print_usage("send");
      return ret;
    }

  if (channel < 0) {
    error("Not presently listening on a port");
    return ret;
  }


  std::string cmd(args(0).string_value());
  if (error_state) return ret;

  // XXX FIXME XXX perhaps process the panalopy of types?
  if (nargin > 1) {
#if DEBUG
    std::cout << "sending !!!x(" << cmd.length() << ") " << cmd.c_str() << std::endl;
#endif
    
    octave_value def = args(1);
    if (args(1).is_string()) {
      // Grab the string value from args(1).
      // Can't use args(1).string_value() because that trims trailing \0
      charMatrix m(args(1).char_matrix_value());
      std::string s(m.row_as_string(0,false,true));
      ok = writes(channel,"!!!s",4);               // string message
      t = htonl(8 + cmd.length() + s.length());
      if (ok) ok = writes(channel,&t,4);           // length of message
      t = htonl(s.length());
      if (ok) ok = writes(channel, &t, 4);         // string length
      t = htonl(cmd.length());
      if (ok) ok = writes(channel, &t, 4);         // name length
      if (cmd.length() && ok) 
	ok = writes(channel, cmd.c_str(), cmd.length());    // name
      if (s.length() && ok) 
	ok = writes(channel, s.c_str(), s.length());        // string
#if DEBUG
      std::cout << "sent string(" << s.length() << ")" << std::endl;
#endif
    } else if (args(1).is_real_type()) {
      Matrix m(args(1).matrix_value());
      
      // write the matrix transfer header
      ok = writes(channel,"!!!m",4);               // matrix message
      t = htonl(12 + cmd.length() + sizeof(double)*m.rows()*m.columns());
      if (ok) ok = writes(channel,&t,4);           // length of message
      t = htonl(m.rows()); 
      if (ok) ok = writes(channel,&t,4);           // rows
      t = htonl(m.columns()); 
      if (ok) ok = writes(channel,&t,4);           // columns
      t = htonl(cmd.length()); 
      if (ok) ok = writes(channel, &t, 4);         // name length
      if (ok) ok = writes(channel, cmd.c_str(), cmd.length());    // name
      
      // write the matrix contents
      const double *v = m.data();                  // data
      if (m.rows()*m.columns() && ok) 
	ok = writes(channel,v,sizeof(double)*m.rows()*m.columns());
#if DEBUG
      std::cout << "sent matrix(" << m.rows() << "x" << m.columns() << ")" << std::endl;
#endif
    } else {
      ok = false;
      error("send expected name and matrix or string value");
    }
    if (!ok) error("send could not write to channel");
  } else {
    ok = writes(channel, "!!!x", 4);
    t = htonl(cmd.length()); write(channel, &t, 4);
    if (ok) ok = writes(channel, cmd.c_str(), cmd.length());
    if (!ok) error("send could not write to channel");
  }

  return ret;
}


DEFUN_DLD(listen,args,,"\
listen(port,host)\n\
   Listen for connections on the given port.  Normally only accepts\n\
   connections from localhost (127.0.0.1), but you can specify any\n\
   dot-separated host name.\n\
")
{
  octave_value_list ret;
  int nargin = args.length();
  if (nargin < 1 || nargin > 2)
    {
      print_usage("listen");
      return ret;
    }

  int port = args(0).int_value();
  if (error_state) return ret;

  std::string host;
  if (nargin >= 2) host = args(1).string_value();
  else host = "127.0.0.1";
  struct in_addr hostid;
  inet_aton(host.c_str(),&hostid);

  if (error_state) return ret;

  int sockfd;                    // listen on sockfd, new connection channel
  struct sockaddr_in my_addr;    // my address information
  struct sockaddr_in their_addr; // connector's address information
  socklen_t sin_size;
  int yes=1;
  
  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
    perror("socket");
    return ret;
  }

  if (setsockopt(sockfd,SOL_SOCKET,SO_REUSEADDR,&yes,sizeof(int)) == -1) {
    perror("setsockopt");
    return ret;
  }

  my_addr.sin_family = AF_INET;         // host byte order
  my_addr.sin_port = htons(port);       // short, network byte order
  my_addr.sin_addr.s_addr = INADDR_ANY; // automatically fill with my IP
  memset(&(my_addr.sin_zero), '\0', 8); // zero the rest of the struct
  
  if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof(struct sockaddr))
      == -1) {
    perror("bind");
    close(sockfd);
    return ret;
  }
  
  if (listen(sockfd, 1) == -1) { /* only listen for one connection */
    perror("listen");
    close(sockfd);
    return ret;
  }

  unwind_protect::begin_frame("Flisten");
  unwind_protect_bool (buffer_error_messages);
  buffer_error_messages = true;

  signal(SIGCHLD, sigchld_handler);

#if !DEBUG && !defined(__CYGWIN__)
  daemonize();
#endif

  // XXX FIXME XXX want a 'sandbox' option which disables fopen, cd, pwd,
  // system, popen ...  Or maybe just an initial script to run for each
  // connection, plus a separate command to disable specific functions.
#if DEBUG
  std::cout << "listening on port " << port << std::endl;
#endif
  while(1) {  // main accept() loop
    sin_size = sizeof(struct sockaddr_in);
#if DEBUG
    std::cout << "trying to accept" << std::endl;
#endif
    if ((channel = accept(sockfd, (struct sockaddr *)&their_addr,
			 &sin_size)) == -1) {
      std::cout << "failed to accept" << std::endl << std::flush;
      perror("accept");
#if defined(__CYGWIN__)
      break;
#else
      continue;
#endif
    }
#if DEBUG
    std::cout << "connected" << std::endl;
#endif


    std::cout << "server: got connection from " << inet_ntoa(their_addr.sin_addr) << std::endl;

    if (their_addr.sin_addr.s_addr == hostid.s_addr) {

      int pid = fork();

      if (pid == -1) {
        perror("fork ");
        break;
      } else if (pid == 0) {
        close(sockfd);            // child doesn't need listener
        signal(SIGCHLD,SIG_DFL);  // child doesn't need SIGCHLD signal
        process_commands(channel);
#if DEBUG
        std::cout << "child is exitting" << std::endl;
#endif
        exit(0);
      }
    } else {
      std::cout << "server: connection refused." << std::endl;
    }

    close(channel);
    channel = -1;
  }

#if DEBUG
  std::cout << "could not read commands; returning " << std::endl;
#endif
  unwind_protect::run_frame("Flisten");
  return ret;
}
