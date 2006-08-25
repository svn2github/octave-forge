#include <stdio.h>
#include <unistd.h>
#include "engine.h"
#include "engif.h"

extern int matopen;
extern int pfd1[2];
extern int pfd2[2];
extern int matbuffer;
extern char* matbufptr;
extern int matbufcnt;

static int outcnt;


int engEvalString( Engine *ep, char *string )
{
  int test;
  char cmdstr[200];

#ifdef DEBUGAPI
  fprintf( stdout, "Begin engEvalString(%s)...\n", string );
  fflush( stdout );
#endif

  if( matopen )
  {
    outcnt = 0;

    flushjunk();

    /* Do not include any newlines in the Octave command string */

    test = 0;
    while( (string[test] != '\n') && (string[test] != '\0') && (test<198) )
    {
      cmdstr[test] = string[test];
      test++;
    }
    cmdstr[test] = '\n';
    test++;
    cmdstr[test] = '\0';

    putline( cmdstr );
    flushprompt( 1 );
  }

  flushjunk();

#ifdef DEBUGAPI
  fprintf( stdout, "Exit engEvalString with status %d\n", 0 );
  fflush( stdout );
#endif

  return 0;
}
