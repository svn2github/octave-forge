LAPACK_LIBS = $$(mkoctfile -p LAPACK_LIBS)
BLAS_LIBS = $$(mkoctfile -p BLAS_LIBS)
FLIBS = $$(mkoctfile -p FLIBS)

all: slab09hd.oct slab09id.oct slab09jd.oct slsb16ad.oct slsb16bd.oct \
     slsb16cd.oct slsb10yd.oct

# TODO: leading and trailing underscores for sl* functions
#       (__sl*__.oct) would be nice, but this can be an issue
#       for fortran compilers.

# balanced stochastic truncation model reduction
slab09hd.oct: slab09hd.cc
	mkoctfile slab09hd.cc \
              AB09HD.f TB01ID.f AB04MD.f TB01KD.f AB09HY.f \
              AB09IX.f MB03UD.f SB02MD.f AB09DD.f TB01LD.f \
              SB03OU.f MA02AD.f MB03QX.f select.f SB03OT.f \
              SB02MR.f SB02MS.f MB03QD.f SB02MU.f SB02MV.f \
              SB02MW.f MB04ND.f MB04OD.f MB03QY.f SB03OR.f \
              SB03OY.f SB04PX.f MB04NY.f MB04OY.f SB03OV.f \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# balanced truncation & singular perturbation approximation model reduction
slab09id.oct: slab09id.cc
	mkoctfile slab09id.cc \
              AB09ID.f TB01PD.f SB08DD.f TB01ID.f TB01KD.f \
              AB09IX.f AB09IY.f SB08CD.f MB04ND.f TB01XD.f \
              MB04OD.f MB01WD.f MB03UD.f AB07MD.f SB01FY.f \
              AB09DD.f TB01LD.f SB03OU.f TB01UD.f MA02AD.f \
              MA02BD.f MB03OY.f MB03QX.f MB01PD.f select.f \
              MB01YD.f MB04NY.f MB01ZD.f SB03OT.f MB04OX.f \
              MB04OY.f MB03QD.f SB03OY.f MB03QY.f MB01QD.f \
              SB03OR.f SB03OV.f SB04PX.f \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# hankel-norm approximation model reduction
slab09jd.oct: slab09jd.cc
	mkoctfile slab09jd.cc \
              AB09JD.f TB01ID.f TB01KD.f AB07ND.f AB09JV.f \
              AB09JW.f AB09CX.f AG07BD.f AB08MD.f AB04MD.f \
              TB01LD.f delctg.f SB04PY.f AB09AX.f AB08NX.f \
              MB01SD.f AB09JX.f MA02AD.f TB01WD.f MB03OY.f \
              MB03PY.f MA02DD.f MB03UD.f MB03QX.f select.f \
              SB04PX.f SB03OU.f MB03QD.f MB03QY.f SB03OT.f \
              MB04ND.f MB04OD.f SB03OR.f SB03OY.f MB04NY.f \
              MB04OY.f SB03OV.f \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# balanced truncation & singular perturbation approximation controller reduction
slsb16ad.oct: slsb16ad.cc
	mkoctfile slsb16ad.cc \
              SB16AD.f TB01ID.f SB16AY.f TB01KD.f AB09IX.f \
              MB04OD.f MB01WD.f SB03OD.f MB03UD.f AB05PD.f \
              AB09DD.f AB07ND.f TB01LD.f AB05QD.f SB03OU.f \
              MA02AD.f MB03QX.f select.f MB01YD.f MB01ZD.f \
              SB03OT.f MB04OY.f MB03QD.f MB04ND.f MB03QY.f \
              SB03OR.f SB03OY.f SB04PX.f MB04NY.f SB03OV.f \
              ${LAPACK_LIBS} ${BLAS_LIBS}	

# coprime factorization state-feedback controller reduction
slsb16bd.oct: slsb16bd.cc
	mkoctfile slsb16bd.cc \
              SB16BD.f AB09AD.f AB09BD.f SB08GD.f SB08HD.f \
              TB01ID.f AB09AX.f MA02GD.f AB09BX.f TB01WD.f \
              MA02DD.f MB03UD.f select.f AB09DD.f SB03OU.f \
              MA02AD.f SB03OT.f MB04ND.f MB04OD.f SB03OR.f \
              SB03OY.f SB04PX.f MB04NY.f MB04OY.f SB03OV.f \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# frequency-weighted coprime factorization state-feedback controller reduction
slsb16cd.oct: slsb16cd.cc
	mkoctfile slsb16cd.cc \
              SB16CD.f SB16CY.f AB09IX.f SB03OD.f MB02UD.f \
              AB09DD.f MA02AD.f MB03UD.f select.f SB03OU.f \
              MB01SD.f SB03OT.f MB04ND.f MB04OD.f SB03OR.f \
              SB03OY.f SB04PX.f MB04NY.f MB04OY.f SB03OV.f \
              ${LAPACK_LIBS} ${BLAS_LIBS}

# fit state-space model to frequency response data
slsb10yd.oct: slsb10yd.cc
	mkoctfile slsb10yd.cc \
              SB10YD.f DG01MD.f AB04MD.f SB10ZP.f AB07ND.f \
              MC01PD.f TD04AD.f TD03AY.f TB01PD.f TB01XD.f \
              AB07MD.f TB01UD.f TB01ID.f MB01PD.f MB03OY.f \
              MB01QD.f \
              ${LAPACK_LIBS} ${BLAS_LIBS}

clean:
	rm *.o core octave-core *.oct *~
