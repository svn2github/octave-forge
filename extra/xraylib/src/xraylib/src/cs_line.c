#include "xrayglob.h"
#include "xraylib.h"

//////////////////////////////////////////////////////////////////////
//                                                                  //
//                    Fluorescent line cross section (cm2/g)        //
//                                                                  //
//          Z : atomic number                                       //
//          E : energy (keV)
//          line :                                                  //
//            KA_LINE 0                                             //
//            KB_LINE 1                                             //
//            LA_LINE 2                                             //
//            LB_LINE 3                                             //
//                                                                  //
// Ref: M. O. Krause et. al. "X-Ray Fluorescence Cross Sections     //
// for K and L X Rays of the Elements", ORNL 53                     //
//////////////////////////////////////////////////////////////////////
      
float CS_FluorLine(int Z, int line, float E)
{
  float JumpK, JumpL1, JumpL2, JumpL3;
  float TaoL1=0., TaoL2=0., TaoL3=0.;
  float cs_line, Factor = 1.;

  if (Z<1 || Z>ZMAX) {
    ErrorExit("Z out of range in function CS_FluorLine");
    return 0;
  }

  if (E <= 0.) {
    ErrorExit("Energy <=0 in function CS_FluorLine");
    return 0;
  }

  if (line>=KN5_LINE && line<=KB_LINE) {
    if (E > EdgeEnergy(Z, K_SHELL)) {
      JumpK = JumpFactor(Z, K_SHELL);
      if (JumpK <= 0.)
	return 0.;
      Factor = ((JumpK-1)/JumpK) * FluorYield(Z, K_SHELL);
    }
    else
      return 0.;                               
  }

  else if (line>=L1N7_LINE && line<=L1M1_LINE) {
    if (E > EdgeEnergy(Z, L1_SHELL)) {
      JumpL1 = JumpFactor(Z, L1_SHELL);
      if (JumpL1 <= 0.)
	return 0.;
      Factor = ((JumpL1-1)/JumpL1) * FluorYield(Z, L1_SHELL);
    }
    else
      return 0.;                               
  }
  
  else if ((line>=L2N7_LINE && line<=L2M1_LINE) || line==LB_LINE) {
    if( E > EdgeEnergy(Z,K_SHELL) ) {
      JumpK = JumpFactor(Z,K_SHELL) ;
      if( JumpK <= 0. )
	return 0. ;
      Factor /= JumpK ;
    }
    JumpL1 = JumpFactor(Z,L1_SHELL) ;
    JumpL2 = JumpFactor(Z,L2_SHELL) ;
    if(E>EdgeEnergy (Z,L1_SHELL)) {
      if( JumpL1 <= 0.|| JumpL2 <= 0. )
	return 0. ;
      TaoL1 = (JumpL1-1) / JumpL1 ;
      TaoL2 = (JumpL2-1) / (JumpL2*JumpL1) ;
    }
    else if( E > EdgeEnergy(Z,L2_SHELL) ) {
      if( JumpL2 <= 0. )
	return 0. ;
      TaoL1 = 0. ;
      TaoL2 = (JumpL2-1)/(JumpL2) ;
    }
    Factor *= (TaoL2 + TaoL1*CosKronTransProb(Z,F12_TRANS)) *
      FluorYield(Z,L2_SHELL) ;
  }
  
  else if ((line>=L3N7_LINE && line<=L3M1_LINE) || line==LA_LINE) {
    if( E > EdgeEnergy(Z,K_SHELL) ) {
      JumpK = JumpFactor(Z,K_SHELL) ;
      if( JumpK <= 0. )
	return 0.;
      Factor /= JumpK ;
    }
    JumpL1 = JumpFactor(Z,L1_SHELL) ;
    JumpL2 = JumpFactor(Z,L2_SHELL) ;
    JumpL3 = JumpFactor(Z,L3_SHELL) ;
    if( E > EdgeEnergy(Z,L1_SHELL) ) {
      if( JumpL1 <= 0.|| JumpL2 <= 0. || JumpL3 <= 0. )
	return 0. ;
      TaoL1 = (JumpL1-1) / JumpL1 ;
      TaoL2 = (JumpL2-1) / (JumpL2*JumpL1) ;
      TaoL3 = (JumpL3-1) / (JumpL3*JumpL2*JumpL1) ;
    }
    else if( E > EdgeEnergy(Z,L2_SHELL) ) {
      if( JumpL2 <= 0. || JumpL3 <= 0. )
	return 0. ;
      TaoL1 = 0. ;
      TaoL2 = (JumpL2-1) / (JumpL2) ;
      TaoL3 = (JumpL3-1) / (JumpL3*JumpL2) ;
    }
    else if( E > EdgeEnergy(Z,L3_SHELL) ) {
      TaoL1 = 0. ;
      TaoL2 = 0. ;
      if( JumpL3 <= 0. )
	return 0. ;
      TaoL3 = (JumpL3-1) / JumpL3 ;
    }
    else
      Factor = 0; 
    Factor *= (TaoL3 + TaoL2 * CosKronTransProb(Z,F23_TRANS) +
        TaoL1 * (CosKronTransProb(Z,F13_TRANS) + CosKronTransProb(Z,FP13_TRANS)
        + CosKronTransProb(Z,F12_TRANS) * CosKronTransProb(Z,F23_TRANS))) ;
    Factor *= (FluorYield(Z,L3_SHELL) ) ;
  }

  else {
    ErrorExit("Line not allowed in function CS_FluorLine");
    return 0;
  }
  
  cs_line = CS_Photo(Z, E) * Factor * RadRate(Z, line) ;
  
  return (cs_line);
}            












