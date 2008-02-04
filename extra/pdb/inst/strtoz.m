## Copyright (C) 2000-2004 Teemu Ikonen
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

#function [Z,w] = strtoz(s)
#
# Return atomic numbers Z and the corresponding number of elements w  
# in the compound.
# Input s is either a string containing the name of the
# compound or the atomic number Z.
# If s is a string matrix the compounds are read rowwise and the outputs
# Z and w are matrices whose rows correspond to the compounds read from 
# the rows of s.
# 
# in:
# s = string containing the stoichiometry of the compound (eg. AlO3)
#     or atomic number Z
# out:
# Z = vector containing the atomic numbers of the elements in compound s
# w = number atoms of each element Z of the compound

# Orig. by Veijo Honkimaki
# Modified to work with GNU Octave by Teemu Ikonen 7.4.2000
# Modified to work with string matrices 6.8.2001 - Teemu
# Add support for > 9 stoichiometries, 
# speedup with data in a structure 21.4.2004 - Teemu

function [Z,w] = strtoz(s)

if(ischar(s))
  tabfile = file_in_loadpath("elements_struct.mat");
  load("-force", tabfile);
  
  N = size(s, 1);
  #    m = size(s, 2);
  Z = zeros(N, 1); 
  w = zeros(N, 1);
  for p = 1:N,
    r = deblank(s(p,:));
    L = length(r);
    k = 1;
    component = 1;
    while(k <= L)
      while(r(k) == " ")
        k++;
      endwhile
      f = "";
      f(1) = r(k++); 
      if (k <= L) && islower(r(k)),
        f(2) = r(k++); 
      end;
      if (k <= L) && isdigit(r(k)),
        [m,i] = sscanf(r(k:end), "%d", 1);
        while((k <= L) && isdigit(r(k)))
          k++;
        endwhile
      else 
        m = 1; 
      end;
      Z(p,component) = elements_struct.(f);
      w(p,component) = m;
      component++;
    endwhile
  endfor
elseif(isreal(s))
  Z = s; 
  w = ones(size(Z));
else
  error("s must be either string or real");
endif

endfunction        
