## Copyright (C) 2012 Philip Nienhuis <prnienhuis@users.sf.net>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## chk_jar_entries - internal function finding Java .jar names in javaclasspath

## Author: Philip <Philip@DESKPRN>
## Created: 2012-10-07

function [ retval, missing ] = chk_jar_entries (jcp, entries, dbug=0)

  retval = 0;
  missing = zeros (1, numel (entries));
  for jj=1:length (entries)
    found = 0;
    for ii=1:length (jcp)
      ## Get jar (or folder/map/subdir) name from java classpath entry
      jentry = strsplit (lower (jcp{ii}), filesep){end};
      if (~isempty (strfind (jentry, lower (entries{jj}))))
        ++retval; 
        found = 1;
        if (dbug > 2)
          fprintf ('  - %s OK\n', jentry); 
        endif
      endif
    endfor
    if (~found)
      if (dbug > 2)
        printf ('  %s....jar missing\n', entries{jj});
      endif
      missing(jj) = 1;
    endif
  endfor

endfunction
