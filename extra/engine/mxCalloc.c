#include "engine.h"
#include <stdlib.h>

void *mxCalloc( unsigned int n, unsigned int size )
{
  return calloc( (size_t) n, (size_t) size );
}
