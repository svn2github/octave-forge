int flushprompt( int outkey );
int flushjunk( void );
int getline( char* buf );
int putline( char* buf );
int openpipes( void );
int closepipes( void );
int plumbpipes( void );
void cleanhouse( void );

extern int pfd1[2];
extern int pfd2[2];

#define BUFMAX 1000
