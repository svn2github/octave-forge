#include <stdio.h>

#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#include "engine.h"
#include "engif.h"

int  pfd1[2];
int  pfd2[2];
int  outcnt;

extern Engine matengine;
extern int matopen;
extern char *matbufptr;
extern int matbufcnt;

static int savechar( int outdest, char dat );

int openpipes( void )
{
  int retval = 0;

  if( pipe( pfd1 ) == -1 )
  {
    perror("pipe");
    retval = -1;
  }
  else
  {
    if( pipe( pfd2 ) == -1 )
    {
      perror("pipe");
      close( pfd1[0] );  /* Needs some error checking */
      close( pfd1[1] );  /* Needs some error checking */
      retval = -1;
    }
  }
  return retval;
}


int closepipes( void )
{
  int retval = 0;

  /* Needs some error checking */

  close( pfd1[0] );
  close( pfd1[1] );
  close( pfd2[0] );
  close( pfd2[1] );

  return retval;
}


int plumbpipes( void )
{
  int retval = 0;

  /* Needs some error checking */

  close(0);       /* close normal stdin */
  dup(pfd2[0]);   /* make stdin same as pfd2[0] */
  close(1);       /* close normal stdout */
  dup(pfd1[1]);   /* make stdout same as pfd1[1] */

  return retval;
}


void cleanhouse( void )
{
  if( matopen )
    engClose( &matengine );
}


int getline( char* buf )
{
  int i;

  /* Read a line into buf */
  i = 0;
  do
  {
    read( pfd1[0], &buf[i], 1 );
    i++;
    if( i == BUFMAX-1 )
      buf[i-1] = '\n';
  }
  while( buf[i-1] != '\n' );
  buf[i] = '\0';

#ifdef DEBUGAPI
  printf( "getline: %s", buf );
#endif

  return 0;
}


int putline( char* buf )
{
  int count;

  /* Write a line from buf */
  count = write( pfd2[1], buf, strlen(buf) );

#ifdef DEBUGAPI
  printf( "putline: %s", buf );
#endif

  return count;
}

int flushjunk( void )
{
#ifdef DEBUGAPI
  char temp;
  int count;
  fd_set rfds;
  struct timeval tv;
  int retval;

  printf( "flushjunk: " );

  count = 0;
  do
  {
    /* Check the Octave pipe to see if it has input. */
    FD_ZERO(&rfds);
    FD_SET(pfd1[0], &rfds);
    /* Wait up to two seconds. */
    tv.tv_sec = 2;
    tv.tv_usec = 0;

    retval = select(pfd1[0]+1, &rfds, NULL, NULL, &tv);
    /* Don't rely on the value of tv now! */

    if (retval)
    {
      count++;
      read( pfd1[0], &temp, 1 );
      printf( "%c", temp );
    }
  }  while( retval );

  printf("\n");
  return count;
#else
  return 0;
#endif
}


int flushprompt( int outkey )
{
  char temp;
  int test, count;

  /* If outkey=1  : write all engine output to the output buffer */
  /*    outkey=2  : write all engine output to stdout */
  /*    otherwise : discard all output from the engine */

  count = 0;
  outcnt = 0;

/*   printf( "flushprompt: " ); */

  test = 1;
  while( test != 4 )
  {
    read( pfd1[0], &temp, 1 );
    switch( test )
    {
    case 0:
      if( temp == '\n' )
	test = 1;
      else
	test = 0;
      break;
    case 1:
      if( temp == '\n' )
	test = 1;
      else
      {
	if( temp == '>' )
	  test = 2;
	else
	  test = 0;
      }
      break;
    case 2:
      if( temp == '>' )
	test = 3;
      else
      {
	test = 0;
	savechar( outkey, '>' );   /* Save the current ">" char */
      }
      break;
    case 3:
      if( temp == ' ' )
	test = 4;
      else
      {
	test = 0;
	savechar( outkey, '>' );   /* Save the previous ">" char */
	savechar( outkey, '>' );   /* Save the current ">" char */
      }
      break;
    }
    if( test < 2 )
      savechar( outkey, temp );
  }
  if( outkey == 2 )
    printf( ">> " );
  else
  {
    if( outkey == 1 )
    {
      /* Add terminating NULL to output buffer */
      if( matbufptr != NULL )
	if( outcnt < matbufcnt )
	{
	  matbufptr[outcnt] = '\0';
	  outcnt++;
	}
    }
  }

  return count;
}


static int savechar( int outdest, char dat )
{
  /* If outdest=1 : write all engine output to the output buffer */
  /*    outdest=2 : write all engine output to stdout */
  /*    otherwise : discard all output from the engine */

  switch( outdest )
  {
  case 0:
    break;
  case 1:
    if( matbufptr != NULL )
      if( outcnt < matbufcnt-1 )
      {
	matbufptr[outcnt] = dat;
	outcnt++;
      }
    break;
  case 2:
    putchar( dat );
    break;
  default:
    fprintf( stderr, "Engine: unknown output destination specified\n" );
  }

  return 0;
}
