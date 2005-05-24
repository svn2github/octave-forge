// Copyright (C) 2001-2004 Teemu Ikonen
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#include <octave/oct.h>
#include <octave/oct-map.h>
#include <octave/ov-str-mat.h>
#include <sys/mman.h>
#include <fcntl.h>

#define BUFLEN 80

inline double strntod(const char* startptr, int n)
{
    char tmp_buf[70]; // this fails completely, if n > 70
    double dtemp = 0.0;
    int i;
    
    for(i = 0; i < n; ++i)
	tmp_buf[i] = startptr[i];
    tmp_buf[i] = '\0';
//    printf("buf: %s\n", tmp_buf);
    sscanf(tmp_buf, " %lg", &dtemp);
//    printf("dtemp: %g\n", dtemp);
        
    return dtemp;
}

inline void bufcpy(const char *source, char *dest)
{
    int i;
    for(i = 0; (i < BUFLEN) && (source[i] != '\n') && (source[i] != '\r'); i++)
	dest[i] = source[i];
    
    for( ; i < BUFLEN; i++)
	dest[i] = ' ';
    
}

DEFUN_DLD(creadpdb, args, ,
"function p = creadpdb(fname)\n\
\n\
 Read a protein databank file from fname to a structure p containing\n\
 some of the elements below:\n\
\n\
 p.cellsize       = Vector giving the lengths of lattice vectors a, b and c\n\
 p.cellangl       = Vector giving the lattice angles alpha, beta and gamma\n\
 p.sgroup         = The full Hermann-Mauguin space group symbol\n\
 p.z              = Z, number of polymeric chains in a unit cell\n\
 p.scalem         = Matrix of the transformation to crystallographic coords\n\
 p.scalev         = Vector of the transformation to crystallographic coords\n\
 p.atomname       = Names of the atoms in ATOM entries (N x 4 char matrix)\n\
 p.aresname       = Name of the residue (N x 3 char matrix)\n\
 p.aresseq        = Residue sequence number (N x 1 matrix)\n\
 p.acoord         = Coordinates of the atoms in ATOM entries (N x 3 matrix)\n\
 p.aoccupancy     = Occupancy of the atom (N x 1 matrix)\n\
 p.atempfactor    = Temperature factor of the atoms (N x 1 matrix)\n\
 p.hetname        = Names of the heterogen atoms (N x 4 char matrix)\n\
 p.hetresname     = Name of the heterogen residue (N x 3 char matrix)\n\
 p.hetresseq      = Heterogen residue sequence number (N x 1 matrix)\n\
 p.hetcoord       = Coordinates of the heterogen atoms (N x 3 matrix)\n\
 p.hetoccupancy   = Occupancy of the heterogen atoms (N x 1 matrix)\n\
 p.hettempfactor  = Temperature factors of the hetatoms (N x 1 matrix)\n\
")
{
    int fd;
    off_t fsize;
    const char *fname;
    const char *fp, *fp_beg;
//    struct stat f_status;
    int i, j;    
    octave_value_list retval;

    if( (args.length() > 0) && args(0).is_string()) {
	fname = (args(0).string_value()).c_str();
    } else {
	error("fname must be a string");
	return octave_value_list();
    }
    if((fd = open(fname, O_RDONLY)) < 0) {
	error("Could not open file");
	return octave_value_list();
    }

    fsize = lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);    
    fp = (const char *) mmap(0, fsize, PROT_READ, MAP_PRIVATE, fd, 0);
    fp_beg = fp;

    // get a reasonable upper bound on the size of atom and hetatm arrays
    int maxentries = fsize / 55;

//    printf("maxent: %d\n", maxentries);
    
    // allocate enough space to hold everything, resize later.
    charMatrix atomname = charMatrix(maxentries, 4);
    charMatrix aresname = charMatrix(maxentries, 3);
    Matrix     aresseq  =     Matrix(maxentries, 1);
    Matrix     acoord   =     Matrix(maxentries, 3);
    Matrix     aoccupancy =   Matrix(maxentries, 1);
    Matrix     atempfactor =  Matrix(maxentries, 1);

    charMatrix hetname  =      charMatrix(maxentries, 4);
    charMatrix hetresname =    charMatrix(maxentries, 3);
    Matrix     hetresseq =     Matrix(maxentries, 1);
    Matrix     hetcoord  =     Matrix(maxentries, 3);
    Matrix     hetoccupancy =  Matrix(maxentries, 1);
    Matrix     hettempfactor = Matrix(maxentries, 1);    

    ColumnVector cellsize(3);
    ColumnVector cellangl(3);
    charMatrix sgroup(1, 11);
    double z;
    bool havecryst = false;
    
    Matrix scalem(3, 3);
    ColumnVector scalev(3);
    bool havescale = false;

    for(i = 0; i < 11; i++)
       sgroup(0,i) = ' ';
   
    int natom = 0;
    int nhet = 0;
    char *tmp_buf = (char *) malloc(80);
    char *buf;
    while((fp - fp_beg) < fsize) {
//	printf("char : %c\n", *fp);
    	switch(*fp) {
	    case 'A':
		bufcpy(fp, tmp_buf);
		if(strncmp(tmp_buf, "ATOM", 4) == 0) {
		    
//		    printf("ATOM\n");

		    buf = tmp_buf-1; // just to make the offsets match the spec
		    atomname(natom, 0) = *(buf+13);
		    atomname(natom, 1) = *(buf+14);
		    atomname(natom, 2) = *(buf+15);
		    atomname(natom, 3) = *(buf+16);

		    aresname(natom, 0) = *(buf+18);
		    aresname(natom, 1) = *(buf+19);
		    aresname(natom, 2) = *(buf+20);		    

		    aresseq(natom, 0) = strntod(buf+23, 4);
		    
		    acoord(natom, 0) = strntod(buf+31, 8);
		    acoord(natom, 1) = strntod(buf+39, 8);
		    acoord(natom, 2) = strntod(buf+47, 8);

		    aoccupancy(natom, 0) = strntod(buf+55, 6);

		    atempfactor(natom, 0) = strntod(buf+61, 6);		    

		    natom++;
		}
		break;
	    case 'H':
		bufcpy(fp, tmp_buf);
		if(strncmp(tmp_buf, "HETATM", 6) == 0) {
		    buf = tmp_buf-1; // just to make the offsets match the spec

		    hetname(nhet, 0) = *(buf+13);
		    hetname(nhet, 1) = *(buf+14);
		    hetname(nhet, 2) = *(buf+15);
		    hetname(nhet, 3) = *(buf+16);

		    hetresname(nhet, 0) = *(buf+18);
		    hetresname(nhet, 1) = *(buf+19);
		    hetresname(nhet, 2) = *(buf+20);		    

		    hetresseq(nhet, 0) = strntod(buf+23, 4);
		    
		    hetcoord(nhet, 0) = strntod(buf+31, 8);
		    hetcoord(nhet, 1) = strntod(buf+39, 8);
		    hetcoord(nhet, 2) = strntod(buf+47, 8);

		    hetoccupancy(nhet, 0) = strntod(buf+55, 6);

		    hettempfactor(nhet, 0) = strntod(buf+61, 6);

		    nhet++;
		}
		break;
	    case 'C':
		bufcpy(fp, tmp_buf);
//		printf("%s\n", tmp_buf);		
		if(strncmp(tmp_buf, "CRYST1", 6) == 0) {
		    buf = tmp_buf-1; // just to make the offsets match the spec
		    cellsize(0) = strntod(buf+7, 9);
		    cellsize(1) = strntod(buf+16, 9);
		    cellsize(2) = strntod(buf+25, 9);
		    cellangl(0) = strntod(buf+34, 7);	
		    cellangl(1) = strntod(buf+41, 7);
		    cellangl(2) = strntod(buf+48, 7);
		    for(i = 0; i < 11; i++)
			sgroup(0, i) = buf[i+56];
		    z = strntod(buf+67, 4);
		    havecryst = true;
		    
		}
		break;
	    case 'S':
		bufcpy(fp, tmp_buf);
		if(strncmp(tmp_buf, "SCALE", 5) == 0) {
		    buf = tmp_buf-1; // just to make the offsets match the spec
		    int n = (static_cast<int>(strntod(buf+6, 1)) - 1);
//		    printf("n = %d\n", n);
		    if ((n <= 2) && (n >= 0)) {
			havescale = true;
			scalem(n, 0) = strntod(buf+11, 10);
			scalem(n, 1) = strntod(buf+21, 10);
			scalem(n, 2) = strntod(buf+31, 10);
			scalev(n) = strntod(buf+46, 10);
		    }
		}
		break;	    
	    default:
		    ;
	}
	for(; ((fp - fp_beg) < fsize) && (*fp != '\n') ; fp++)
	    ;
	if((fp - fp_beg) < fsize)
	    fp++;
    }

    free(tmp_buf);
    munmap((void *) fp_beg, fsize);
    close(fd);
    
//    printf("natoms: %d\nnhets: %d\n", natom, nhet);
    
    atomname.resize(natom, 4);
    aresname.resize(natom, 3);
    aresseq.resize(natom, 1);
    acoord.resize(natom, 3);
    aoccupancy.resize(natom, 1);
    atempfactor.resize(natom, 1);

    hetname.resize(nhet, 4);
    hetresname.resize(nhet, 3);
    hetresseq.resize(nhet, 1);
    hetcoord.resize(nhet, 3);
    hetoccupancy.resize(nhet, 1);
    hettempfactor.resize(nhet, 1);

//    printf("resized\n");
    
    Octave_map p; // = Octave_map();
    if(natom > 0) {
	p.assign("atomname", octave_value(atomname, true));
	p.assign("aresname", octave_value(aresname, true));
	p.assign("aresseq", octave_value(aresseq));
	p.assign("acoord", octave_value(acoord));
	p.assign("aoccypancy", octave_value(aoccupancy));
	p.assign("atempfactor", octave_value(atempfactor));
    }

    if(nhet > 0) {
	p.assign("hetname", octave_value(hetname, true));
	p.assign("hetresname", octave_value(hetresname, true));
	p.assign("hetresseq", octave_value(hetresseq));
	p.assign("hetcoord", octave_value(hetcoord));
	p.assign("hetoccypancy", octave_value(hetoccupancy));
	p.assign("hettempfactor", octave_value(hettempfactor));    
    }

    if(havecryst) {
	p.assign("cellsize", octave_value(cellsize));
	p.assign("cellangl", octave_value(cellangl));	
	p.assign("sgroup", octave_value(sgroup, true));
	p.assign("z", octave_value(z));
    }

    if(havescale) {
	p.assign("scalem", octave_value(scalem));
	p.assign("scalev", octave_value(scalev));	
    }    
    
    retval = octave_value_list(octave_value(p));
	
    return retval;
    
}
