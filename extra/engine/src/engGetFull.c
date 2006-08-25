#include <stdio.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include "engine.h"
#include "engif.h"

extern int matopen;

#define GETSTR "save -ascii \"-\"\n"

/* Improvement: It would be more efficient to use a binary format */

int engGetFull( Engine *ep, char *name, int *m, int *n,
		double **pr, double **pi )
{
  int i, j, retval;
  char buf[BUFMAX];
  char comm, *ptr, str1[BUFMAX], str2[BUFMAX], str3[BUFMAX];

#ifdef DEBUGAPI
  fprintf( stdout, "Begin engGetFull ...\n" );
  fflush( stdout );
#endif

  retval = 1;
  if( matopen )
  {
    flushjunk();
    sprintf( buf, "exist(\"%s\")\n", name );
    putline( buf );
    getline( buf );
    flushprompt( 0 );
    sscanf( buf, " ans = %d", &i );

    if( i == 1 )
    {
      sprintf( buf, "save -ascii \"-\" %s\n", name );
      putline( buf );

      getline( buf );
      sscanf( buf, "%c %s %s", &comm, str1, str2 );
      if( comm != '#' )
	return retval;
      if( !strcmp( "Created", str1 ) )  /* New in Octave 2.0.14 */
      {
	getline( buf );
	sscanf( buf, "%c %s %s", &comm, str1, str2 );
      }
      if( strcmp( "name:", str1 ) )
 	return retval;
      if( strcmp( name, str2 ) )
 	return retval;
      getline( buf );
      sscanf( buf, "%c %s %s %s", &comm, str1, str2, str3 );
      if( comm != '#' )
	return retval;
      if( strcmp( "type:", str1 ) )
	return retval;
      if( !strcmp( "complex", str2 ) )  /* Complex data type */
      {
	if( !strcmp( "scalar", str3 ) )
	{
	  *m = 1;
	  *n = 1;
	  *pr = mxCalloc( 1, sizeof( **pr ) );
	  *pi = mxCalloc( 1, sizeof( **pi ) );
	  getline( buf );
	  sscanf( buf, "(%lf,%lf)", &pr[0][0], &pi[0][0] );
	}
	else
	{
	  if( !strcmp( "matrix", str3 ) )
	  {
	    getline( buf );
	    sscanf( buf, "%c %s %d", &comm, str1, m );
	    if( strcmp( "rows:", str1 ) )
	      return retval;
	    getline( buf );
	    sscanf( buf, "%c %s %d", &comm, str1, n );
	    if( strcmp( "columns:", str1 ) )
	      return retval;
	    *pr = mxCalloc( (*m)*(*n), sizeof( **pr ) );
	    *pi = mxCalloc( (*m)*(*n), sizeof( **pi ) );
	    for( i=0; i<*m; i++ )
	    {
	      getline( buf );
	      ptr = strtok( buf, " " );
	      for( j=0; j<*n; j++ )
	      {
		sscanf( ptr, "(%lf,%lf)", (*pr)+j*(*m)+i, (*pi)+j*(*m)+i );
		ptr = strtok( NULL, " " );
	      }
	    }
	  }
	  else
	    return retval;
	}
      }
      else  /* Real data type */
      {
	if( !strcmp( "scalar", str2 ) )
	{
	  *m = 1;
	  *n = 1;
	  *pr = mxCalloc( 1, sizeof( **pr ) );
	  *pi = NULL;
	  getline( buf );
	  sscanf( buf, "%lf", &pr[0][0] );
	}
	else
	{
	  if( !strcmp( "matrix", str2 ) )
	  {
	    getline( buf );
	    sscanf( buf, "%c %s %d", &comm, str1, m );
	    if( strcmp( "rows:", str1 ) )
	      return retval;
	    getline( buf );
	    sscanf( buf, "%c %s %d", &comm, str1, n );
	    if( strcmp( "columns:", str1 ) )
	      return retval;
	    *pr = mxCalloc( (*m)*(*n), sizeof( **pr ) );
	    *pi = NULL;
	    for( i=0; i<*m; i++ )
	    {
	      getline( buf );
	      ptr = strtok( buf, " " );
	      for( j=0; j<*n; j++ )
	      {
		sscanf( ptr, "%lf", *pr+j*(*m)+i );
		ptr = strtok( NULL, " " );
	      }
	    }
	  }
	  else
	    return retval;
	}
      }
      retval = 0;
      flushprompt( 0 );
    }  /* if variable exists */

  }  /* if( matopen ) */

#ifdef DEBUGAPI
  fprintf( stdout, "Exit engGetFull with status %d\n", retval );
  fflush( stdout );
#endif

  return retval;
}
