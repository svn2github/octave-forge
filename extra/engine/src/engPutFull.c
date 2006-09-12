#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include "engine.h"
#include "engif.h"

extern int matopen;

#define PUTSTR "load -ascii -force \"matfifo\"\n"
#define FIFO_NAME "matfifo"

int engPutFull( Engine *ep, char *name, int m, int n,
		double *pr, double *pi )
{
  int i, j;
  char buf[BUFMAX];
  int ffd;

#ifdef DEBUGAPI
  fprintf( stdout, "Begin engPutFull ...\n" );
  fflush( stdout );
#endif

  if( matopen )
  {
    /* don't forget to error check this stuff!! */
    mknod(FIFO_NAME, S_IFIFO | 0655, 0);

    putline( PUTSTR );

    if( strlen( name ) > BUFMAX-9 )
    {
      fprintf( stderr, "ERROR: engPutFull name too long\n" );
      exit( -1 );
    }

    ffd = open(FIFO_NAME, O_WRONLY);

    sprintf( buf, "# name: %s\n", name );
    write( ffd, buf, strlen(buf) );

    if( pi == NULL )  /* Real data type */
    {
      sprintf( buf, "# type: matrix\n" );
      write( ffd, buf, strlen(buf) );
      sprintf( buf, "# rows: %d\n", m );
      write( ffd, buf, strlen(buf) );
      sprintf( buf, "# columns: %d\n", n );
      write( ffd, buf, strlen(buf) );
      for( i=0; i<m; i++ )
      {
	for( j=0; j<n; j++ )
	{
	  sprintf( buf, " %f", pr[i+m*j] );
	  write( ffd, buf, strlen(buf) );
	}
	write( ffd, "\n", 1 );
      }
    }
    else  /* Complex data type */
    {
      sprintf( buf, "# type: complex matrix\n" );
      write( ffd, buf, strlen(buf) );
      sprintf( buf, "# rows: %d\n", m );
      write( ffd, buf, strlen(buf) );
      sprintf( buf, "# columns: %d\n", n );
      write( ffd, buf, strlen(buf) );
      for( i=0; i<m; i++ )
      {
	for( j=0; j<n; j++ )
	{
	  sprintf( buf, " (%f,%f)", pr[i+m*j], pi[i+m*j] );
	  write( ffd, buf, strlen(buf) );
	}
	write( ffd, "\n", 1 );
      }
    }

    close( ffd );

    remove( FIFO_NAME );

  }

  flushprompt( 0 );
  flushjunk();

#ifdef DEBUGAPI
  fprintf( stdout, "Exit engPutFull with status %d\n", 0 );
  fflush( stdout );
#endif

  return 0;
}
