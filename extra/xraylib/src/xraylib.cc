#include <octave/oct.h>
#include "xraylib.h"

static bool xraylib_init = false;

#define __MULTIBEG__(OCTNAME, N, DSTR) \
DEFUN_DLD(OCTNAME, args, nargout, DSTR) \
{ \
   dim_vector dv; \
   octave_value retval; \
 \
   if(!xraylib_init) \
       XRayInit(); \
\
   if(args.length() != N) { \
      print_usage (); \
      return octave_value(); \
   } \
   dv = dim_vector(); \
   dv.resize(N); \
   for(int i = 0; i < N; i++) { \
      if(!args(i).is_real_type()) { \
	 error("The arguments must be real."); \
	 print_usage (); \
	 return octave_value(); \
      } \
      dv.elem(i) = args(i).length(); \
   } \
   NDArray y(dv);

#define __MULTIEND__ \
   retval = octave_value(y).squeeze(); \
   return retval; \
}

#define DEF_MULTIMAPPER1(ONAME, FNAME, T1, DOCSTRING) \
__MULTIBEG__(ONAME, 1, DOCSTRING) \
   NDArray n = args(0).array_value(); \
   for(int i = 0; i < n.length(); i++) { \
      y(i) = static_cast<double>(FNAME(static_cast<T1>(n.xelem(i)))); \
   } \
   y.resize(dim_vector(y.dims().elem(0), 1)); \
   retval = octave_value(y).squeeze(); \
   return retval; \
}

#define DEF_MULTIMAPPER2(ONAME, FNAME, T1, T2, DOCSTRING) \
__MULTIBEG__(ONAME, 2, DOCSTRING) \
   NDArray n = args(0).array_value(); \
   NDArray m = args(1).array_value(); \
   for(int i = 0; i < m.length(); i++) { \
      for(int j = 0; j < n.length(); j++) { \
      y(j, i) = static_cast<double>(FNAME(static_cast<T1>(n.xelem(j)), \
					  static_cast<T2>(m.xelem(i)))); \
      } \
   } \
__MULTIEND__

#define DEF_MULTIMAPPER3(ONAME, FNAME, T1, T2, T3, DOCSTRING) \
__MULTIBEG__(ONAME, 3, DOCSTRING) \
   NDArray n = args(0).array_value(); \
   NDArray m = args(1).array_value(); \
   NDArray p = args(2).array_value(); \
   for(int i = 0; i < p.length(); i++) { \
      for(int j = 0; j < m.length(); j++) { \
         for(int k = 0; k < n.length(); k++) { \
            y(k, j, i) = static_cast<double>(FNAME(static_cast<T1>(n.xelem(j)), \
                                                   static_cast<T2>(m.xelem(j)), \
                                                   static_cast<T3>(p.xelem(i)))); \
         } \
      } \
   } \
__MULTIEND__
	  
#define DEF_MULTIMAPPER4(ONAME, FNAME, T1, T2, T3, T4, DOCSTRING) \
__MULTIBEG__(ONAME, 4, DOCSTRING) \
   Array<octave_idx_type> idx(4); \
   for(int i = 0; i < 4; i++) \
	idx(i) = 0; \
   NDArray n = args(0).array_value(); \
   NDArray m = args(1).array_value(); \
   NDArray p = args(2).array_value(); \
   NDArray q = args(3).array_value(); \
   for(int i = 0; i < p.length(); i++) { \
      idx(0) = i; \
      for(int j = 0; j < m.length(); j++) { \
      idx(1) = j; \
      for(int k = 0; k < n.length(); k++) { \
      idx(2) = k; \
      for(int l = 0; l < n.length(); l++) { \
      idx(3) = i; \
	 y(idx) = static_cast<double>(FNAME(static_cast<T1>(n.xelem(j)), \
                                            static_cast<T2>(m.xelem(j)), \
                                            static_cast<T3>(p.xelem(j)), \
                                            static_cast<T4>(q.xelem(i)))); \
      } } } \
   } \
__MULTIEND__	  


DEF_MULTIMAPPER1(AtomicWeight, AtomicWeight, int, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} AtomicWeight (@var{Z})\n\
\n\
Return the atomic mass of an element with atomic number Z.\n\
@end deftypefn\n\
")
						      
DEF_MULTIMAPPER2(CosKronTransProb, CosKronTransProb, int, int, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{p} =} CosKronTransProb (@var{Z}, @var{t})\n\
\n\
Coster-Kronig transition probability\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{t} : transition type:\n\
F1_TRANS   0\n\
F12_TRANS  1\n\
F13_TRANS  2\n\
FP13_TRANS 3\n\
F23_TRANS  4\n\
@end example\n\
@end deftypefn\n\
")		      

DEF_MULTIMAPPER3(CS_FluorLine, CS_FluorLine, int, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CS_FluorLine (@var{Z}, @var{E},@var{line})\n\
\n\
Fluorescent line cross section (cm2/g)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{line} :\n\
KA_LINE 0\n\
KB_LINE 1\n\
LA_LINE 2\n\
LB_LINE 3\n\
(Individual lines are also defined with negative flags\n\
See file lines.h in src directory for equivalences.)\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")


DEF_MULTIMAPPER2(EdgeEnergy, EdgeEnergy, int, int, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} EdgeEnergy (@var{Z}, @var{shell})\n\
\n\
Absorption edge energy (keV)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{shell} :\n\
K_SHELL  0\n\
L1_SHELL 1\n\
L2_SHELL 2\n\
L3_SHELL 3\n\
M1_SHELL 4\n\
M2_SHELL 5\n\
M3_SHELL 6\n\
M4_SHELL 7\n\
M5_SHELL 8\n\
@end example\n\
@end deftypefn\n\
")		    

DEF_MULTIMAPPER2(LineEnergy, LineEnergy, int, int, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} LineEnergy (@var{Z},@var{line})\n\
\n\
Fluorescent line energy (keV)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{line} :\n\
KA_LINE 0\n\
KB_LINE 1\n\
LA_LINE 2\n\
LB_LINE 3\n\
(Individual lines are also defined with negative flags\n\
See file lines.h in src directory for equivalences.)\n\
@end example\n\
@end deftypefn\n\
")
			    
DEF_MULTIMAPPER2(FluorYield, FluorYield, int, int, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} FluorYield (@var{Z}, @var{shell})\n\
\n\
Fluorescent Yield\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{shell} :\n\
K_SHELL  0\n\
L1_SHELL 1\n\
L2_SHELL 2\n\
L3_SHELL 3\n\
M1_SHELL 4\n\
M2_SHELL 5\n\
M3_SHELL 6\n\
M4_SHELL 7\n\
M5_SHELL 8\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(JumpFactor, JumpFactor, int, int, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} JumpFactor (@var{Z}, @var{shell})\n\
\n\
Jump Ratio\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{shell} :\n\
K_SHELL  0\n\
L1_SHELL 1\n\
L2_SHELL 2\n\
L3_SHELL 3\n\
M1_SHELL 4\n\
M2_SHELL 5\n\
M3_SHELL 6\n\
M4_SHELL 7\n\
M5_SHELL 8\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER4(DCSP_Rayl, DCSP_Rayl, int, float, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCSP_Rayl (@var{Z}, @var{E},@var{theta},@var{phi})\n\
\n\
Differential Rayleigh scattering cross section\n\
for polarized beam (cm2/g/sterad)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@var{phi} : scattering azimuthal angle (rad)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER4(DCSP_Compt, DCSP_Compt, int, float, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCSP_Compt (@var{Z}, @var{E},@var{theta},@var{phi})\n\
\n\
Differential Compton scattering cross section\n\
for polarized beam (cm2/g/sterad)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@var{phi} : scattering azimuthal angle (rad)\n\
@end example\n\
@end deftypefn\n\
")    									    

DEF_MULTIMAPPER3(DCSP_KN, DCSP_KN, float, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCSP_KN (@var{E}, @var{theta}, @var{phi})\n\
\n\
Klein-Nishina differential scattering cross section\n\
for polarized beam (barn/atom/sterad)\n\
\n\
@example\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@var{phi} : scattering azimuthal angle (rad)\n\
@end example\n\
@end deftypefn\n\
")    

DEF_MULTIMAPPER2(DCSP_Thoms, DCSP_Thoms, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCSP_Thoms (@var{theta}, @var{phi})\n\
\n\
Thomson differential scattering cross section\n\
for polarized beam (barn/atom/sterad)\n\
\n\
@example\n\
@var{theta} : scattering polar angle (rad)\n\
@var{phi} : scattering azimuthal angle (rad)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(RadRate, RadRate, int, int, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} RadRate (@var{Z}, @var{line})\n\
\n\
Fractional Radiative Rate\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{line} :\n\
KA_LINE 0\n\
KB_LINE 1\n\
LA_LINE 2\n\
LB_LINE 3\n\
(Individual lines are also defined with negative flags\n\
See file lines.h in src directory for equivalences.)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(FF_Rayl, FF_Rayl, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =}  (@var{Z}, @var{q})\n\
\n\
Atomic form factor for Rayleigh scattering\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{q} : momentum transfer\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(SF_Compt, SF_Compt, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} SF_Compt (@var{Z}, @var{q})\n\
\n\
Incoherent scattering function for Compton scattering\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{q} : momentum transfer\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER1(DCS_Thoms, DCS_Thoms, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCS_Thoms (@var{theta})\n\
\n\
Thomson differential scattering cross section (barn/atom/sterad)\n\
\n\
@example\n\
@var{theta} : scattering polar angle (rad)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(DCS_KN, DCS_KN, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCS_KN (@var{}, @var{})\n\
\n\
Klein-Nishina differential scatt cross sect (barn/atom/sterad)\n\
\n\
@example\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER3(DCS_Rayl, DCS_Rayl, int, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCS_Rayl (@var{Z}, @var{E}, @var{theta})\n\
\n\
Differential Rayleigh scattering cross section (cm2/g/sterad)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@end example\n\
@end deftypefn\n\
")    

DEF_MULTIMAPPER3(DCS_Compt, DCS_Compt, int, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCS_Compt (@var{Z}, @var{E}, @var{theta})\n\
\n\
Differential Compton scattering cross section (cm2/g/sterad)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(MomentTransf, MomentTransf, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} MomentTransf (@var{E}, @var{theta})\n\
\n\
Momentum transfer for X-ray photon scattering (angstrom-1)\n\
\n\
@example\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER1(CS_KN, CS_KN, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CS_KN (@var{E})\n\
\n\
Total klein-Nishina cross section (barn/atom)\n\
\n\
@example\n\
@var{E} : Energy (keV)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(ComptonEnergy, ComptonEnergy, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} ComptonEnergy (@var{E0}, @var{theta})\n\
\n\
Photon energy after Compton scattering (keV)\n\
\n\
@example\n\
@var{E0} : Photon Energy before scattering (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(CS_Total, CS_Total, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CS_Total (@var{Z}, @var{E})\n\
\n\
Total cross section  (cm2/g)\n\
(Photoelectric + Compton + Rayleigh)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")
   
DEF_MULTIMAPPER2(CS_Photo, CS_Photo, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CS_Photo (@var{Z}, @var{E})\n\
\n\
Photoelectric absorption cross section  (cm2/g)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(CS_Rayl, CS_Rayl, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CS_Rayl (@var{Z}, @var{E})\n\
\n\
Rayleigh scattering cross section  (cm2/g)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")
     
DEF_MULTIMAPPER2(CS_Compt, CS_Compt, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CS_Compt (@var{Z}, @var{E})\n\
\n\
Compton scattering cross section  (cm2/g)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER3(CSb_FluorLine, CSb_FluorLine, int, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CSb_FluorLine (@var{Z}, @var{line}, @var{E})\n\
\n\
Fluorescent line cross section (barn/atom)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@var{line} :\n\
KA_LINE 0\n\
KB_LINE 1\n\
LA_LINE 2\n\
LB_LINE 3\n\
(Individual lines are also defined with negative flags\n\
See file lines.h in src directory for equivalences.)\n\
@end example\n\
@end deftypefn\n\
")				        

DEF_MULTIMAPPER2(CSb_Total, CSb_Total, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CSb_Total (@var{Z}, @var{E})\n\
\n\
Total cross section  (barn/atom)\n\
(Photoelectric + Compton + Rayleigh)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")
   
DEF_MULTIMAPPER2(CSb_Photo, CSb_Photo, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CSb_Photo (@var{Z}, @var{E})\n\
\n\
Photoelectric absorption cross section  (barn/atom)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER2(CSb_Rayl, CSb_Rayl, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CSb_Rayl (@var{Z}, @var{E})\n\
\n\
Rayleigh scattering cross section  (barn/atom)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")
        
DEF_MULTIMAPPER2(CSb_Compt, CSb_Compt, int, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} CSb_Compt (@var{Z}, @var{E})\n\
\n\
Compton scattering cross section  (barn/atom)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : energy (keV)\n\
@end example\n\
@end deftypefn\n\
")

DEF_MULTIMAPPER3(DCSb_Rayl, DCSb_Rayl, int, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCSb_Rayl (@var{Z}, @var{E}, @var{theta})\n\
\n\
Differential Rayleigh scattering cross sect (barn/atom/sterad)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@end example\n\
@end deftypefn\n\
")				        

DEF_MULTIMAPPER3(DCSb_Compt, DCSb_Compt, int, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCSb_Compt (@var{Z}, @var{E}, @var{theta})\n\
\n\
Differential Compton scatt cross section (barn/atom/sterad)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@end example\n\
@end deftypefn\n\
")				        

DEF_MULTIMAPPER4(DCSPb_Rayl, DCSPb_Rayl, int, float, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCSPb_Rayl (@var{Z}, @var{E},@var{theta},@var{phi})\n\
\n\
Differential Rayleigh scattering cross section\n\
for polarized beam (barn/atom/sterad)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@var{phi} : scattering azimuthal angle (rad)\n\
@end example\n\
@end deftypefn\n\
")    					

DEF_MULTIMAPPER4(DCSPb_Compt, DCSPb_Compt, int, float, float, float, "\
  -*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{a} =} DCSPb_Compt (@var{Z}, @var{E},@var{theta},@var{phi})\n\
\n\
Differential Compton scattering cross section\n\
for polarized beam (barn/atom/sterad)\n\
\n\
@example\n\
@var{Z} : atomic number\n\
@var{E} : Energy (keV)\n\
@var{theta} : scattering polar angle (rad)\n\
@var{phi} : scattering azimuthal angle (rad)\n\
@end example\n\
@end deftypefn\n\
")    					
