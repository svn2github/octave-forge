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
## COMMENT: would be much better to have the result directly from gnuplot,
##          but show/gshow deliver a human readable format, which cannot
##          be read by a machine clearly
##
## Does not properly handle options which are repeated.
## Does not properly handle options which are set to "nooption"
## Actual option settings depend on the installed version of gnuplot

## Author: Daniel Heiserer <Daniel.heiserer@physik.tu-muenchen.de>

## 2003-03-13 Teemu Ikonen <tpikonen@pcu.helsinki.fi>
##     * kind of fixed a race condition with gnuplot and octave processes
## 2003-03-04 Teemu Ikonen <tpikonen@pcu.helsinki.fi>
##     * got rid of grep and sed, now parses with octave
##     * can read options whose values are longer than ~70 characters
##       (ie. span more than one line in the optfile)
## 2001-03-30 Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##     * strip spaces
##     * use proper temporary files
## 2001-04-04 Laurent Mazet <mazet@crm.mot.com>
##     * check if gnuplot very create a file
## 2001-12-07 Paul Kienzle <pkienzle@users.sf.net>
##     * silently return "" if option is not found

function gout = gget(option)

  ## tell gnuplot to save all its options to a file, scan that file
  ## for the option we are interested in, then delete it.
  optfile = tmpnam;
  graw (["save set \"", optfile, "\"\n"]);  
  rmcmd = sprintf("rm -f %s", optfile);

  # FIXME:
  # this (tries) to prevent a race condition where the file exists,
  # but is not yet completely written. This is a stupid hack.
  # Limit is 10 seconds of waiting.  This may not be enough in windows,
  # but that's moot since windows gget doesn't seem to work.
  count=0;
  while (f = fopen(optfile)) == -1
    sleep (0.5);
    if count++>20, error("gnuplot not responding"); endif
  endwhile
  
  while fseek(f, -9, SEEK_END) || ~strcmp('#    EOF', fgetl(f))
    sleep (0.5);
    if count++>20, break; endif
  endwhile
  fseek(f, 0);

  gout = "";
  s = strcat("set ", option, " ");
  buf = blanks(80);
  idx = [];
  buf = fgetl(f);
  while(!feof(f))
    idx = findstr(s, buf);
    if(!isempty(idx))
      break;
    endif
    buf = fgetl(f);
  endwhile
  
  if(feof(f) || isempty(gout = buf((idx + length(s)):end)))
    fclose(f);
    system(rmcmd);
    return
  endif

  while(gout(end) == '\\')
    buf = fgetl(f);
    idx = find(buf != " ");
    if isempty(idx)
      buf = "";
    else
      buf = buf(min(idx) : max(idx));
    endif
    gout = strcat(gout(1:(end-1)), buf);
  endwhile
  fclose(f);
  system(rmcmd);

endfunction
