#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "xrayglob.h"

#define OUTD -9999
void ArrayInit(void);

void XRayInit(void)
{
  int ex;
  FILE *fp;
  char file_name[MAXFILENAMESIZE];
  char shell_name[5], line_name[5], trans_name[5];
  char *path;
  int Z, iE;
  int shell, line, trans;
  float E, prob;
   
  HardExit = 0;
  ExitStatus = 0;

  if ((path = getenv("XRAYLIB_DIR")) == NULL) {
    if ((path = getenv("HOME")) == NULL) {
      ErrorExit("Environmetal variables XRAYLIB_DIR and HOME not defined");
      return;
    }
    strcpy(XRayLibDir, path);
    strcat(XRayLibDir, "/.xraylib/data/");
  }
  else {
    strcpy(XRayLibDir, path);
    strcat(XRayLibDir, "/data/");
  }

  ArrayInit();

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "atomicweight.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File atomicweight.dat not found");
    return;
  }
  while ( !feof(fp) ) {
    ex=fscanf(fp,"%d", &Z);
    if (ex != 1) break;
    fscanf(fp, "%f", &AtomicWeight_arr[Z]);
    // printf("%d\t%f\n", Z, AtomicWeight_arr[Z]);
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "CS_Photo.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File CS_Photo.dat not found");
    return;
  }
  for (Z=1; Z<=ZMAX; Z++) {
    ex = fscanf(fp, "%d", &NE_Photo[Z]);
    // printf("%d\n", NE_Photo[Z]); 
    if (ex != 1) break;
    E_Photo_arr[Z] = (float*)malloc(NE_Photo[Z]*sizeof(float));
    CS_Photo_arr[Z] = (float*)malloc(NE_Photo[Z]*sizeof(float));
    CS_Photo_arr2[Z] = (float*)malloc(NE_Photo[Z]*sizeof(float));
    for (iE=0; iE<NE_Photo[Z]; iE++) {
      fscanf(fp, "%f%f%f", &E_Photo_arr[Z][iE], &CS_Photo_arr[Z][iE],
	     &CS_Photo_arr2[Z][iE]);
      // printf("%e\t%e\t%e\n", E_Photo_arr[Z][iE], CS_Photo_arr[Z][iE],
      //     CS_Photo_arr2[Z][iE]);
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "CS_Rayl.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File CS_Rayl.dat not found");
    return;
  }
  for (Z=1; Z<=ZMAX; Z++) {
    ex = fscanf(fp, "%d", &NE_Rayl[Z]);
    // printf("%d\n", NE_Rayl[Z]); 
    if (ex != 1) break;
    E_Rayl_arr[Z] = (float*)malloc(NE_Rayl[Z]*sizeof(float));
    CS_Rayl_arr[Z] = (float*)malloc(NE_Rayl[Z]*sizeof(float));
    CS_Rayl_arr2[Z] = (float*)malloc(NE_Rayl[Z]*sizeof(float));
    for (iE=0; iE<NE_Rayl[Z]; iE++) {
      fscanf(fp, "%f%f%f", &E_Rayl_arr[Z][iE], &CS_Rayl_arr[Z][iE],
	     &CS_Rayl_arr2[Z][iE]);
      // printf("%e\t%e\t%e\n", E_Rayl_arr[Z][iE], CS_Rayl_arr[Z][iE],
      //     CS_Rayl_arr2[Z][iE]);
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "CS_Compt.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File CS_Compt.dat not found");
    return;
  }

  for (Z=1; Z<=ZMAX; Z++) {
    ex = fscanf(fp, "%d", &NE_Compt[Z]);
    // printf("%d\n", NE_Compt[Z]); 
    if (ex != 1) break;
    E_Compt_arr[Z] = (float*)malloc(NE_Compt[Z]*sizeof(float));
    CS_Compt_arr[Z] = (float*)malloc(NE_Compt[Z]*sizeof(float));
    CS_Compt_arr2[Z] = (float*)malloc(NE_Compt[Z]*sizeof(float));
    for (iE=0; iE<NE_Compt[Z]; iE++) {
      fscanf(fp, "%f%f%f", &E_Compt_arr[Z][iE], &CS_Compt_arr[Z][iE],
	     &CS_Compt_arr2[Z][iE]);
      // printf("%e\t%e\t%e\n", E_Compt_arr[Z][iE], CS_Compt_arr[Z][iE],
      //     CS_Compt_arr2[Z][iE]);
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "FF.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File FF.dat not found");
    return;
  }
  for (Z=1; Z<=ZMAX; Z++) {
    ex = fscanf(fp, "%d", &Nq_Rayl[Z]);
    // printf("%d\n", Nq_Rayl[Z]); 
    if (ex != 1) break;
    q_Rayl_arr[Z] = (float*)malloc(Nq_Rayl[Z]*sizeof(float));
    FF_Rayl_arr[Z] = (float*)malloc(Nq_Rayl[Z]*sizeof(float));
    FF_Rayl_arr2[Z] = (float*)malloc(Nq_Rayl[Z]*sizeof(float));
    for (iE=0; iE<Nq_Rayl[Z]; iE++) {
      fscanf(fp, "%f%f%f", &q_Rayl_arr[Z][iE], &FF_Rayl_arr[Z][iE],
	     &FF_Rayl_arr2[Z][iE]);
      // printf("%e\t%e\t%e\n", q_Rayl_arr[Z][iE], FF_Rayl_arr[Z][iE],
      //     FF_Rayl_arr2[Z][iE]);
    }
  }
  fclose(fp);
  
  strcpy(file_name, XRayLibDir);
  strcat(file_name, "SF.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File SF.dat not found");
    return;
  }
  for (Z=1; Z<=ZMAX; Z++) {
    ex = fscanf(fp, "%d", &Nq_Compt[Z]);
    // printf("%d\n", Nq_Compt[Z]); 
    if (ex != 1) break;
    q_Compt_arr[Z] = (float*)malloc(Nq_Compt[Z]*sizeof(float));
    SF_Compt_arr[Z] = (float*)malloc(Nq_Compt[Z]*sizeof(float));
    SF_Compt_arr2[Z] = (float*)malloc(Nq_Compt[Z]*sizeof(float));
    for (iE=0; iE<Nq_Compt[Z]; iE++) {
      fscanf(fp, "%f%f%f", &q_Compt_arr[Z][iE], &SF_Compt_arr[Z][iE],
	     &SF_Compt_arr2[Z][iE]);
      // printf("%e\t%e\t%e\n", q_Compt_arr[Z][iE], SF_Compt_arr[Z][iE],
      //     SF_Compt_arr2[Z][iE]);
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "edges.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File edges.dat not found");
    return;
  }
  while ( !feof(fp) ) {
    ex = fscanf(fp,"%d", &Z);
    if (ex != 1) break;
    fscanf(fp,"%s", shell_name);
    fscanf(fp,"%f", &E);  
    E /= 1000.0;
    for (shell=0; shell<SHELLNUM; shell++) {
      if (strcmp(shell_name, ShellName[shell]) == 0) {
	EdgeEnergy_arr[Z][shell] = E;
	// printf("%d\t%s\t%e\n", Z, ShellName[shell], E);
	break;
      } 
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "fluor_lines.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File fluor_lines.dat not found");
    return;
  }
  while ( !feof(fp) ) {
    ex = fscanf(fp,"%d", &Z);
    if (ex != 1) break;
    fscanf(fp,"%s", line_name);
    fscanf(fp,"%f", &E);  
    E /= 1000.0;
    for (line=0; line<LINENUM; line++) {
      if (strcmp(line_name, LineName[line]) == 0) {
	LineEnergy_arr[Z][line] = E;
	// printf("%d\t%s\t%e\n", Z, LineName[line], E);
	break;
      } 
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "fluor_yield.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File fluor_yield.dat not found");
    return;
  }
  while ( !feof(fp) ) {
    ex = fscanf(fp,"%d", &Z);
    if (ex != 1) break;
    fscanf(fp,"%s", shell_name);
    fscanf(fp,"%f", &prob);  
    for (shell=0; shell<SHELLNUM; shell++) {
      if (strcmp(shell_name, ShellName[shell]) == 0) {
	FluorYield_arr[Z][shell] = prob;
	// printf("%d\t%s\t%e\n", Z, ShellName[shell], prob);
	break;
      } 
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "jump.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File jump.dat not found");
    return;
  }
  while ( !feof(fp) ) {
    ex = fscanf(fp,"%d", &Z);
    if (ex != 1) break;
    fscanf(fp,"%s", shell_name);
    fscanf(fp,"%f", &prob);  
    for (shell=0; shell<SHELLNUM; shell++) {
      if (strcmp(shell_name, ShellName[shell]) == 0) {
	JumpFactor_arr[Z][shell] = prob;
	// printf("%d\t%s\t%e\n", Z, ShellName[shell], prob);
	break;
      } 
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "coskron.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File coskron.dat not found");
    return;
  }
  while ( !feof(fp) ) {
    ex = fscanf(fp,"%d", &Z);
    if (ex != 1) break;
    fscanf(fp,"%s", trans_name);
    fscanf(fp,"%f", &prob);  
    for (trans=0; trans<TRANSNUM; trans++) {
      if (strcmp(trans_name, TransName[trans]) == 0) {
	CosKron_arr[Z][trans] = prob;
	// printf("%d\t%s\t%e\n", Z, TransName[trans], prob);
	break;
      } 
    }
  }
  fclose(fp);

  strcpy(file_name, XRayLibDir);
  strcat(file_name, "radrate.dat");
  if ((fp = fopen(file_name,"r")) == NULL) {
    ErrorExit("File radrate.dat not found");
    return;
  }
  while ( !feof(fp) ) {
    ex = fscanf(fp,"%d", &Z);
    if (ex != 1) break;
    fscanf(fp,"%s", line_name);
    fscanf(fp,"%f", &prob);  
    for (line=0; line<LINENUM; line++) {
      if (strcmp(line_name, LineName[line]) == 0) {
	RadRate_arr[Z][line] = prob;
	// printf("%d\t%s\t%e\n", Z, LineName[line], prob);
	break;
      } 
    }
  }
  fclose(fp);

}

void ArrayInit()
{
  int Z, shell, line, trans;

  for (Z=0; Z<=ZMAX; Z++) {
    NE_Photo[Z] = OUTD;
    NE_Rayl[Z] = OUTD;
    NE_Compt[Z] = OUTD;
    Nq_Rayl[Z] = OUTD;
    Nq_Compt[Z] = OUTD;
    AtomicWeight_arr[Z] = OUTD;
    for (shell=0; shell<SHELLNUM; shell++) {
      EdgeEnergy_arr[Z][shell] = OUTD;
      FluorYield_arr[Z][shell] = OUTD;
      JumpFactor_arr[Z][shell] = OUTD;
    }
    for (line=0; line<LINENUM; line++) {
      LineEnergy_arr[Z][line] = OUTD;
      RadRate_arr[Z][line] = OUTD;
    }
    for (trans=0; trans<TRANSNUM; trans++) {
      CosKron_arr[Z][trans] = OUTD;
    }
  }
}









