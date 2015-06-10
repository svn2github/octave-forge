
sinclude Makeconf

# assumptions to make if not using ./configure script
ifndef OCTAVE_FORGE
	MKOCTFILE=mkoctfile

#	Adapt the variables NETCDF_INC and NETCDF_LIB
#       for octcdf with NetCDF support only (and not OPeNDAP).
#	The folder NETCDF_INC should contain netcdf.h and
#	the folder NETCDF_LIB should contain libnetcdf.a or 
#	libnetcdf.so

#	NETCDF_INC=/usr/include/netcdf-3
#	NETCDF_LIB=/usr/lib/netcdf-3
#	OCTCDF_CFLAGS := $(CPPFLAGS) -I$(NETCDF_INC)
#	OCTCDF_LIBS := $(LDFLAGS) -L$(NETCDF_LIB) -lnetcdf

#       For NetCDF with OpenDAP (version 3.5.2 or higher) support use 
#	the following two lines instead
        OCTCDF_LIBS=$(shell ncdap-config --libs)
        OCTCDF_CFLAGS=$(shell ncdap-config --cflags) 


#       If you use a version of octave 2.1.x, uncomment the following
#       two lines

#	HAVE_OCTAVE_21 = 1
#	OCTCDF_CFLAGS := $(OCTCDF_CFLAGS) -DHAVE_OCTAVE_21

	HAVE_NETCDF = yes
	RM = rm -f
endif

NCTARGET = netcdf.oct

NCSOURCES = ov-netcdf.cc ov-ncfile.cc ov-ncvar.cc ov-ncatt.cc ov-ncdim.cc 
OBJECTS = $(patsubst %.cc,%.o,$(NCSOURCES))

MFILES =  ncchar.m ncfloat.m nclong.m ncbyte.m ncdouble.m ncint.m ncshort.m 

TARGETS = $(NCTARGET)

MOFLAGS = $(OCTCDF_CFLAGS)
MOLIBS = $(OCTCDF_LIBS) 

#
# comment this line out if your octave installation does not have integer types.
#
MOFLAGS := $(MOFLAGS) -DHAVE_OCTAVE_INT

all: $(TARGETS)

mfiles: $(MFILES)

ov-netcdf.o ov-ncfile.o ov-ncvar.o  ov-ncatt.o  ov-ncdim.o: ov-netcdf.h ov-ncfile.h ov-ncvar.h  ov-ncatt.h ov-ncdim.h

$(NCTARGET) : $(OBJECTS)
	$(MKOCTFILE) -o $@ $(MOFLAGS) $(OBJECTS) $(MOLIBS) 

%.o:%.cc
	$(MKOCTFILE) -c $< $(MOFLAGS) $(DEFINES)


$(MFILES): nctype.m4
	m4 --define=TYPE=$(patsubst nc%.m,%,$@) nctype.m4 > $@

clean: ; -$(RM) -R *.o core* octave-core *.oct *~ *.nc autom4te.cache
