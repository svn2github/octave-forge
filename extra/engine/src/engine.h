typedef char Engine;

Engine *engOpen( char *startcommand );
int engGetFull( Engine *ep, char *name, int *m, int *n,
		double **pr, double **pi );
int engPutFull( Engine *ep, char *name, int m, int n,
		double *pr, double *pi );
int engEvalString( Engine *ep, char *string );
int engOutputBuffer( Engine *ep, char *p, int n );
int engClose( Engine *ep );

void *mxCalloc( unsigned int n, unsigned int size );
void mxFree( void *ptr );
