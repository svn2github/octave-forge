function a = read_pdb(fname)
#function p = read_pdb(fname)
#
# Read a protein databank file from fname to a structure p containing 
# some of the elements below:
#
# p.classification = Classifies the molecule(s)
# p.idcode         = PDB ID of the file
# p.seqres         = Amino acid sequence of the molecule
# p.cellsize       = Vector giving the lengths of lattice vectors a, b and c
# p.cellangl       = Vector giving the lattice angles alpha, beta and gamma
# p.sgroup         = The full Hermann-Mauguin space group symbol
# p.z              = Z, number of polymeric chains in a unit cell
# p.scalem         = Matrix of the transformation to crystallographic coords
# p.scalev         = Vector of the transformation to crystallographic coords
# p.atomname       = Names of the atoms in ATOM entries (N x 4 char matrix)
# p.aresname       = Name of the residue (N x 3 char matrix)
# p.aresseq        = Residue sequence number (N x 1 matrix)   
# p.acoord         = Coordinates of the atoms in ATOM entries (N x 3 matrix)
# p.aoccupancy     = Occupancy of the atom (N x 1 matrix) 
# p.atempfactor    = Temperature factor of the atoms (N x 1 matrix) 
# p.hetname        = Names of the heterogen atoms (N x 4 char matrix)
# p.hetresname     = Name of the heterogen residue (N x 3 char matrix)
# p.hetresseq      = Heterogen residue sequence number (N x 1 matrix)   
# p.hetcoord       = Coordinates of the heterogen atoms (N x 3 matrix)
# p.hetoccupancy   = Occupancy of the heterogen atoms (N x 1 matrix) 
# p.hettempfactor  = Temperature factors of the hetatoms (N x 1 matrix) 

# p.az             = Number of electrons, Z, of the atoms (N x 1 matrix) 
# p.hetz           = Number of electrons, Z, of the hetatoms (N x 1 matrix) 

## Created: 3.8.2001
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>

[f, err] = fopen(fname, "r");
if(f < 0),
    error("Could not open file: %s", err);
end
disp("Read...")

# Parse the title section

#a.classification = "Unknown";
#a.idcode         = "N/A";

obsolete = false;
caveat = false;
buf = fgets(f);
while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "HEADER"))
    a.classification = deblank(buf(11:50));
    a.idcode = buf(63:66);
  elseif(!obsolete && findstr(buf(1:6), "OBSLTE") )
    warning("PDB-file contains OBSLTE record");
    obsolete = true;
  elseif(findstr(buf(1:6), "TITLE"))
  elseif(!caveat && findstr(buf(1:6), "CAVEAT"))
    warning("PDB-file contains CAVEAT record");
    caveat = true;
  elseif(findstr(buf(1:6), "COMPND"))
    ;
  elseif(findstr(buf(1:6), "SOURCE"))
    ;
  elseif(findstr(buf(1:6), "KEYWDS"))
    ;
  elseif(findstr(buf(1:6), "EXPDTA"))
    ;
  elseif(findstr(buf(1:6), "AUTHOR"))
    ;
  elseif(findstr(buf(1:6), "REVDAT"))
    ;
  elseif(findstr(buf(1:6), "SPRSDE"))
    ;
  elseif(findstr(buf(1:6), "JRNL"))
    ;
  elseif(findstr(buf(1:6), "REMARK"))
    ;
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Title");

# Parse the Primary Structure Section
  
while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "DBREF"))
    ;
  elseif(findstr(buf(1:6), "SEQADV"))
    ;
  elseif(findstr(buf(1:6), "SEQRES"))
    numres = sscanf(buf(14:17), "%d");
    if(buf(12) != " ")
      #FIXME: 
      warning("More than one chain in molecule, confused")
    endif
    j = 1;
    a.seqres = "   ";
    while(findstr(buf(1:6), "SEQRES"))
      i = 20;
      while(!strcmp(buf(i:i+2), "   ") && i < 69)
        a.seqres(j,:) = buf(i:i+2);
        j++;
        i = i + 4;
      endwhile
      buf = fgets(f);
    endwhile    
    if(j-1 != numres)
      warning("Read %d residues, expected %d", j, numres);
    endif

  elseif(findstr(buf(1:6), "MODRES"))
    ;
  else
    break;
  endif
  buf = fgets(f);
endwhile  
disp("Primary Structure");

# Parse the Heterogen Section

while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "HET"))
    ;
  elseif(findstr(buf(1:6), "HETNAM"))
    ;
  elseif(findstr(buf(1:6), "HETSYN"))
    ;
  elseif(findstr(buf(1:6), "FORMUL"))
    ;
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Heterogen");

# Parse the Secondary Structure Section

while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "HELIX"))
    ;
  elseif(findstr(buf(1:6), "SHEET"))
    ;
  elseif(findstr(buf(1:6), "TURN"))
    ;
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Secondary Structure");

# Parse the Connectivity Annotation Section

while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "SSBOND"))
    ;
  elseif(findstr(buf(1:6), "LINK"))
    ;
  elseif(findstr(buf(1:6), "HYDBND"))
    ;
  elseif(findstr(buf(1:6), "SLTBRG"))
    ;
  elseif(findstr(buf(1:6), "CISPEP"))
    ;
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Connectivity Annotation");

# Parse the Miscellaneous Features Section

while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "SITE"))
    ;
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Miscellaneous Features");

# Parse the Crystallographic and Coordinate Transformation Section 

while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "CRYST1"))
    a.cellsize = sscanf(buf(7:33), "%g", [3, 1]);
    a.cellangl = sscanf(buf(34:54), "%g", [3, 1]);
    a.sgroup = deblank(buf(56:66));    
    a.z = sscanf(buf(67:70), "%d");
  elseif(findstr(buf(1:6), "CRYST"))
    ;
  elseif(findstr(buf(1:6), "ORIGX"))
    ;
  elseif(findstr(buf(1:6), "SCALE1"))
    a.scalem = zeros(3,3);
    a.scalev = zeros(3,1);
    a.scalem(1,:) = sscanf(buf(11:40), "%g", [1, 3]);
    a.scalev(1) = sscanf(buf(46:55), "%g");
    buf = fgets(f);
    a.scalem(2,:) = sscanf(buf(11:40), "%g", [1, 3]);
    a.scalev(2) = sscanf(buf(46:55), "%g");
    buf = fgets(f);
    a.scalem(3,:) = sscanf(buf(11:40), "%g", [1, 3]);
    a.scalev(3) = sscanf(buf(46:55), "%g");
  elseif(findstr(buf(1:6), "SCALE"))
    ;
  elseif(findstr(buf(1:6), "MTRIX"))
    ;
  elseif(findstr(buf(1:6), "TVECT"))
    ;
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Crystallographic and Coordinate Transformation");

# Parse the Coordinate Section

while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:4), "ATOM"))
    j = 1;
    a.atomname = "    ";
    a.aresname = "   ";
    a.aresseq = 0;
    a.acoord = [0, 0, 0];
    a.aoccupancy = 0;
    a.atempfactor = 0;
#    a.az = 0;
    tmp = 0;
    while( (length(buf) >= 4) && findstr(buf(1:4), "ATOM"))
      sernro = sscanf(buf(7:11), "%d");
      if(sernro != j)
        warning("Something fishy with ATOM indices");
      endif
      a.atomname(j,:) = buf(13:16);
      # trick to make strtoz work correctly with atoms which have a two
      # letter abbreviation
      if(a.atomname(j,1) != " "),
        a.atomname(j,2) = tolower(a.atomname(j,2));
      endif
#      a.az(j) = strtoz(a.atomname(j,1:2));
      #  [tmp, err] = sscanf(buf(79), "%g");
      #  if(err == 1)
      #      if(buf(80) == "+")
      #          a.az(j) += tmp;
      #      elseif(buf(80) == "-")
      #          a.az(j) -= tmp;
      #      endif
      #  endif
      a.aresname(j,:) = buf(18:20);
      tmp = sscanf(buf(23:26), "%d");
      if(!isempty(tmp))
        a.aresseq(j) = tmp;
      else
        a.aresseq(j) = 1;
      endif
      a.acoord(j,:) = sscanf(buf(31:54), "%g", [1, 3]);
      tmp = sscanf(buf(55:60), "%g");
      if(!isempty(tmp))
        a.aoccupancy(j) = tmp;
      else
        a.aoccupancy(j) = 1;
      endif
      tmp = sscanf(buf(61:66), "%g");
      if(!isempty(tmp))
        a.atempfactor(j) = tmp;
      else
        a.atempfactor(j) = 1;
      endif
      buf = fgets(f);
      j++;
    endwhile
  elseif(findstr(buf(1:6), "HETATM"))
    j = 1;
    tmp = 0;
    a.hetname = "    ";
    a.hetresname = "   ";
    a.hetresseq = 0;
    a.hetcoord = [0, 0, 0];
    a.hetoccupancy = 0;
    a.hettempfactor = 0;
#    a.hetz = 0;
    while( (length(buf) >= 6) && findstr(buf(1:6), "HETATM"))
        sernro = sscanf(buf(7:11), "%d");
        #  if(sernro != j)
        #    warning("Something fishy with HETATM indices");
        #  endif
        a.hetname(j,:) = buf(13:16);
        # trick to make strtoz work correctly with atoms which have a two
        # letter abbreviation
        if(a.hetname(j,1) != " "),
          a.hetname(j,2) = tolower(a.hetname(j,2));
        endif
#        a.hetz(j) = strtoz(a.hetname(j,1:2));
#        [tmpcharge, err] = sscanf(buf(79), "%g");
#        if(err == 1)
#            if(buf(80) == "+")
#                a.hetz(j) += tmpcharge;
#            elseif(buf(80) == "-")
#                a.hetz(j) -= tmpcharge;
#            endif
#        endif        
      a.hetresname(j,:) = buf(18:20);
      tmp = sscanf(buf(23:26), "%d");
      if(!isempty(tmp))
        a.hetresseq(j) = tmp;
      else
        a.hetresseq(j) = 1;
      endif
      a.hetcoord(j,:) = sscanf(buf(31:54), "%g", [1, 3]);
      tmp = sscanf(buf(55:60), "%g");
      if(!isempty(tmp))
        a.hetoccupancy(j) = tmp;
      else
        a.hetoccupancy(j) = 1;
      endif
      tmp = sscanf(buf(61:66), "%g");
      if(!isempty(tmp))
        a.hettempfactor(j) = tmp;
      else
        a.hettempfactor(j) = 1;
      endif
      buf = fgets(f);
      j++;
    endwhile
  elseif(findstr(buf(1:6), "MODEL"))
    ;
  elseif(findstr(buf(1:6), "SIGATM"))
    ;
  elseif(findstr(buf(1:6), "ANISOU"))
    ;
  elseif(findstr(buf(1:6), "SIGUIJ"))
    ;  
  elseif(findstr(buf(1:6), "TER"))
    ;  
  elseif(findstr(buf(1:6), "ENDMDL"))
    ; 
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Coordinate");

# Parse the Connectivity Section

while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "CONECT"))
    ;
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Connectivity");

# Parse the Bookkeeping Section

while(true)
  if( feof(f) || (length(buf) < 6) ) 
    break;
  elseif(findstr(buf(1:6), "MASTER"))
    # Internal checks
    #numcoord = sscanf(buf(51:55), "%d");
    numseq = sscanf(buf(66:70), "%d");
    if(numseq != (floor(length(a.seqres)/13)+1))
      warning("SEQRES number in MASTER record doesn't match");
    endif
  elseif(findstr(buf(1:6), "END"))
    break;
  else
    break;
  endif
  buf = fgets(f);
endwhile
disp("Bookkeeping");

fclose(f);

endfunction
