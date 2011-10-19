all: slab09jd.oct slsb10yd.oct

# TODO: leading and trailing underscores for sl* functions
#       (__sl*__.oct) would be nice, but this can be an issue
#       for fortran compilers.

# Frequency-weighted Hankel norm approximation with invertible weights
slab09jd.oct: slab09jd.cc
	mkoctfile slab09jd.cc \
              AB09JD.f TB01ID.f TB01KD.f AB07ND.f AB09JV.f \
              AB09JW.f AB09CX.f AG07BD.f AB08MD.f AB04MD.f \
              TB01LD.f delctg.f SB04PY.f AB09AX.f AB08NX.f \
              MB01SD.f AB09JX.f MA02AD.f TB01WD.f MB03OY.f \
              MB03PY.f MA02DD.f MB03UD.f MB03QX.f select.f \
              SB04PX.f SB03OU.f MB03QD.f MB03QY.f SB03OT.f \
              MB04ND.f MB04OD.f SB03OR.f SB03OY.f MB04NY.f \
              MB04OY.f SB03OV.f

# fit state-space model to frequency response data
slsb10yd.oct: slsb10yd.cc
	mkoctfile slsb10yd.cc \
              SB10YD.f DG01MD.f AB04MD.f SB10ZP.f AB07ND.f \
              MC01PD.f TD04AD.f TD03AY.f TB01PD.f TB01XD.f \
              AB07MD.f TB01UD.f TB01ID.f MB01PD.f MB03OY.f \
              MB01QD.f

clean:
	rm *.o core octave-core *.oct *~
