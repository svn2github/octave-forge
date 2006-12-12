#define GLOBH
#include "xrayglob.h"

float AtomicWeight_arr[ZMAX+1];
float EdgeEnergy_arr[ZMAX+1][SHELLNUM];
float LineEnergy_arr[ZMAX+1][LINENUM];
float FluorYield_arr[ZMAX+1][SHELLNUM];
float JumpFactor_arr[ZMAX+1][SHELLNUM];
float CosKron_arr[ZMAX+1][TRANSNUM];
float RadRate_arr[ZMAX+1][LINENUM];

int NE_Photo[ZMAX+1];
float *E_Photo_arr[ZMAX+1];
float *CS_Photo_arr[ZMAX+1];
float *CS_Photo_arr2[ZMAX+1];

int NE_Rayl[ZMAX+1];
float *E_Rayl_arr[ZMAX+1];
float *CS_Rayl_arr[ZMAX+1];
float *CS_Rayl_arr2[ZMAX+1];

int NE_Compt[ZMAX+1];
float *E_Compt_arr[ZMAX+1];
float *CS_Compt_arr[ZMAX+1];
float *CS_Compt_arr2[ZMAX+1];

int Nq_Rayl[ZMAX+1];
float *q_Rayl_arr[ZMAX+1];
float *FF_Rayl_arr[ZMAX+1];
float *FF_Rayl_arr2[ZMAX+1];

int Nq_Compt[ZMAX+1];
float *q_Compt_arr[ZMAX+1];
float *SF_Compt_arr[ZMAX+1];
float *SF_Compt_arr2[ZMAX+1];
