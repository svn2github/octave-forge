#include <stdio.h>
#include <unistd.h>
#include "engine.h"
#include "engif.h"

extern int matopen;


int engClose( Engine *ep )
{

#ifdef DEBUGAPI
  fprintf( stdout, "Begin engClose ...\n" );
  fflush( stdout );
#endif

  if( matopen )
  {
    putline( "exit\n" );
    closepipes();
    matopen = 0;
  }

#ifdef DEBUGAPI
  fprintf( stdout, "Exit engClose with status %d\n", 0 );
  fflush( stdout );
#endif

  return 0;
}
