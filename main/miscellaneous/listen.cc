#define STATUS(x) do { if (debug) std::cout << x << std::endl << std::flush; } while (0)

#include <iomanip>

#include <cstdio>
#include <cstdlib>
#include <unistd.h>
#include <cerrno>
// #include <string.h>
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
#include <octave/oct-syscalls.h>
#include <octave/oct-time.h>
#include <octave/lo-mappers.h>

static bool debug = false;

static double timestamp = 0.0;
inline void tic(void) { timestamp = octave_time(); }
inline double toc(void) {return round(-1e6*(timestamp-double(octave_time())));}

// XXX FIXME XXX --- surely this is part of the standard library?
void
lowercase (std::string& s)
{
  for (std::string::iterator i=s.begin(); i != s.end(); i++) *i = tolower(*i);
}

octave_value
get_builtin_value (const std::string& nm)
{
  octave_value retval;

  symbol_record *sr = fbi_sym_tab->lookup (nm);

  if (sr)
    {
      octave_value sr_def = sr->def ();

      if (sr_def.is_undefined ())
        error ("get_builtin_value: undefined symbol `%s'", nm.c_str ());
      else
        retval = sr_def;
      }
  else
    error ("get_builtin_value: unknown symbol `$s'", nm.c_str ());

  return retval;
}


// XXX FIXME XXX autoconf stuff
#if 0 && defined(_sgi)
typedef int socklen_t;
#endif

static void
sigchld_handler(int /* sig */)
{
  int status;
  /* Reap all childrens */
  STATUS("reaping all children");
  while (waitpid(-1, &status, WNOHANG) > 0)
    ;
  STATUS("done reaping children");
}

/* Posix signal handling, based on the example from the
 * Unix Programming FAQ 
 * Copyright (C) 2000 Andrew Gierth
 */
static void sigchld_setup(void)
{
  struct sigaction act;

  /* Assign sig_chld as our SIGCHLD handler */
  act.sa_handler = sigchld_handler;

  /* We don't want to block any other signals in this example */
  sigemptyset(&act.sa_mask);
  
  /*
   * We're only interested in children that have terminated, not ones
   * which have been stopped (eg user pressing control-Z at terminal)
   */
  act.sa_flags = SA_NOCLDSTOP;

  /*
   * Make these values effective. If we were writing a real 
   * application, we would probably save the old value instead of 
   * passing NULL.
   */
  if (sigaction(SIGCHLD, &act, NULL) < 0) 
     error("listen could not set SIGCHLD");
}


#if defined(__CYGWIN__)

// Don't daemonize on cygwin just yet.
inline void daemonize(void) {}

#else

static RETSIGTYPE
sigterm_handler(int /* sig */)
{
  exit(0);
}


static void
daemonize(void)
{
  if (debug) return; /* Don't daemonize if debugging */
  if (fork()) exit(0);
  std::cout << "Octave pid: " << octave_syscalls::getpid() << std::endl;
  signal(SIGTERM,sigterm_handler);
  signal(SIGQUIT,sigterm_handler);

  freopen("/dev/null", "r", stdin);
  freopen("/dev/null", "w", stdout);
  freopen("/dev/null", "w", stderr);
}

#endif



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
  STATUS("sending error !!!e (" << strlen(str) << ") " << str);

  unsigned long int len = strlen(str);
  write(channel,"!!!e",4);
  unsigned long int t = htonl(len); write(channel,&t,4);
  write(channel,str,len);
}

static bool reads (const int channel, void * buf, int n)
{
  // STATUS("entering reads loop with size " << n); tic();
  while (1) {
    int chunk = read(channel, buf, n);
    if (chunk == 0) STATUS("read socket returned 0");
    if (chunk < 0) STATUS("read socket: " << strerror(errno));
    if (chunk <= 0) return false;
    n -= chunk;
    // if (n == 0) STATUS("done reads loop after " << toc() << "us");
    if (n == 0) return true;
    // STATUS("reading remaining " << n << " characters");
    buf = (void *)((char *)buf + chunk);
  }
}

static bool writes (const int channel, const void * buf, int n)
{
  // STATUS("entering writes loop");
  while (1) {
    int chunk = write(channel, buf, n);
    if (chunk == 0) STATUS("write socket returned 0");
    if (chunk < 0) STATUS("write socket: " << strerror(errno));
    if (chunk <= 0) return false;
    n -= chunk;
    // if (n == 0) STATUS("done writes loop");
    if (n == 0) return true;
    buf = (void *)((char *)buf + chunk);
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
  STATUS("waiting for command");

  // XXX FIXME XXX do we need to specify the buffer size?
  //  int bufsize=sizeof(def_buffer);
  //  socklen_t ol;
  //  ol=sizeof(bufsize);
  //  setsockopt(channel,SOL_SOCKET,SO_SNDBUF,&bufsize,ol);
  //  setsockopt(channel,SOL_SOCKET,SO_RCVBUF,&bufsize,ol);

  // XXX FIXME XXX prepare to capture long jumps, because if
  // we dont, then errors in octave might escape to the prompt

  command[4] = '\0';
  if (debug) tic();
  while (reads(channel, &command, 4)) {
    // XXX FIXME XXX do whatever is require to check if function files
    // have changed; do we really want to do this for _every_ command?
    // Maybe we need a 'reload' command.
    STATUS("received command " << command << " after " << toc() << "us");
    
    // Check for magic command code
    if (command[0] != '!' || command[1] != '!' || command[2] != '!') {
      STATUS("communication error: closing connection");
      break;
    }

    // Get command length
    if (debug) tic(); // time the read
    int len;
    if (!reads(channel, &len, 4)) break;
    len = ntohl(len);
    // STATUS("read 4 byte command length in " << toc() << "us"); 

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
	STATUS("skip big command loop");
	while (ok && len > (signed)sizeof(def_buffer)) {
	  ok = reads(channel, def_buffer, sizeof(def_buffer));
	  len -= sizeof(def_buffer);
	}
	STATUS("done skip big command loop");
	if (!ok) break;
	ok = reads(channel, def_buffer, sizeof(def_buffer));
	if (!ok) break;
	continue;
      }
    } else {
      buffer = def_buffer;
    }
    // if (debug) tic();
    ok = reads(channel, buffer, len);
    buffer[len] = '\0';
    STATUS("read " << len << " byte command in " << toc() << "us");

    // Process the command
    if (ok) switch (command[3]) {
    case 'm': // send the named matrix 
      {
	// XXX FIXME XXX this can be removed: app can do send(name,value)
	STATUS("sending " << buffer);
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
	if (ok)
	  STATUS("sent " << m.rows()*m.columns());
	else
	  STATUS("failed " << m.rows()*m.columns());
      }
      break;
      
    case 'x': // silently execute the command
      {
	if (debug) 
	  {
	    if (len > 500) 
	      {
		// XXX FIXME XXX can we limit the maximum output width for a
		// string?  The setprecision() io manipulator doesn't do it.
		// In the meantime, a hack ...
		char t = buffer[400]; buffer[400] = '\0';
		STATUS("evaluating (" << len << ") " 
		       << buffer << std::endl 
		       << "..." << std::endl 
		       << buffer+len-100);
		buffer[400] = t;
	      }
	    else
	      {
		STATUS("evaluating (" << len << ") " << buffer);
	      }
	  }

	if (debug) tic();
	int parse_status = 0;
	error_state = 0;
	eval_string(buffer, true, parse_status, 0);
	STATUS("parse status = " << parse_status << ", error state = " 
	       << error_state << ", processing time = " << toc() << "us");
	if (parse_status != 0 || error_state)
	  {
	    error_state = 0;
	    bind_global_error_variable();
	    octave_value def = get_builtin_value("__error_text__");
	    std::string str = def.string_value();
	    // provide a context for the error (but not too much!)
	    str += "when evaluating:\n";
	    if (len > 100) 
	      {	
		char t=buffer[100]; 
	        buffer[100] = '\0'; 
	        str+=buffer; 
	        buffer[100]=t;
	      }
	    else
              str += buffer;
	    STATUS("error is " << str);
	    channel_error(channel,str.c_str());
	    clear_global_error_variable(NULL);
	  }
      }
      break;
      
    case 'c': // execute the command and capture stdin/stdout
      STATUS("capture command not yet implemented");
      break;
      
    default:
      STATUS("ignoring command " << command);
      break;
    }

    if (buffer != def_buffer) delete[] buffer;
    // STATUS("done " << command);
    if (!ok) break;
    if (debug) tic();
  }
}


int channel = -1;

#if 1
// Temporary hack (I hope).  For some reason 
// the DEFUN_DLD isn't being found from
// within listen, so I install it by hand.

DEFUN_INTERNAL(send,args,,false,"\
send(str)\n\
  Send a command on the current connection\n\
send(name,value)\n\
  Send a binary value with the given name on the current connection\n\
")
#else
DEFUN_DLD(send,args,,"\
send(str)\n\
  Send a command on the current connection\n\
send(name,value)\n\
  Send a binary value with the given name on the current connection\n\
")
#endif
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
    STATUS("sending !!!x(" << cmd.length() << ") " << cmd.c_str());
    
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
      STATUS("sent string(" << s.length() << ")");
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
      STATUS("sent matrix(" << m.rows() << "x" << m.columns() << ")");
    } else {
      ok = false;
      error("send expected name and matrix or string value");
    }
    if (!ok) error("send could not write to channel");
  } else {
    // STATUS("start writing at "<<toc()<<"us");
    ok = writes(channel, "!!!x", 4);
    t = htonl(cmd.length()); writes(channel, &t, 4);
    if (ok) ok = writes(channel, cmd.c_str(), cmd.length());
    if (!ok) error("send could not write to channel");
    // STATUS("stop writing at "<<toc()<<"us");
  }

  return ret;
}

extern "C" int listencanfork(void);

DEFUN_DLD(listen,args,,"\
listen(port,host)\n\
   Listen for connections on the given port.  Normally only accepts\n\
   connections from localhost (127.0.0.1), but you can specify any\n\
   dot-separated host name.\n\
listen(...,debug|nodebug)\n\
   If debug, echo all commands sent across the connection.  If nodebug,\n\
   detach the process and don't echo anything.  You will need to use\n\
   kill directly to end the process. Nodebug is the default.\n\
")
{
  install_builtin_function (Fsend, "send", "builtin send doc", false);

#if defined(__CYGWIN__)
  bool canfork = listencanfork();
#else
  bool canfork = true;
#endif

  octave_value_list ret;
  int nargin = args.length();
  if (nargin < 1)
    {
      print_usage("listen");
      return ret;
    }

  int port = args(0).int_value();
  if (error_state) return ret;

  debug = false;
  if (nargin >= 2) {
    std::string lastarg(args(nargin-1).string_value());
    if (error_state) return ret;
    lowercase(lastarg);
    if (lastarg == "debug") {
      debug = true;
      nargin--;
    } else if (lastarg == "nodebug") {
      nargin--;
    } else {
      print_usage("listen");
    }
  }

  struct in_addr localhost;
  struct in_addr hostid;
  inet_aton("127.0.0.1",&localhost);
  if (nargin >= 2) {
    std::string host(args(1).string_value());
    if (error_state) return ret;
    if (!inet_aton(host.c_str(),&hostid)) {
      error("listen: could not find host id for %s",host.c_str());
      return ret;
    }
  }

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
  
  /* listen for connections (allowing one pending connection) */
  if (listen(sockfd, canfork?1:0) == -1) { 
    perror("listen");
    close(sockfd);
    return ret;
  }

  unwind_protect::begin_frame("Flisten");
  unwind_protect_bool (buffer_error_messages);
  buffer_error_messages = true;

  sigchld_setup();

  daemonize();
      
  // XXX FIXME XXX want a 'sandbox' option which disables fopen, cd, pwd,
  // system, popen ...  Or maybe just an initial script to run for each
  // connection, plus a separate command to disable specific functions.
  STATUS("listening on port " << port);
  while(1) {  // main accept() loop
    sin_size = sizeof(struct sockaddr_in);
    STATUS("trying to accept");
    if ((channel = accept(sockfd, (struct sockaddr *)&their_addr,
			 &sin_size)) == -1) {
      // XXX FIXME XXX
      // Linux is returning "Interrupted system call" when the
      // child terminates.  Until I figure out why, I can't use
      // accept errors as a basis for breaking out of the listen
      // loop, so instead print the octave PID so that I can kill
      // it from another terminal.
      STATUS("failed to accept"  << std::endl 
	     << "Octave pid: " << octave_syscalls::getpid() );
      perror("accept");
#if defined(_sgi)
      break;
#else
      continue;
#endif
    }
    STATUS("connected");

#if defined(__GNUC__) && defined(_sgi)
    // Known bug: functions which pass or return structures use a
    // different ABI for gcc and native compilers on some architectures.
    // Whether this is a bug depends on the structure length.  SGI's 64-bit
    // architecture makes this a problem for inet_ntoa.
    STATUS("server: got connection from " << their_addr.sin_addr);
#else
    STATUS("server: got connection from " << inet_ntoa(their_addr.sin_addr));
#endif

    if (their_addr.sin_addr.s_addr == hostid.s_addr ||
	their_addr.sin_addr.s_addr == localhost.s_addr) {
      if (canfork) {
        int pid = fork();

        if (pid == -1) {
          perror("fork ");
          break;
        } else if (pid == 0) {
          close(sockfd);            // child doesn't need listener
          signal(SIGCHLD,SIG_DFL);  // child doesn't need SIGCHLD signal
          process_commands(channel);
          STATUS("child is exitting");
          exit(0);
        }
      } else {
	process_commands(channel);
        STATUS("server: connection closed");
      }
    } else {
      STATUS("server: connection refused.");
    }

    close(channel);
    channel = -1;
  }

  STATUS("could not read commands; returning");
  close(sockfd);
  unwind_protect::run_frame("Flisten");
  return ret;
}
