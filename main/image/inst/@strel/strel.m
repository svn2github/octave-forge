## Copyright (C) 2012 Roberto Metere <roberto@metere.it>
## Copyright (C) 2012 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} strel (@var{shape}, @var{parameters})
## Create a strel (structuring element) object for morphology operations.
##
## The structuring element can have any type of shape as specified by
## @var{shape}, each one with its @var{parameters}.
##
## @deftypefnx {Function File} {} strel ("arbitrary", @var{nhood})
## @deftypefnx {Function File} {} strel ("arbitrary", @var{nhood}, @var{height})
## Create arbitrary shaped structuring elements.
##
## @var{nhood} must be a matrix of 0's and 1's.  Any number with of dimensions
## are possible.  To create a non-flat SE, the @var{height} can be specified.
## See individual functions that use the strel object for an interpretation of
## non-flat SEs.
##
## Note that if an arbitrary shape is used, it will not be possible to perform
## structuring element decomposition which may have a performance hit in some
## cases.  See for example the difference for a square shape:
## @example
## @group
## im = randp (5, 2000) > 15;
## se = strel ("square", 20);
## t = cputime (); imdilate (im, se); cputime () - t
##     @result{} 0.77605
## se = strel (ones (20));
## t = cputime (); imdilate (im, se); cputime () - t
##     @result{} 2.9082
## @end group
## @end example
##
## @deftypefnx {Function File} {} strel ("cube", @var{edge})
## Create cube shaped @var{flat} structuring element.  @var{edge} must be a
## positive integer that specifies the length of its edges.  This shape meant to
## perform morphology operations in volumes, see the square shape for 2
## dimensional images.
##
## @deftypefnx {Function File} {} strel ("diamond", @var{radius})
## Create diamond shaped flat structuring element.  @var{radius} must be a
## positive integer.
##
## @deftypefnx {Function File} {} strel ("disk", @var{radius})
## Create disk shaped flat structuring element.  @var{radius} must be a positive
## integer.
##
## @deftypefnx {Function File} {} strel ("octagon", @var{apothem})
## Create octagon shaped flat structuring element.  @var{apothem} must be a
## positive integer that specifies the distance from the origin to the sides of
## the octagon.
##
## @deftypefnx {Function File} {} strel ("pair", @var{offset})
## Creates a flat structuring element with two members.  One member is placed
## at the origin while the other is placed with @var{offset} in relation to the
## origin.  @var{offset} must then be a 2 element vector for the coordinates.
##
## @deftypefnx {Function File} {} strel ("rectangle", @var{dimensions})
## Creates a rectangular shaped flat structuring element.  @var{dimensions} must
## be a two element vector of positive integers with the number of rows and
## columns of the rectangle.
##
## @deftypefnx {Function File} {} strel ("square", @var{edge})
## Create square shaped flat structuring element.  @var{edge} must be a positive
## integer that specifies the length of its edges.  For use in volumes, see the
## cube shape.
##
## The actual structuring element neighborhood, the logical matrix used for the
## operations, can be accessed with the @code{getnhood} method.  However, most
## morphology functions in the image package will have an improved performance
## if the actual strel object is used, and not its element neighborhood.
##
## @example
## @group
## se = strel ("square", 5);
## getnhood (se)
##     @result{}
##         1  1  1  1  1
##         1  1  1  1  1
##         1  1  1  1  1
##         1  1  1  1  1
##         1  1  1  1  1
## @end group
## @end example
##
## @seealso{imdilate, imerode}
## @end deftypefn

function SE = strel (shape, varargin)

  if (nargin < 1 || nargin > 4 || (! ischar (shape) && ! ismatrix (shape)))
    print_usage;
  endif

  if (! ischar (shape))
    varargin(2:end+1) = varargin(:);
    varargin(1) = shape;
    shape = "arbitrary";
  endif

  ## because the order that these are created matters, we make them all here
  SE        = struct;
  SE.shape  = tolower (shape);
  SE.nhood  = false;
  SE.flat   = true;
  SE.height = [];
  SE.seq    = cell;
  SE.opt    = struct;

  switch (SE.shape)
    case "arbitrary"
      if (numel (varargin) == 1)
        nhood   = varargin{1};
        SE.flat = true;
      elseif (numel (varargin) == 2)
        nhood     = varargin{1};
        SE.height = varargin{2};
        SE.flat   = false;
      else
        error ("strel: an arbitrary shape takes 1 or 2 arguments");
      endif
      if (! isbw (nhood, "non-logical"))
        error ("strel: NHOOD must be a matrix with only 0 and 1 values")
      endif

      SE.nhood = logical (nhood); # we need this as logical for the height tests

      if (! SE.flat && ! (isnumeric (SE.height) && isreal (SE.height) &&
                          ndims (SE.height) == ndims (nhood)          &&
                          all (size (SE.height) == size (nhood))      &&
                          all (isfinite (SE.height(:)))))
        error ("strel: HEIGHT must be a finite real matrix of the same size as NHOOD");
      endif

#    case "ball"
      ## TODO implement ball shape

    case "cube"
      if (numel (varargin) == 1)
        SE.opt.edge = varargin{1};
      else
        error ("strel: no EDGE specified for cube shape");
      endif
      if (! is_positive_integer (SE.opt.edge))
        error ("strel: EDGE value must be positive integers");
      endif

      SE.nhood = true (SE.opt.edge, SE.opt.edge, SE.opt.edge);
      SE.flat  = true;

    case "diamond"
      if (numel (varargin) == 1)
        radius = varargin{1};
      else
        error ("strel: no RADIUS specified for diamond shape");
      endif
      if (! is_positive_integer (radius))
        error ("strel: RADIUS must be a positive integer");
      endif

      corner   = tril (true (radius+1, radius), -1);
      SE.nhood = [rot90(tril(true(radius+1))) corner;
                  corner' rot90(triu(true(radius),1))];
      SE.flat  = true;

    case "disk"
      if (numel (varargin) == 1)
        radius = varargin{1};
      else
        ## TODO implement second option for number of periodic lines
        error ("strel: no RADIUS specified for disk shape");
      endif
      if (! is_positive_integer (radius))
        error ("strel: RADIUS must be a positive integer");
      endif

      SE.nhood = fspecial ("disk", radius) > 0;
      SE.flat  = true;

#    case "line"
      ## TODO implement line shape

   case "octagon"
      if (numel (varargin) == 1)
        apothem = varargin{1};
      else
        error ("strel: no APOTHEM specified for octagon shape");
      endif
      if (! is_positive_integer (apothem) || mod (apothem, 3) != 0)
        error ("strel: APOTHEM must be a positive integer multiple of 3");
      endif

      ## we look at it as 9 blocks. North AND South are the same and West TO
      ## East as well. We make the corner for NorthEast and rotate it for the
      ## other corners
      cwide    = apothem/3*2 + 1;
      iwide    = apothem/3*2 - 1;
      N_and_S  = true ([cwide iwide]);
      corner   = tril (true (cwide));
      SE.nhood = [rotdim(corner), N_and_S, corner;
                  true([iwide (2*apothem + 1)]);
                  transpose(corner), N_and_S, rotdim(corner, -1)];
      SE.flat  = true;

    case "pair"
      if (numel (varargin) == 1)
        offset = varargin{1};
      else
        error ("strel: no OFFSET specified for pair shape");
      endif
      if (! ismatrix (offset) || numel (offset) != 2 || ! isnumeric (offset))
        error ("strel: OFFSET must be a 2 element vector");
      elseif (any (fix (offset) != offset))
        error ("strel: OFFSET values must be integers");
      endif

      lengths  = abs (2*offset) + 1;
      SE.nhood = false (lengths);
      origin   = (lengths + 1)/2;
      SE.nhood(origin(1), origin(2)) = true;
      SE.nhood(origin(1) + offset(1), origin(2) + offset(2)) = true;

      SE.flat = true;

    case "periodicline"
      ## TODO implement periodicline shape

    case "rectangle"
      if (numel (varargin) == 1)
        SE.opt.dimensions = varargin{1};
      else
        error ("strel: no DIMENSIONS specified for rectangle shape");
      endif
      if (! ismatrix (SE.opt.dimensions) || numel (SE.opt.dimensions) != 2 ||
          ! isnumeric (SE.opt.dimensions))
        error ("strel: DIMENSIONS must be a 2 element vector");
      elseif (! is_positive_integer (SE.opt.dimensions(1)) ||
              ! is_positive_integer (SE.opt.dimensions(2)))
        error ("strel: DIMENSIONS values must be positive integers");
      endif

      SE.nhood = true (SE.opt.dimensions);
      SE.flat  = true;

    case "square"
      if (numel (varargin) == 1)
        SE.opt.edge = varargin{1};
      else
        error ("strel: no EDGE specified for square shape");
      endif
      if (! is_positive_integer (SE.opt.edge))
        error ("strel: EDGE value must be positive integers");
      endif

      SE.nhood = true (SE.opt.edge);
      SE.flat  = true;

    otherwise
      error ("strel: unknown SHAPE `%s'", shape);
  endswitch

  SE = class (SE, "strel");
endfunction

function retval = is_positive_integer (val)
  retval = isscalar (val) && isnumeric (val) && val > 0 && fix (val) == val;
endfunction

%!shared shape, height
%! shape  = [0 0 0 1];
%!assert (getnhood (strel (shape)), logical (shape));
%!assert (getnhood (strel ("arbitrary", shape)), logical (shape));
%! height = [0 0 0 3];
%!assert (getnhood (strel ("arbitrary", shape, height)), logical (shape));
%!assert (getheight (strel ("arbitrary", shape, height)), height);
%! shape = [0 0 1];
%! height = [-2 1 3];  ## this works for matlab compatibility
%!assert (getnhood (strel ("arbitrary", shape, height)), logical (shape));
%!assert (getheight (strel ("arbitrary", shape, height)), height);
%! shape = [0 0 0 1 0 0 0
%!          0 0 1 1 1 0 0
%!          0 1 1 1 1 1 0
%!          1 1 1 1 1 1 1
%!          0 1 1 1 1 1 0
%!          0 0 1 1 1 0 0
%!          0 0 0 1 0 0 0];
%!assert (getnhood (strel ("diamond", 3)), logical (shape));
%! shape = [0 0 0 1 0 0 0
%!          0 1 1 1 1 1 0
%!          0 1 1 1 1 1 0
%!          1 1 1 1 1 1 1
%!          0 1 1 1 1 1 0
%!          0 1 1 1 1 1 0
%!          0 0 0 1 0 0 0];
%!assert (getnhood (strel ("disk", 3)), logical (shape));
%! shape = [0 0 1 1 1 0 0
%!          0 1 1 1 1 1 0
%!          1 1 1 1 1 1 1
%!          1 1 1 1 1 1 1
%!          1 1 1 1 1 1 1
%!          0 1 1 1 1 1 0
%!          0 0 1 1 1 0 0];
%!assert (getnhood (strel ("octagon", 3)), logical (shape));
%! shape = [1;1;0];
%!assert (getnhood (strel ("pair", [-1 0])), logical (shape));
%! shape = [1 0 0 0 0 0 0
%!          0 0 0 1 0 0 0
%!          0 0 0 0 0 0 0];
%!assert (getnhood (strel ("pair", [-1 -3])), logical (shape));
%! shape = [0 0 0 0 0 0 0
%!          0 0 0 0 0 0 0
%!          0 0 0 1 0 0 0
%!          0 0 0 0 0 0 0
%!          0 0 0 0 0 0 1];
%!assert (getnhood (strel ("pair", [2 3])), logical (shape));
%!assert (getnhood (strel ("rectangle", [10 5])), true (10, 5));
%!assert (getnhood (strel ("square", 5)), true (5));

## test how @strel/getsequence and indexing works fine
%!shared se, seq
%! se = strel ("square", 5);
%! seq = getsequence (se);
%!assert (class (se(1)),  "strel")
%!assert (class (se(1,1)),"strel")
%!assert (class (seq),    "strel")
%!assert (class (seq(1)), "strel")
%!assert (class (seq(2)), "strel")
%!assert (numel (se), 1)
%!assert (numel (seq), 2)
%!error se(2);
%!error seq(3);

## test reflection
%!shared se, ref
%! se = strel ("arbitrary", [1 0 0; 1 1 0; 0 1 0], [2 0 0; 3 1 0; 0 3 0]);
%! ref = reflect (se);
%!assert (getnhood (ref), logical([0 1 0; 0 1 1; 0 0 1]));
%!assert (getheight (ref), [0 3 0; 0 1 3; 0 0 2]);

## test input validation
%!error strel()
%!error strel("nonmethodthing", 2)
%!error strel("arbitrary", "stuff")
%!error strel("arbitrary", [0 0 1], [2 0 1; 4 5 1])
%!error strel("arbitrary", [0 0 1], "stuff")
%!error strel("diamond", -3)
%!error strel("disk", -3)
%!error strel("octagon", 4)
%!error strel("pair", [45 67 90])
%!error strel("rectangle", 2)
%!error strel("rectangle", [2 -5])
%!error strel("square", [34 1-2])
