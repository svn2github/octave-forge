#include "xrayvars.h"

#ifndef GLOBH
#define GLOBH

extern float AtomicWeight_arr[ZMAX+1];
extern float EdgeEnergy_arr[ZMAX+1][SHELLNUM];
extern float LineEnergy_arr[ZMAX+1][LINENUM];
extern float FluorYield_arr[ZMAX+1][SHELLNUM];
extern float JumpFactor_arr[ZMAX+1][SHELLNUM];
extern float CosKron_arr[ZMAX+1][TRANSNUM];
extern float RadRate_arr[ZMAX+1][LINENUM];

extern int NE_Photo[ZMAX+1];
extern float *E_Photo_arr[ZMAX+1];
extern float *CS_Photo_arr[ZMAX+1];
extern float *CS_Photo_arr2[ZMAX+1];

extern int NE_Rayl[ZMAX+1];
extern float *E_Rayl_arr[ZMAX+1];
extern float *CS_Rayl_arr[ZMAX+1];
extern float *CS_Rayl_arr2[ZMAX+1];

extern int NE_Compt[ZMAX+1];
extern float *E_Compt_arr[ZMAX+1];
extern float *CS_Compt_arr[ZMAX+1];
extern float *CS_Compt_arr2[ZMAX+1];

extern int Nq_Rayl[ZMAX+1];
extern float *q_Rayl_arr[ZMAX+1];
extern float *FF_Rayl_arr[ZMAX+1];
extern float *FF_Rayl_arr2[ZMAX+1];

extern int Nq_Compt[ZMAX+1];
extern float *q_Compt_arr[ZMAX+1];
extern float *SF_Compt_arr[ZMAX+1];
extern float *SF_Compt_arr2[ZMAX+1];

#endif
