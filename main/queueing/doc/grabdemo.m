## Copyright (C) 2005, 2006, 2007 David Bateman
## Modifications Copyright (C) 2009 Moreno Marzolla
##
## This file is part of qnetworks. It is based on the fntests.m
## script included in GNU Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

clear all;

global fundirs;

if (nargin == 1)
  xdir = argv(){1};
else
  xdir = "../inst/";
endif

srcdir = canonicalize_file_name (xdir);
fundirs = {srcdir};

function print_file_name (nm)
  filler = repmat (".", 1, 55-length (nm));
  printf ("  %s %s", nm, filler);
endfunction

function y = hasdemo (f)
  fid = fopen (f);
  str = fscanf (fid, "%s");
  fclose (fid);
  y = findstr (str, "%!demo");
endfunction

function dump_demo( fname, code, idx )
  if ( !idx) 
    return;
  endif
  printf("%d demos found\n", length(idx)-1 );
  [dd nn ee vv] = fileparts(fname);
  for i=2:length(idx)
    demoname = [ "demo_" num2str(i-1) "_" nn ".texi" ];
    fid = fopen( demoname, "wt" );
    fprintf(fid,"%s",code(idx(i-1)+1:idx(i)-1));
    fclose(fid);
  endfor
endfunction

for j=1:length(fundirs)
  d = fundirs{j};
  lst = dir (d);
  for i = 1:length (lst)
    nm = lst(i).name;
    if ((length (nm) > 3 && strcmp (nm((end-2):end), ".cc"))
	 || (length (nm) > 2 && strcmp (nm((end-1):end), ".m")))
      f = fullfile (d, nm);
      ## Only run if it contains %!demo
      if (hasdemo (f))
	tmp = strrep (f, [srcdir, "/"], "");
	print_file_name (tmp);
	[code, idx] = test (f, "grabdemo" );
        dump_demo( nm, code, idx );
      endif
    endif
  endfor 
endfor
