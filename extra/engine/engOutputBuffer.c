#include <stdio.h>
#include "engine.h"

int matbuffer = 0;
char* matbufptr = NULL;
int matbufcnt = 0;

int engOutputBuffer( Engine *ep, char *p, int n )
{

#ifdef DEBUGAPI
  fprintf( stdout, "Begin engOutputBuffer ...\n" );
  fflush( stdout );
#endif

  if( p != NULL )
  {
    matbufptr = p;
    matbufcnt = n;
  }
  else
  {
    matbufptr = NULL;
    matbufcnt = 0;
  }

#ifdef DEBUGAPI
  fprintf( stdout, "Exit engOutputBuffer with status %d\n", 0 );
  fflush( stdout );
#endif

  return 0;
}
