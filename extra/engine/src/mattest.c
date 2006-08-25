#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "engine.h"

#define MAT_STR 4000 	/* maximum number of chars of matlab return string */
#define CMD_LEN 4   	/* length of "quit" and "exit" commands */

int main( void )
{
  Engine *eng_ptr;
  char out_str[MAT_STR];
  char in_str[MAT_STR];

  int i, j;
  int m, n;
  double ar[100], ai[100], *aar, *aai;

  m = 3;
  n = 5;
  for( i=0; i<m; i++ )
    for( j=0; j<n; j++ )
      ar[i+m*j] = ai[i+m*j] = j+n*i;

  eng_ptr = engOpen( "\0" );
  engOutputBuffer(eng_ptr, out_str, MAT_STR);

  engPutFull( eng_ptr, "a", m, n, ar, NULL );
	
  strcpy(in_str, " ");

  printf("\n============================================");
  printf("\n= Emulated MATLAB command-line C interface =");
  printf("\n============================================");
  printf("\n\n");

  /* MATLAB emulation loop */
 
  while( strncmp(in_str, "quit", CMD_LEN) && strncmp(in_str, "exit", CMD_LEN ) )
  {
    printf(">> ");
    fgets(in_str, MAT_STR-1, stdin);

    if( strncmp(in_str, "quit", CMD_LEN) && strncmp(in_str, "exit", CMD_LEN ) )
    {
      engEvalString(eng_ptr, in_str);
/*       if(strlen(out_str) >= 2) */
/*       { */
/* 	out_str[0] = ' '; */
/* 	out_str[1] = ' '; */
/*       } */
      printf("%s", out_str);
    } /* if strncmp */ 
  }  /* while */

  if( engGetFull( eng_ptr, "a", &m, &n, &aar, &aai ) == 0 )
  {
    printf( "Matrix a\n" );
    if( aai == NULL )
    {
      for( i=0; i<m; i++ )
      {
	for( j=0; j<n; j++ )
	  printf( " % f", aar[i+m*j]);
	printf( "\n" );
      }
    }
    else
    {
      for( i=0; i<m; i++ )
      {
	for( j=0; j<n; j++ )
	  printf( " % f + % f", aar[i+m*j], aai[i+m*j] );
	printf( "\n" );
      }
    }
    mxFree( aar );
    mxFree( aai );
  }
  else
    printf( "Error reading Matrix a\n" );

  printf("\nClosing Matlab engine...\n");
  engClose( eng_ptr );

  return 0;
}
