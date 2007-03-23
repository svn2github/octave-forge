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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

#function plotpdb(pdb)
#    
# Visualizes a pdb-file or a pdb-struct with rasmol.

## Created: 3.8.2001
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>

# FIXME: redirecting input for rasmol works by opening a free pseudo-tty
# which isn't (hopefully) attached to anything. Is there a better way?

function plotpdb(pdb)


RASMOL = [tilde_expand(fileparts(mfilename("fullpath"))) "/bin/rasmol.sh"];

ptybase = "/dev/ptyz";
startno = toascii("0");

# This is a hack to get a static -like variable in the function
#global plotpdb_static_ptynum;
#if (! exist ("plotpdb_static_ptynum"))
#    plotpdb_static_ptynum = startno - 1;
#endif

# FIXME: this allows only ten rasmol windows open at one moment
plotpdb_static_ptynum = startno - 1;
do
    ++plotpdb_static_ptynum;
    ptyname = sprintf("%s%c", ptybase, plotpdb_static_ptynum);
    ptyfid = fopen(ptyname, "r");
until(ptyfid > 0)
fclose(ptyfid);

#++plotpdb_static_ptynum;
#ptyname = sprintf("%s%c", ptybase, plotpdb_static_ptynum)

if(isstr(pdb))
    fname = pdb;
    [forkstat, fmsg] = fork();
    if(forkstat == 0),
      exec_args = [fname; ptyname];
      exec(RASMOL, exec_args);
      exit;
    elseif(forkstat < 0)
      error(fmsg);
    endif	
elseif(is_struct(pdb))
    fname = tmpnam;
    write_pdb(pdb, fname, true);
    [forkstat, fmsg] = fork();
    if(forkstat == 0),        
        exec_args = [fname; ptyname];
        exec(RASMOL, exec_args);
        exit;
    elseif(forkstat < 0)
        error(fmsg);
    endif	
else
    error("pdb must be a valid pdb-struct or a file name");
endif

endfunction
