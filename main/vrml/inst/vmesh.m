## Copyright (C) 2002 Etienne Grossmann.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##

## s = vmesh (x, y, z [, options] ) - Visualize a 3D surface
## s = vmesh (z [, options] )
##
## Visualizes a 3D surface. Returns the VRML code.
##
## x : RxC or C  : X coordinates of the points on the surface
## y : RxC or R  : Y "                                      "
## z : RxC       : Z "                                      "
##
## s :   string  : The code
##
## If x and y are omitted, they are assumed to be linspace(-1,1,C or R).
## Points presenting one or more 'inf' or 'nan' coordinates are ignored.
##
## Options : (all options of vrml_surf may be used too)
##
## "col" , col  : 3      : RGB Color,                Default = [0.3,0.4,0.9]
##             or 3x(R*C): Color of vertices (vrml colorPerVertex is TRUE).
##             or 3x((R-1)*(C-1))
##                       : Color of facets
##             or 1      : Reflectivity (equivalent to [col,col,col] in RGB)
##             or R x C  : Reflectivity of vertices
##             or 1x(R*C)
##             or (R-1)x(C-1)
##             or (R-1)*(C-1)
##                       : Reflectivity of facets.
##
## "checker", c : 1x2 : Color as a checker. If c(1) is positive, checker has
##                      c(1) rows. If it is negative, each checker row is
##                      c(1) facets high. c(2) does the same for columns.
##             or 1x1 : Same as [c,c].
##
## "zgray"            : Color varies from black for lowest point to white
##                      for highest.
##
## "zrb"              : Color varies from blue for lowest point to red for
##                      highest.
##
## "zcol", zcol : Mx3 : Color is linearly interpolated between the RGB
##                      values specified by the rows of zcol.
##
##        RGB and reflectivity values should be in the [0,1] interval.
##
## "level", l   : 1xN : Display one or more horizontal translucent plane(s)
##
##                        z == l(i)   (1 <= i <= length(l))
## 
## "lcol", lc   : Nx3 : Color of the plane(s).          Default = [.7 .7 .7]
## "ltran",lt   : Nx1 : Transparency of the plane(s).   Default =        0.3
##
## See also: vrml_surf(), vrml_faces(), demo("vmesh")

## Author:        Etienne Grossmann <etienne@cs.uky.edu>

function s = vmesh (x, y, z, varargin)

level = [];
lcol = [7 7 7]/10;
ltran = 0.3;

if (nargin <= 1) || ischar(y),	# Cruft to allow not passing x and y
  zz = x ;
  [R,C] = size (zz);
  [xx,yy] = meshgrid (linspace (-1,1,C), linspace (-1,1,R)); 

  if     nargin >=3,
    s = vmesh ( xx, yy, zz, y, z, varargin{:} );
    if ! nargout,  clear s; end;  return
  elseif nargin >=2,
    s = vmesh ( xx, yy, zz, y, varargin{:} );
    if ! nargout,  clear s; end;  return
  end
  x = xx ; y = yy ; z = zz ;
end


frame = 1;

## surf_args = list (x,y,z);	# Arguments that'll be passed to vrml_surf
surf_args = {x,y,z};	# Arguments that'll be passed to vrml_surf

if nargin > 3,

  op1 = [" tran col checker creaseAngle emit colorPerVertex tex zcol",\
	 " level lcol ltran "];
  op0 = " smooth zgrey zrb ";

  df = tars (level, lcol, ltran);

  opts = read_options (varargin,"op0",op0,"op1",op1,"default",df);

				# Identify options for vrml_surf()
#   all_surf_opts  = list ("tran", "col", "checker", "creaseAngle", "emit", \
# 			 "colorPerVertex", "smooth", "tex",\
# 			 "zgrey","zrb","zcol");
  all_surf_opts  = {"tran", "col", "checker", "creaseAngle", "emit", \
		    "colorPerVertex", "smooth", "tex",\
		    "zgrey","zrb","zcol"};

  for i = 1:length(all_surf_opts)
    ## optname = nth (all_surf_opts, i);
    optname = all_surf_opts{i};
    if struct_contains (opts, optname)
      ## surf_args = append (surf_args, list (optname));
      surf_args{length(surf_args)+1} = optname;
      if index (op1,[" ",optname," "])
	## surf_args = append (surf_args, list(opts.(optname)));
	surf_args{length(surf_args)+1} = opts.(optname);
      end
    end
  end
  level = opts.level;
  ltran = opts.ltran;
  lcol  = opts.lcol;
end

## s = leval ("vrml_surf", surf_args);
s = feval ("vrml_surf", surf_args{:});

pts = [x(:)';y(:)';z(:)'];
ii = find (all (isfinite (pts)));
pt2 = pts(:,ii); x2 = x(:)(ii); y2 = y(:)(ii); z2 = z(:)(ii);
## Addd a point light
scl = nanstd ((pt2-mean (pt2')'*ones(1,columns (pt2)))(:));

lpos = [(min(x2) - 1.1*scl* max(max(x2)-min(x2), 1)),
	mean(y2),
	max(z2)];

pl = vrml_PointLight ("location", lpos, "intensity", 0.7);

#  distance = max ([max (x(:)) - min (x(:)),\
#  		 max (y(:)) - min (y(:)),\
#  		 max (z(:)) - min (z(:))])
#  vp = vrml_Viewpoint  ("orientation", [1 0 0 -pi/6],\
#  		      "position",    distance*[0 0 5]);

minpts = min (pt2');
maxpts = max (pt2');
medpts = (minpts + maxpts)/2;
ptssz  = (maxpts - minpts);
ptssz  = max (ptssz, max (ptssz/10));

if frame, fr = vrml_frame (minpts-ptssz/10,\
			   "scale", ptssz * 1.2, "col",(ones(3)+eye(3))/2);
else      fr = "";
end

sbg = vrml_Background ("skyColor", [0.5 0.5 0.6]);

slevel = "";
if ! isempty (level)
  level = level(:)';		# Make a row
  nlev = length (level);
  
  xmin = min (x(:)); xmax = max (x(:));
  ymin = min (y(:)); ymax = max (y(:));

  if any (size (lcol) != [nlev,3])
    nlc = prod (szlc = size (lcol));
				# Transpose colors
    if all (szlc == [3,nlev]), lcol = lcol'; 
				# Single gray level
    elseif nlc == 1          , lcol *= ones (nlev,3);
				# nlev gray levels
    elseif nlc == nlev       , lcol = lcol(:)*[1 1 1];
    elseif nlc == 3          , lcol = ones(nlev,1)*lcol(:)';
    else error ("lcol has size %i x %i",szlc);
    end
  end
  if prod (size (ltran)) == 1    , ltran = ltran*ones(1,nlev); end
  
  for i = 1:nlev
    slevel = [slevel, \
	      vrml_parallelogram([xmin     xmin     xmax     xmax;\
				  ymin     ymax     ymax     ymin;\
				  level(i) level(i) level(i) level(i)],\
				 "col",lcol(i,:),"tran",ltran(i))];
  end
end

s = [pl, sbg, s , fr, slevel];


vrml_browse (s);

if ! nargout,  clear s; end

%!demo
%! % Test the vmesh and vrml_browse functions with the test_vmesh script
%! R = 41; C = 26; 
%! [x,y] = meshgrid (linspace (-8+eps,8+eps,C), linspace (-8+eps,8+eps,R));
%! z = sin (sqrt (x.^2 + y.^2)) ./ (sqrt (x.^2 + y.^2));
%! vmesh (z);
%! printf ("Press a key.\n"); pause;
%! 
%! ############## The same surface, with holes (NaN's) in it. ###############
%! z(3,3) = nan;		# Bore a hole
%!  				# Bore more holes
%! z(1+floor(rand(1,5+R*C/30)*R*C)) = nan;
%! vmesh (z);
%! printf ("Press a key.\n"); pause;
%!
%! ###### The same surface, with checkered stripes - 'checker' option ######
%! vmesh (z,"checker",-[6,5]);
%! printf ("Press a key.\n"); pause;
%! 
%! ##### With z-dependent coloring - 'zrb', 'zgrey' and'zcol' options. #####
%! vmesh (z,"zrb");
%! printf ("That's it!\n");




## %! test_vmesh
endfunction

