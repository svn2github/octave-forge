## Author: Paul Kienzle <pkienzle@users.sf.net>
## Author: Dmitri A. Sergatskov <dasergatskov@gmail.com>
## Author: Russel Valentine
## Author: Peter Gustafson
## This program is granted to the public domain.

## -*- texinfo -*-
## @deftypefn {Function File} {} tics (@var{axis}, [@var{pos1}, @var{pos2}, @dots{}], [@var{lab1}, @var{lab2}, @dots{}],)
## Explicitly set the tic positions and labels for the given axis.
##
## @var{axis} must be 'x', 'y' or 'z'.
##
## If no positions or labels are given, then restore the default.
## If positions are given but no labels, use those positions with the
## normal labels. If positions and labels are given, each position
## labeled with the corresponding row from the label matrix.
##
## @end deftypefn

function tics (axis, pos, lab)

  if ( nargin < 1 || nargin > 3 )
    print_usage;
  endif

  t = lower (axis);
  if (t ~= "x" && t ~= "y" && t ~= "z")
    error ("First input argument must be one of 'x', 'y' or 'z'");
  endif

  if (nargin == 1)
    set (gca(), [t, "tick"], []);
    set (gca(), [t, "tickmode"], "auto");
    set (gca(), [t, "ticklabel"], "");
    set (gca(), [t, "ticklabelmode"], "auto");
  elseif (nargin == 2)
    set (gca(), [t, "tick"], pos);
    set (gca(), [t, "ticklabel"], "");
    set (gca(), [t, "ticklabelmode"], "auto");
  elseif (nargin == 3)
    set (gca(), [t, "tick"], pos);
    set (gca(), [t, "ticklabel"], lab);
  else
    ## we should never get here anyway
    print_usage;
  endif

endfunction
