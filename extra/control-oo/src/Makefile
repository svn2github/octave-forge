all: slab08nd.oct slab13dd.oct

# transmission zeros of state-space models
slab08nd.oct: slab08nd.cc
	mkoctfile slab08nd.cc \
              AB08ND.f AB08NX.f TB01ID.f MB03OY.f MB03PY.f

# L-infinity norm
slab13dd.oct: slab13dd.cc
	mkoctfile slab13dd.cc \
              AB13DD.f MA02AD.f MB01SD.f MB03XD.f TB01ID.f \
              TG01AD.f TG01BD.f AB13DX.f MA01AD.f MA02ID.f \
              MB03XP.f MB04DD.f MB04QB.f MB04TB.f MB03XU.f \
              MB04TS.f UE01MD.f MB02RD.f MB02SD.f MB04QC.f \
              MB04QF.f MB03YA.f MB03YD.f MB02RZ.f MB04QU.f \
              MB02SZ.f MB03YT.f

clean:
	rm *.o core octave-core *.oct *~
