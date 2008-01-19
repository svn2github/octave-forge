# Copyright (C) 2008, Thomas Treichl <treichl@users.sourceforge.net>
# OdePkg - Package for solving ordinary differential equations with octave
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

EXTERNALDIRS  = hairer
EXTERNALFILES = hairer/dc_decsol.f
COMPILEDMEX   = odepkg_mexsolver_seulex.mex

all : $(COMPILEDMEX)

$(EXTERNALDIRS) :
	mkdir $(EXTERNALDIRS)

$(EXTERNALFILES) : $(EXTERNALDIRS)
	curl -s -S http://www.unige.ch/~hairer/prog/nonstiff/dopri5.f -o hairer/dopri5.f
	curl -s -S http://www.unige.ch/~hairer/prog/nonstiff/dop853.f -o hairer/dop853.f
	curl -s -S http://www.unige.ch/~hairer/prog/nonstiff/odex.f   -o hairer/odex.f
	curl -s -S http://www.unige.ch/~hairer/prog/stiff/radau.f     -o hairer/radau.f
	curl -s -S http://www.unige.ch/~hairer/prog/stiff/radau5.f    -o hairer/radau5.f
	curl -s -S http://www.unige.ch/~hairer/prog/stiff/rodas.f     -o hairer/rodas.f
	curl -s -S http://www.unige.ch/~hairer/prog/stiff/seulex.f    -o hairer/seulex.f
	curl -s -S http://www.unige.ch/~hairer/prog/stiff/decsol.f    -o hairer/decsol.f
	curl -s -S http://www.unige.ch/~hairer/prog/stiff/dc_decsol.f -o hairer/dc_decsol.f

$(COMPILEDMEX) : $(EXTERNALFILES)
	patch -p0 < hairer.diff
	mkoctfile --mex odepkg_mexsolver_dopri5.c odepkgmex.c odepkgext.c hairer/dopri5.f
	mkoctfile --mex odepkg_mexsolver_dop853.c odepkgmex.c odepkgext.c hairer/dop853.f
	mkoctfile --mex odepkg_mexsolver_odex.c   odepkgmex.c odepkgext.c hairer/odex.f
	mkoctfile --mex odepkg_mexsolver_radau.c  odepkgmex.c odepkgext.c hairer/radau.f\
			hairer/decsol.f hairer/dc_decsol.f
	mkoctfile --mex odepkg_mexsolver_radau5.c odepkgmex.c odepkgext.c hairer/radau5.f\
			hairer/decsol.f hairer/dc_decsol.f
	mkoctfile --mex odepkg_mexsolver_rodas.c  odepkgmex.c odepkgext.c hairer/rodas.f\
			hairer/decsol.f hairer/dc_decsol.f
	mkoctfile --mex odepkg_mexsolver_seulex.c odepkgmex.c odepkgext.c hairer/seulex.f\
			hairer/decsol.f hairer/dc_decsol.f

clean :
	rm -rf $(EXTERNALDIRS) *.o *.mex octave-core *~