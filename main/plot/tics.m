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

function tics(axis,pos,lab)

  if nargin == 1
    eval(["gset ", axis, "tics autofreq"]);
  elseif nargin == 2
    tics = sprintf(' %g,', pos);
    tics(length(tics)) = ' ';
    eval(["gset ", axis, "tics (", tics, ")"]);
  elseif nargin == 3
    tics = sprintf('"%s" %g', deblank(lab(1,:)), pos(1));
    for i=2:rows(lab)
      tics = [tics, sprintf(', "%s" %g', deblank(lab(i,:)), pos(i)) ];
    endfor
    eval([ "gset ", axis, "tics (", tics ,")" ]);
  else
    usage("tics(axis,[pos1,pos2,...],['lab1';'lab2';...])");
  endif

endfunction
