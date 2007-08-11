## tics(axis,[pos1,pos2,...],['lab1';'lab2';...])
##
## Explicitly set the tic positions and labels for the given axis.
##
## If no positions or labels are given, then restore the default.
## If positions are given but no labels, use those positions with the
## normal labels.  If positions and labels are given, each position
## labeled with the corresponding row from the label matrix.
##
## Axis is 'x', 'y' or 'z'.

## This program is in the public domain
## Author: Paul Kienzle <pkienzle@users.sf.net>

## Modified to use new gnuplot interface in octave > 2.9.0
## Dmitri A. Sergatskov <dasergatskov@gmail.com>
## April 18, 2005

function tics(axis,pos,lab)
  t=upper(axis);
  if nargin == 1
    set (gca(), [t,"TickMode"], "auto");
  elseif nargin == 2
    set (gca(), [t, "Tick"], pos);
  elseif nargin == 3
    set (gca(), [t,"Tick"], pos);
    set (gca(), [t,"TickLabel"], lab);
  else
    usage("tics(axis,[pos1,pos2,...],['lab1';'lab2';...])");
  endif

endfunction
