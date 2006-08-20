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

  if nargin == 1
    cmd = ["set ", axis, "tics autofreq;\n"];
    __gnuplot_raw__ (cmd);
  elseif nargin == 2
    tics = sprintf(' %g,', pos);
    tics(length(tics)) = ' ';
    cmd = ["set ", axis, "tics (", tics, ");\n"];
    __gnuplot_raw__ (cmd);
  elseif nargin == 3
    tics = sprintf('"%s" %g', deblank(lab(1,:)), pos(1));
    for i=2:rows(lab)
      tics = [tics, sprintf(', "%s" %g', deblank(lab(i,:)), pos(i)) ];
    endfor
    cmd = [ "set ", axis, "tics (", tics ,");\n"];
    __gnuplot_raw__ (cmd);
  else
    usage("tics(axis,[pos1,pos2,...],['lab1';'lab2';...])");
  endif

endfunction
