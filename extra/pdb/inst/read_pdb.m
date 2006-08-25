## Copyright (C) 2001-2004 Teemu Ikonen 
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#function p = read_pdb(fname)
#
# Read a protein databank file from fname to a structure p containing 
# some of the elements below:
#
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
# p.az             = Number of electrons, Z, of the atoms (N x 1 matrix) 
# p.hetname        = Names of the heterogen atoms (N x 4 char matrix)
# p.hetresname     = Name of the heterogen residue (N x 3 char matrix)
# p.hetresseq      = Heterogen residue sequence number (N x 1 matrix)   
# p.hetcoord       = Coordinates of the heterogen atoms (N x 3 matrix)
# p.hetoccupancy   = Occupancy of the heterogen atoms (N x 1 matrix) 
# p.hettempfactor  = Temperature factors of the hetatoms (N x 1 matrix) 
# p.hetz           = Number of electrons, Z, of the hetatoms (N x 1 matrix) 
# 
# NOTE: This function also returns the atomic numbers of the atoms in the
# structure (fields p.az and p.hetz), if you do not need this information,
# use the faster function creadpdb.oct

## Created: 3.8.2001
## Rewritten: 8.10.2003 
## Rewritten to use the .oct function creadpdb: 20.4.2004
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>

function p = read_pdb(fname)
p = creadpdb(fname);

global elements_struct;
load("-force", file_in_loadpath("elements_struct.mat"));

if(struct_contains(p, "atomname"))
   p.az = atomnames_to_z(p.atomname);
endif

if(struct_contains(p, "hetname"))
   p.hetz = atomnames_to_z(p.hetname);
endif

function z = atomnames_to_z(n)
  global elements_struct;
  N = size(n, 1);
  z = zeros(N, 1);
  for i = 1:N,
    # Heuristics to decipher the element from atomname
    tmpnam = n(i,isalpha(n(i,:)));
    if (isfield(elements_struct, tmpnam(1)))
      z(i) = elements_struct.(tmpnam(1));
    elseif (length(tmpnam) > 1)
      tmpnam(2) = tolower(tmpnam(2));
      z(i) = elements_struct.(tmpnam(1:2));
    else
      error("Element %s not found", tmpnam);
    endif
  endfor
endfunction
 
endfunction
