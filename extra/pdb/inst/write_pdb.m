## Copyright (C) 2001 Teemu Ikonen
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

#function write_pdb(p, fname[, quick])
#
# Writes a pdb struct p (see read_pdb.m) to a pdb-file fname.
#
# If the third parameter quick is given, write only ATOM and HETATM lines.

## Created: 3.8.2001
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>

function write_pdb(p, fname, varargin)

if(!isstruct(p)) # || !isfield(p, "acoord"))
    error("p must be a pdb struct");
endif

[f, err] = fopen(fname, "wt");
if(f < 0)
    error("Could not open output file: %s", err);
endif

quick = false;
if(nargin() > 2)
  quick = true;
endif

buf = blanks(80);

if(!quick)

# Print the Title Section

if( isfield(p, "classification") || isfield(p, "idcode") ) 
  if isfield(p, "classification")  
    classification = p.classification;
  else
    classification = "Unknown";
  endif
  if(isfield(p, "idcode"))
    idcode = p.idcode;
  else
    idcode = "N/A ";
  endif
  buf(1:6)   = sprintf("HEADER");
  buf(11:50) = sprintf("%-40s", classification);
  buf(63:66) = sprintf("%4s", idcode);
  buf(80)    = sprintf("\n");
  fprintf(f, "%s", buf);
endif

# Print the Primary Structure Section

numres = 0;
if(isfield(p, "seqres"))
  numres = size(p.seqres, 1);
  j = 1;
  i = 1;
  while(j <= numres),
    buf = blanks(80);
    buf(1:6)   = sprintf("SEQRES");
    buf(9:10)  = sprintf("%2d", i);
    buf(14:17) = sprintf("%4d", numres);
    k = 20;
    while(k <= 68 && j <= numres)
      buf(k:(k+2)) = sprintf("%s", p.seqres(j, :));
      k = k + 4;
      j++;
    endwhile
    buf(80) = sprintf("\n");
    fprintf(f, "%s", buf);
    i++;
  endwhile
endif
    
    # Print the Heterogen Section

# -------------

# Print the Secondary Structure Section

# -------------

# Print the Connectivity Annotation Section

# -------------

# Print the Miscellaneous Features Section

# -------------

# Print the Crystallographic and Coordinate Transformation Section 

if( isfield(p, "cellsize") || isfield(p, "cellangl") ...
    || isfield(p, "sgroup") || isfield(p, "z") )
    if(isfield(p, "cellsize"))
      cellsize = p.cellsize;
    else
      cellsize = zeros(3,1);
    endif    
    if(isfield(p, "cellangl"))
      cellangl = p.cellangl;
    else
      cellangl = zeros(3,1);
    endif    
    if(isfield(p, "sgroup"))
      sgroup = p.sgroup;
    else
      sgroup = "N/A";
    endif
    if(isfield(p, "z"))
      z = p.z;
    else
      z = 0;
    endif
    buf = blanks(80);
    buf(1:6)   = "CRYST1";
    buf(7:54) = sprintf(" %8.3f %8.3f %8.3f %6.2f %6.2f %6.2f", ...
       cellsize, cellangl);	
    buf(56:66) = sprintf("%-11s", sgroup);
    buf(67:70) = sprintf("%4d", z);
    buf(80) = "\n";
    fprintf(f, "%s", buf);
end
  
#buf = blanks(80);
#buf(1:55) = "ORIGX1      1.000000  0.000000  0.000000       0.000000";
#buf(80) = "\n";
#fprintf(f, "%s", buf);
#buf = blanks(80);
#buf(1:55) = "ORIGX2      0.000000  1.000000  0.000000       0.000000";
#buf(80) = "\n";
#fprintf(f, "%s", buf);
#buf = blanks(80);
#buf(1:55) = "ORIGX3      0.000000  0.000000  1.000000       0.000000";
#buf(80) = "\n";
#fprintf(f, "%s", buf);

if( isfield(p, "scalem") || isfield(p, "scalev") )
  if(isfield(p, "scalem"))
    scalem = p.scalem;
  else
    scalem = eye(3);
  endif
  if(isfield(p, "scalev"))
    scalev = p.scalev;
  else
    scalev = zeros(3,1);
  endif
  buf = blanks(80);
  buf(1:6) = "SCALE1";
  buf(11:40) = sprintf(" %9.6f %9.6f %9.6f", scalem(1,:));
  buf(46:55) = sprintf("%10.5f", scalev(1));
  buf(80) = "\n";
  fprintf(f, "%s", buf);
  buf = blanks(80);
  buf(1:6) = "SCALE2";
  buf(11:40) = sprintf(" %9.6f %9.6f %9.6f", scalem(2,:));
  buf(46:55) = sprintf("%10.5f", scalev(2));
  buf(80) = "\n";
  fprintf(f, "%s", buf);
  buf = blanks(80);
  buf(1:6) = "SCALE3";
  buf(11:40) = sprintf(" %9.6f %9.6f %9.6f", scalem(3,:));
  buf(46:55) = sprintf("%10.5f", scalev(3));
  buf(80) = "\n";
  fprintf(f, "%s", buf);
endif

endif # if(!quick)

serialn = 0;
if(isfield(p, "acoord"))
  natoms = size(p.acoord, 1);
  if(isfield(p, "atomname"))
    atomname = toupper(p.atomname);
  else
    for i = 1:natoms,
      atomname(i, :) = "    ";
    endfor
  endif
  if(isfield(p, "aresname"))
    aresname = toupper(p.aresname);
  else
    for i = 1:natoms,
      aresname(i, :) = "   ";
    endfor
  endif
  if(isfield(p, "aresseq"))
    aresseq = p.aresseq;
  else
    aresseq = ones(natoms, 1);
  endif
  if(isfield(p, "aoccupancy"))
    aoccupancy = p.aoccupancy;
  else
    aoccupancy = ones(natoms, 1);
  endif
  if(isfield(p, "atempfactor"))
    atempfactor = p.atempfactor;
  else
    atempfactor = zeros(natoms, 1);
  endif
  
  i = 1;
  segid = toascii("C")-1;
  first = 1;
  while(i <= natoms)      
    if (aresseq(i) == 1)
      if(first)
         segid = segid + 1;
         first = 0;
      endif
    else
      first = 1;
    endif
    serialn++;
#    buf = blanks(80);
#    buf(1:6)   = "ATOM  ";
#    buf(7:11)  = sprintf("%5d", serialn);
#    buf(13:16) = sprintf("%4s", atomname(i,:));
#    buf(18:20) = aresname(i,:);
#    buf(23:26) = sprintf("%4d", aresseq(i));
#    buf(31:54) = sprintf("%8.3f%8.3f%8.3f", p.acoord(i,:));
#    buf(55:60) = sprintf(" %5.2f", aoccupancy(i,:));
#    buf(61:66) = sprintf("%6.2f", atempfactor(i,:));
#    buf(73:76) = sprintf("%c   ", segid);
#    buf(74) = "\n";
#    fprintf(f, "%s", buf(1:74));

    fprintf(f, "ATOM  ");
    fprintf(f, "%5d", serialn);
    fprintf(f, " %-4s", atomname(i,:));
    fprintf(f, " %3s", aresname(i,:));
    fprintf(f, "  %4d", aresseq(i));
    fprintf(f, "    %8.3f%8.3f%8.3f", p.acoord(i,:));
    fprintf(f, " %5.2f", aoccupancy(i,:));
    fprintf(f, "%6.2f", atempfactor(i,:));
    fprintf(f, "      %-4c", segid);    
    fprintf(f, "\n");
    
    i++;
  endwhile

  serialn++;
  buf = blanks(80);
  buf(1:6)   = "TER   ";
  buf(7:11)  = sprintf("%5d", serialn);
  buf(18:20) = aresname(natoms, :);
  buf(23:26) = sprintf("%4d", aresseq(natoms));
  buf(80) = "\n";
  fprintf(f, "%s", buf);
endif

if(isfield(p,"hetcoord")) 
  nhet = size(p.hetcoord, 1);
  if(isfield(p, "hetname"))
    hetname = toupper(p.hetname);
  else
    for i = 1:nhet
      hetname(i, :) = "    ";
    endfor
  endif
  if(isfield(p, "hetresname"))
    hetresname = toupper(p.hetresname);
  else
    for i = 1:nhet,
      hetresname(i, :) = "   ";
    endfor
  endif
  if(isfield(p, "hetresseq"))
    hetresseq = p.hetresseq;
  else
    hetresseq = ones(nhet, 1);
  endif
  if(isfield(p, "hetoccupancy"))
    hetoccupancy = p.hetoccupancy;
  else
    hetoccupancy = ones(nhet, 1);
  endif
  if(isfield(p, "hettempfactor"))
    hettempfactor = p.hettempfactor;
  else
    hettempfactor = zeros(nhet, 1);
  endif

  i = 1;
  while(i <= nhet)
    serialn++;
    
#    buf = blanks(80);
#    buf(1:6)   = "HETATM";
#    buf(7:11)  = sprintf("%5d", serialn);
#    buf(13:16) = sprintf("%s", hetname(i,:));
#    buf(18:20) = hetresname(i, :);
#    buf(23:26) = sprintf("%4d", hetresseq(i));
#    buf(31:54) = sprintf(" %7.3f %7.3f %7.3f", p.hetcoord(i,:));
#    buf(55:60) = sprintf(" %5.2f", hetoccupancy(i,:));
#    buf(61:66) = sprintf("%6.2f", hettempfactor(i,:));
#    buf(80) = "\n";
#    fprintf(f, "%s", buf);

    fprintf(f, "HETATM");
    fprintf(f, "%5d", serialn);
    fprintf(f, " %-4s", hetname(i,:));
    fprintf(f, " %3s", hetresname(i,:));
    fprintf(f, "  %4d", hetresseq(i));
    fprintf(f, "    %8.3f%8.3f%8.3f", p.hetcoord(i,:));
    fprintf(f, " %5.2f", hetoccupancy(i,:));
    fprintf(f, "%6.2f", hettempfactor(i,:));
#    fprintf(f, "      %-4c", segid);    
    fprintf(f, "\n");

    i++;
  endwhile
endif

#buf = blanks(80);
#buf(1:6) = "MASTER";
#buf(11:70) = sprintf(" %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d %4d",
#                     0, 0, 0, 0, 0, 0, 0, 6, natoms+nhetatoms, 1, 0, numres);
#buf(80) = "\n";
#fprintf(f, "%s", buf);

buf = blanks(80);
buf(1:6) = "END   ";
buf(80) = "\n";
fprintf(f, "%s", buf);

fclose(f);

endfunction
