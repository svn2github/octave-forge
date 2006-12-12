#include <stdio.h>
#include "xraylib.h"
#include "xrayglob.h"

#define OUTFILE "xrayglob_inline.c"
#define FLOAT_PER_LINE 4
#define INT_PER_LINE 10
#define NAME_PER_LINE 4

void XRayInit(void);
FILE *f;

#define PR_MAT(ROWMAX, COLMAX, ARRNAME) \
for(j = 0; j < (ROWMAX); j++) { \
  print_floatvec((COLMAX), ARRNAME[j]); \
  fprintf(f, ",\n"); \
} \
fprintf(f, "};\n\n");

#define PR_DYNMAT(NVAR, EVAR, ENAME) \
  for(j = 0; j < ZMAX+1; j++) { \
    fprintf(f, "float __%s_%d[] =\n", ENAME, j);\
    print_floatvec(NVAR[j], EVAR[j]); \
    fprintf(f, ";\n\n");\
  } \
\
  fprintf(f, "float *%s[] =\n", ENAME);\
  fprintf(f, "{\n"); \
  for(i = 0; i < ZMAX+1; i++) { \
    fprintf(f, "__%s_%d, ", ENAME, i);\
    if(i%NAME_PER_LINE == (NAME_PER_LINE-1))\
      fprintf(f, "\n");\
  }\
  fprintf(f, "};\n\n");    

#define PR_NUMVEC(NVAR, NNAME) \
  fprintf(f, "int %s[] =\n", NNAME); \
  print_intvec(ZMAX+1, NVAR); \
  fprintf(f, ";\n\n");



void print_floatvec(int arrmax, float *arr)
{
  int i;
  fprintf(f, "{\n"); 
  for(i = 0; i < arrmax; i++) {
    fprintf(f, "%.10E, ", arr[i]);
    if(i%FLOAT_PER_LINE == (FLOAT_PER_LINE-1))
      fprintf(f, "\n");
  }
  fprintf(f, "}");
}

void print_intvec(int arrmax, int *arr)
{
  int i;
  fprintf(f, "{\n"); 
  for(i = 0; i < arrmax; i++) {
    fprintf(f, "%d, ", arr[i]);
    if(i%INT_PER_LINE == (INT_PER_LINE-1))
      fprintf(f, "\n");
  }
  fprintf(f, "}");
}


int main(void) 
{

  int i,j;

  XRayInit();

  f = fopen(OUTFILE, "w");
  if(f == NULL) {
    perror("file open");
  }

  fprintf(f, "#define GLOBH\n");
  fprintf(f, "#include \"xrayglob.h\"\n\n");

  fprintf(f, "float AtomicWeight_arr[ZMAX+1] =\n");
  print_floatvec(ZMAX+1, AtomicWeight_arr);
  fprintf(f, ";\n\n");

  fprintf(f, "float EdgeEnergy_arr[ZMAX+1][SHELLNUM] = {\n");
  PR_MAT(ZMAX+1, SHELLNUM, EdgeEnergy_arr);

  fprintf(f, "float LineEnergy_arr[ZMAX+1][LINENUM] = {\n");
  PR_MAT(ZMAX+1, LINENUM, LineEnergy_arr);

  fprintf(f, "float FluorYield_arr[ZMAX+1][SHELLNUM] = {\n");
  PR_MAT(ZMAX+1, SHELLNUM, FluorYield_arr);

  fprintf(f, "float JumpFactor_arr[ZMAX+1][SHELLNUM] = {\n");
  PR_MAT(ZMAX+1, SHELLNUM, JumpFactor_arr);

  fprintf(f, "float CosKron_arr[ZMAX+1][TRANSNUM] = {\n");
  PR_MAT(ZMAX+1, TRANSNUM, CosKron_arr);

  fprintf(f, "float RadRate_arr[ZMAX+1][LINENUM] = {\n");
  PR_MAT(ZMAX+1, LINENUM, RadRate_arr);

  PR_NUMVEC(NE_Photo, "NE_Photo");
  PR_DYNMAT(NE_Photo, E_Photo_arr, "E_Photo_arr");
  PR_DYNMAT(NE_Photo, CS_Photo_arr, "CS_Photo_arr");
  PR_DYNMAT(NE_Photo, CS_Photo_arr2, "CS_Photo_arr2");

  PR_NUMVEC(NE_Rayl, "NE_Rayl");
  PR_DYNMAT(NE_Rayl, E_Rayl_arr, "E_Rayl_arr");
  PR_DYNMAT(NE_Rayl, CS_Rayl_arr, "CS_Rayl_arr");
  PR_DYNMAT(NE_Rayl, CS_Rayl_arr2, "CS_Rayl_arr2");

  PR_NUMVEC(NE_Compt, "NE_Compt");
  PR_DYNMAT(NE_Compt, E_Compt_arr, "E_Compt_arr");
  PR_DYNMAT(NE_Compt, CS_Compt_arr, "CS_Compt_arr");
  PR_DYNMAT(NE_Compt, CS_Compt_arr2, "CS_Compt_arr2");

  PR_NUMVEC(Nq_Rayl, "Nq_Rayl");
  PR_DYNMAT(Nq_Rayl, q_Rayl_arr, "q_Rayl_arr");
  PR_DYNMAT(Nq_Rayl, FF_Rayl_arr, "FF_Rayl_arr");
  PR_DYNMAT(Nq_Rayl, FF_Rayl_arr2, "FF_Rayl_arr2");

  PR_NUMVEC(Nq_Compt, "Nq_Compt");
  PR_DYNMAT(Nq_Compt, q_Compt_arr, "q_Compt_arr");
  PR_DYNMAT(Nq_Compt, SF_Compt_arr, "SF_Compt_arr");
  PR_DYNMAT(Nq_Compt, SF_Compt_arr2, "SF_Compt_arr2");

  fclose(f);

  return 0;
}
