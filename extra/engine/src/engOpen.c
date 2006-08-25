#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include "engine.h"
#include "engif.h"

Engine matengine=0;
int    matopen=0;

#define BINEXE "octave"

/* Bug: The parent does not know if the child (octave) dies */
/* Bug: Need a SIGTERM handler to close the engine */

Engine *engOpen( char *startcommand )
{
  static int firstopen=1;
  pid_t matpid;
  Engine *retptr;

#ifdef DEBUGAPI
  fprintf( stdout, "Begin engOpen ...\n" );
  fflush( stdout );
#endif

  retptr = NULL;
  if( !matopen )
  {
    if( openpipes() == 0 );
    {
      switch(matpid=fork())
      {
      case -1:
	perror("fork");  /* Something went wrong */
	closepipes();
	break;

      case 0:            /* This is the child process */
	plumbpipes();    /* Connect stdin/out to open pipes */
	execlp(BINEXE, BINEXE, "-q", "-f", "-i", "--traditional", "--no-line-editing", NULL);
	fprintf( stderr, "Octave execution failed!!!!!\n" );
	exit( -1 );      /* The child dies */

      default:           /* This is the parent process */
	matopen = 1;     /* Fork was successful */
	flushprompt( 0 );   /* Dump the startup stuff */
	retptr = &matengine;
	if( firstopen )
	{
	  atexit( cleanhouse );  /* If the user doesn't close the engine */
	  firstopen=0;
	}
	break;
      }
    }
  }

#ifdef DEBUGAPI
  fprintf( stdout, "Exit engOpen with status %p\n", retptr );
  fflush( stdout );
#endif

  return retptr;
}
