function write_pdb_quick(p, fname)
#function write_pdb_quick(p, fname)
#
# Writes (only) the atomic coordinates from pdb struct p 
# (see read_pdb.m) to a pdb-file fname

## Created: 3.8.2001
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>


if(!is_struct(p)) # || !struct_contains(p, "acoord"))
    error("p must be a pdb struct");
endif

[f, err] = fopen(fname, "w");
if(f < 0)
    error("Could not open output file: %s", err);
endif

buf = blanks(80);

if(struct_contains(p, "acoord"))
  natoms = size(p.acoord, 1);
  if(struct_contains(p, "atomname"))
    atomname = toupper(p.atomname);
  else
    for i = 1:natoms,
      atomname(i, :) = "    ";
    endfor
  endif
  if(struct_contains(p, "aresname"))
    aresname = toupper(p.aresname);
  else
    for i = 1:natoms,
      aresname(i, :) = "   ";
    endfor
  endif
  if(struct_contains(p, "aresseq"))
    aresseq = p.aresseq;
  else
    aresseq = ones(natoms, 1);
  endif
  if(struct_contains(p, "aoccupancy"))
    aoccupancy = p.aoccupancy;
  else
    aoccupancy = ones(natoms, 1);
  endif
  if(struct_contains(p, "atempfactor"))
    atempfactor = p.atempfactor;
  else
    atempfactor = zeros(natoms, 1);
  endif
  
  j = 1;
  while(j <= natoms)
    buf = blanks(80);
    buf(1:6)   = "ATOM  ";
    buf(7:11)  = sprintf("%5d", j);
    buf(13:16) = sprintf("%4s", atomname(j,:));
    buf(18:20) = aresname(j,:);
    buf(23:26) = sprintf("%4d", aresseq(j));
    buf(31:54) = sprintf(" %7.3f %7.3f %7.3f", p.acoord(j,:));
    buf(55:60) = sprintf(" %5.2f", aoccupancy(j,:));
    buf(61:66) = sprintf("%6.2f", atempfactor(j,:));
    buf(77:78) = sprintf("%s", atomname(j,1:2));
    buf(80) = "\n";
    fprintf(f, "%s", buf);
    j++;
  endwhile

  buf = blanks(80);
  buf(1:6)   = "TER   ";
  buf(7:11)  = sprintf("%5d", j);
  buf(18:20) = aresname(natoms, :);
  buf(23:26) = sprintf("%4d", aresseq(natoms));
  buf(80) = "\n";
  fprintf(f, "%s", buf);
  j++;
endif

if(struct_contains(p,"hetcoord")) 
  nhet = size(p.hetcoord, 1);
  if(struct_contains(p, "hetname"))
    hetname = toupper(p.hetname);
  else
    for i = 1:nhet
      hetname(i, :) = "    ";
    endfor
  endif
  if(struct_contains(p, "hetresname"))
    hetresname = toupper(p.hetresname);
  else
    for i = 1:nhet,
      hetresname(i, :) = "   ";
    endfor
  endif
  if(struct_contains(p, "hetresseq"))
    hetresseq = p.hetresseq;
  else
    hetresseq = ones(nhet, 1);
  endif
  if(struct_contains(p, "hetoccupancy"))
    hetoccupancy = p.hetoccupancy;
  else
    hetoccupancy = ones(nhet, 1);
  endif
  if(struct_contains(p, "hettempfactor"))
    hettempfactor = p.hettempfactor;
  else
    hettempfactor = zeros(nhet, 1);
  endif

  i = 1;
  while(i <= nhet)
    buf = blanks(80);
    buf(1:6)   = "HETATM";
    buf(7:11)  = sprintf("%5d", j);
    buf(13:16) = sprintf("%s", hetname(i,:));
    buf(18:20) = hetresname(i, :);
    buf(23:26) = sprintf("%4d", hetresseq(i));
    buf(31:54) = sprintf(" %7.3f %7.3f %7.3f", p.hetcoord(i,:));
    buf(55:60) = sprintf(" %5.2f", hetoccupancy(i,:));
    buf(61:66) = sprintf("%6.2f", hettempfactor(i,:));
    buf(80) = "\n";
    fprintf(f, "%s", buf);
    i++;
    j++;
  endwhile
endif

buf = blanks(80);
buf(1:6) = "END   ";
buf(80) = "\n";
fprintf(f, "%s", buf);

fclose(f);

endfunction
