This package introduces the functions gfprimdf, gftuple, rspoly,
rsenco, rsdeco, that attempt to be compatiable with the equivalent 
Matlab functions as much as possible. In addition it introduces 
the functions rsenco_ccsds and rsdeco_ccsds that encode and
decode to the CCSDS standard.

This code makes extensive use of the Reed Solomon libraries of
Phil Karn, that are available from http://www.ka9q.net/code/fec.
Please note that if you use version 3.1.1, then a small patch 
to the code called "patch.rs-3.1.1" in the current directory is needed.
Alternatively, use the supplied version of the code. This code
must be built and installed prior to building these octave 
functions.

Please note that these octave functions access internal structures
of Phil Karn's software and as such the header "int.h" must be 
available.

Also, these functions were developed using the outputs of the matlab
code only to achieve compatiability. No attempt was made to read the
matlab dot-m files. I believe the code to be relatively compatiable
however, with one particularity being that the matlab code returns
different parity symbols than tis code. This should not be an issue
if the code is used with itself only.

A function rstest.m is available that should excercise this code
fairly well, for the values of M and K chosen.

This code is licensed under the Gnu Public License

David Bateman
dbateman@free.fr

INSTALL
-------

Within octave-forge, there is no need to do anything.  Everything will
be built and installed automatically.

* Install reed-solomon-3.1.1 under ${ROOT}/reed-solomon-3.1.1 or use
  existing copy (assume ${ROOT} is where this code lives)
* Alter INSTALDIR in the Makefile to be the installation directory
  for the oct-files
% cd reed-solomon-3.1.1
% ./configure
% make
% make install
% cd ..
% make
% make install
