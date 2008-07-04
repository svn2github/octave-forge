#include <stdio.h>
#include <string.h>

/*
 * This routine returns the contents of registers set by the cpuid instruction
 * in the array res:
 *   res[0] : eax
 *   res[1] : ebx
 *   res[2] : ecx
 *   res[3] : edx
 */
void do_cpuid(unsigned int *res, unsigned int level);
/* result defines */
#define EAX 0
#define EBX 1
#define ECX 2
#define EDX 3


/*
 * This program returns a number indicating the highest CPU feature found supported
 *
 * The ranking is:
 *    SSE3
 *    SSE2
 *    SSE
 *    MMX
 *
 * The output codes are:
 *   0 (ZERO) - could not identify or something wrong
 *   1 - Support for MMX
 *   2 - Support for SSE
 *   3 - Support for SSE2
 *   4 - Support for SSE3
 *
 * If you call this program with the parameter 
 *     -f FEATURE
 * where FEATURE is one of "mmx", "sse", "sse2", "sse3", it tests for the requiested feature
 * and returns ZERO if is is not supported and ONE if the feature is supported
 *
 */

unsigned int HAVE_MMX = 0;
unsigned int HAVE_SSE = 0;
unsigned int HAVE_SSE2 = 0;
unsigned int HAVE_SSE3 = 0;
 
void usage();
 
int main(int argc, char* argv[])
{

   if( argc == 2 ) {
      if( '-'==argv[1][0] && 'h'==argv[1][1] ) {
         usage();
         return 0;
      } else {
         usage();
         return 0;
      }
   }
   
   unsigned int r[4];
   unsigned int max_level;

/*
 * In this call, we ask for max supported cpuid support, and return if
 * we can't get any usuable info.  Also sets ebx,edx and ecx (16 chars of data)
 * to vendor ID string
 */
   do_cpuid(r, 0);
   max_level = r[EAX];
   if (!max_level)
      return(0);

/*
 * Find processor features
 */
   do_cpuid(r, 1);
   
   HAVE_MMX = (r[EDX]>>23) & 1U;
   HAVE_SSE = (r[EDX]>>25) & 1U;
   HAVE_SSE2 = (r[EDX]>>26) & 1U;
   HAVE_SSE3 = (r[ECX]>>0) & 1U;
   
   if( argc == 3 ) {
      if( '-'==argv[1][0] && 'f'==argv[1][1] ) {
         if( strcasecmp( "mmx", argv[2] ) == 0 )
            return HAVE_MMX;
         if( strcasecmp( "sse", argv[2] ) == 0 )
            return HAVE_SSE;
         if( strcasecmp( "sse2", argv[2] ) == 0 )
            return HAVE_SSE2;
         if( strcasecmp( "sse3", argv[2] ) == 0 )
            return HAVE_SSE3;
         
         return 0;
      } else
         return 0;
   }
   
   if( argc == 1 ) {
      if( HAVE_SSE3 )  return 4;
      if( HAVE_SSE2 )  return 3;
      if( HAVE_SSE  )  return 2;
      if( HAVE_MMX  )  return 1;
      return 0;
   }
   
   return 0;
}

void usage()
{
   printf("CPUFEATURE -- Check for CPU Feature\n");
   printf("\n");
   printf("Usage:\n");
   printf("   CPUFEATURE\n");
   printf("      Return an integer indicating the highest feature flag found\n");
   printf("      Return values are:\n");
   printf("          4 - SSE3\n");
   printf("          3 - SSE2\n");
   printf("          2 - SSE\n");
   printf("          1 - MMX\n");
   printf("          0 - error or not indentified\n");
   printf("\n");
   printf("   CPUFEATURE -f [mmx|sse|sse2|sse3]\n");
   printf("      Test for specified feature and return 1 if supported and zero otherwise\n");
   printf("\n");
   printf("   CPUFEATURE -h\n");
   printf("      Print this help text\n");
   printf("\n");
} 
