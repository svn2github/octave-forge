## Copyright (C) 1999 Daniel Heiserer
##
## This program is free software; it is distributed in the hope that it
## will be useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
## the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file; see the file COPYING.  If not, write to the
## Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## usage:  m = gget(option)
##
## returns gnuplot's setting of option.
##
## REQUIRES: unix piping functionality, grep, sed
## COMMENT: would be much better to have the result directly from gnuplot,
##          but show/gshow deliver a human readable format, which cannot
##          be read by a machine clearly
##

## Author: Daniel Heiserer <Daniel.heiserer@physik.tu-muenchen.de>

## 2001-03-30 Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##     * strip spaces
##     * use proper temporary files
## 2001-04-04 Laurent Mazet <mazet@crm.mot.com>
##     * check if gnuplot very create a file

function gout = gget(option)

  ## tell gnuplot to save all its options to a file, scan that file
  ## for the option we are interested in, then delete it.
  optfile = tmpnam;
  graw (["save set \"", optfile, "\"\n"]);
  f = fopen(optfile);
  while f == -1
    sleep (1);
    f = fopen(optfile);
  endwhile
  fclose(f);
  
  cmd = sprintf("grep \"[# ]*set %s\" %s | sed 's/.*set %s *//'; rm -f %s", ...
		option, optfile, option, optfile);
  gout = system(cmd);
  if (length(gout) == 0) 
    error("gget: option %s not found", option);
  endif

  ## grab the first output line only, without newline
  ## XXX FIXMEXXX --- some options (e.g., key) may return multiple lines
  ## since the real options are actually "key title" and "key".  Tricky...
  idx = find(gout == "\n");
  if !isempty(idx)
    gout = gout(1:idx(1)-1); 
    if (length(gout) == 0) return; endif
  endif

  ## strip leading and trailing blanks
  idx = find(gout != " ");
  if isempty(idx)
    gout = "";
  else
    gout = gout(min(idx) : max(idx));
  endif

endfunction
