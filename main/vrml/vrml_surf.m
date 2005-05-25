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

## s = vrml_surf (x, y, z [, options] ) - code for a VRML surface
## s = vrml_surf (z [, options] )
##
## Returns vrml97 code for a Shape -> IndexedFaceSet node representing a
## surface passing through the given points.
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
## Options :
##
## "col" , col  : 3      : RGB Color,                default = [0.3,0.4,0.9]
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
##        RGB and reflectivity values should be in the [0,1] interval.
##
## "checker", c : 1x2 : Color as a checker. If c(1) is positive, checker has
##            c(1) rows. If it is negative, each checker row is c(1) facets
##            high c(2) likewise determines width of checker columns.
## "checker", c : 1x1 : Same as [c,c].
##
## "zcol", zc   : 3xN : Specify a colormap. The color of each vertex is
##            interpolated according to its height (z).
##
## "zgrey"      : Black-to-white colormap. Same as "zcol", [0 1;0 1;0 1].
## "zrb"        : Red-to-blue. Same as "zcol", [0 7 10;0 0 2;7 19 2]/10.
##
## "tran", tran : 1x1    : Transparency,                        default = 0
##
## "creaseAngle", a
##              : 1      : vrml creaseAngle The browser may smoothe the fold
##                         between facets forming an angle less than a.
##                                                              default = 0
## "smooth"           : same as "creaseAngle",pi.

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: Setembro 2002


function s = vrml_surf (x, y, z,varargin)


if (nargin <= 1) || isstr(y),	# Cruft to allow not passing x and y
  zz = x ;
  [R,C] = size (zz);
  [xx,yy] = meshgrid (linspace (-1,1,C), linspace (-1,1,R));
  ## ones(R,1)*[1:C] ;
  ## yy = ## [1:R]'*ones(1,C) ;
  if     nargin >=3,
    s = vrml_surf ( xx, yy, zz, y, z, varargin{:} );
    return
  elseif nargin >=2,
    s = vrml_surf ( xx, yy, zz, y, varargin{:} );
    return
  end
  x = xx ; y = yy ; z = zz ;
end

				# Read options
				# Default values

upper = 1;			# Do "upper" triangulation of square grid
tran = 0 ;			# Transparency
col = [0.3, 0.4, 0.9] ;		# Color
checker = 0;			# Checkered coloring
colorPerVertex = 1;		# Color vertices or faces
zrb = zgrey = zcol = 0;		# Color by elevation
emit = 0;			# emissiveColor or diffuse only
smooth = creaseAngle = nan ;
DEFcoord = DEFcol = "";		# Give a name to VRML objects

if nargin > 3,

  op1 = " tran col creaseAngle emit colorPerVertex checker DEFcoord DEFcol zcol ";
  op0 = " smooth zgrey zrb " ;

  default = tar (tran, col, creaseAngle, emit, colorPerVertex, \
		 DEFcoord, DEFcol, zcol, smooth, checker, zgrey, zrb);

  s = read_options (varargin,"op0",op0,"op1",op1,"default",default);
  
  tran=            s.tran;
  col=             s.col;
  creaseAngle=     s.creaseAngle;
  emit=            s.emit;
  colorPerVertex=  s.colorPerVertex;
  DEFcoord=        s.DEFcoord;
  DEFcol=          s.DEFcol;
  zcol=            s.zcol;
  smooth=          s.smooth;
  checker=         s.checker;
  zgrey=           s.zgrey;
  zrb=             s.zrb;
end
## keyboard
if ! isnan (smooth), creaseAngle = pi ; end


[R,C] = size(z);
if any (size (x) == 1), x = ones(R,1)*x(:)' ; end
if any (size (y) == 1), y = y(:)*ones(1,C)  ; end

pts = [x(:)';y(:)';z(:)'];

keepp = all (!isnan(pts) & finite(pts)) ;
keepip = find (keepp);

trgs = zeros(3,2*(R-1)*(C-1)) ;

## Points are numbered as
##
## 1  R+1 .. (C-1)*R+1
## 2  R+2         :
## :   :          :
## R  2*R ..     C*R
##


## (x,y), (x,y+1), (x+1,y)  i.e. n, n+1, n+R

if !upper			# Do regular triangulation
  ## Triangles are numbered as :
  ##
  ## X = (R-1)*(C-1)
  ## +-----+-----+-----+-----+-----+
  ## |    /|    /|    /|    /|-R+1/|
  ## | 1 / | R / |   / |   / |R*C/ |
  ## |  /  |  /  |  /  |  /  |  /  |
  ## | /X+1| /X+R| /   | /   | /   |
  ## |/    |/    |/    |/    |/    |
  ## +-----+-----+-----+-----+-----+
  ## |    /|    /|    /|    /|    /|
  ## | 2 / |R+2/ |   / |   / |   / |
  ## |  /  |  /  |  /  |  /  |  /  |
  ## | /   | /   | /   | /   | /   |
  ## |/    |/    |/    |/    |/    |
  ## +-----+-----+-----+-----+-----+
  ##    :           :           :
  ##    :           :           :
  ## +-----+-----+-----+-----+-----+
  ## |    /|    /|    /|    /|    /|
  ## |R-1/ |2*R/ |   / |   / |C*R/ |
  ## |  /  |-1/  |  /  |  /  |  /  |
  ## | /X+R| /   | /   | /   | /C*R|
  ## |/    |/    |/    |/    |/ X+ |
  ## +-----+-----+-----+-----+-----+
  
  tmp = 1:(R-1)*(C-1);

  trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
  trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
  trgs(3,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';
  
  tmp += (R-1)*(C-1);
  
  trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';
  trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
  trgs(3,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';

else				# Do "upper" triangulation
  
  ##  Each triangle is      +-----+     +-----+
  ##  the highest of either |    /| or  |\    |
  ##                  	    |   / |     | \   |
  ##                  	    |  /  |     |  \  |
  ##                  	    | /   |     |   \ |
  ##                  	    |/    |     |    \|
  ##                        +-----+     +-----+


  tmp = 1:(R-1)*(C-1);
  tmp2 = reshape(1:R*C,R,C);
  foo1 = z(1:R-1,1:C-1) + z(2:R,2:C);
  foo2 = z(2:R,1:C-1) + z(1:R-1,2:C);
  tmp3 = (!isnan(foo1) & (isnan (foo2) | foo1 > foo2))(:)';

  trgs(1,tmp) = tmp2(1:R-1,1:C-1)(:)';
  trgs(2,tmp) = tmp2(2:R,1:C-1)(:)';
  trgs(3,tmp) = trgs(1,tmp) + R + tmp3 ;
  tmp += (R-1)*(C-1);
  trgs(1,tmp) = tmp2(1:R-1,2:C)(:)';
  trgs(2,tmp) = tmp2(2:R,2:C)(:)';
  trgs(3,tmp) = trgs(1,tmp) - R + 1 - tmp3 ;
end				# EOF "upper" triangulation

if length (col) == 1		# Convert graylevel to RGB
  col = [1 1 1]*col;

elseif any (prod (size (col)) == [R*C,(R-1)*(C-1)])
  col = [1;1;1]*col(:)';
end

if zgrey || zrb || any (zcol(:)) # Treat zgrey zrb and zcol options
  zx = max (z(keepip));
  zn = min (z(keepip));
  if     zgrey, zcol = [0 0 0; 1 1 1]';
  elseif zrb  , zcol = [0 0 0.7; 0.5 0 0.8; 1 0 0]';
  end

  ci = 1 + floor (cw = (columns (zcol)-1) * (z(keepip) - zn)/(zx - zn));
  cw =  cw - ci + 1;
  ii = find (ci >= columns (zcol));
  if ! isempty (ii), ci(ii) = columns (zcol) - 1; cw(ii) = 1; end
  col = zeros (3,R*C);
  col(:,keepip) = \
      zcol(:,ci) .* ([1;1;1]*(1-cw)) + zcol(:,ci+1) .* ([1;1;1]*cw);

end				# EOF zgrey zrb and zcol options


if checker
  if isnan (checker), checker = 10; end
  if length (checker) == 1, checker = [checker, checker]; end

  if checker(1) > 0, checker(1) = - C/checker(1); end
  if checker(2) > 0, checker(2) = - R/checker(2); end
  checker *= -1;
  colx = 2 * (rem (0:C-2,2*checker(1)) < checker(1)) - 1;
  coly = 2 * (rem (0:R-2,2*checker(2)) < checker(2)) - 1;
  icol = 1 + ((coly'*colx) > 0);
				# Keep at most 1st 2 colors of col for the
				# checker
  if prod (size (col)) == 2,
    col = [1;1;1]*col;
  elseif  prod (size (col)) < 6, # Can't be < 3 because of previous code
    col = col(1:3)(:);
    if all (col >= 1-eps), col = [col [0;0;0]];	# Black and White
    else                   col = [col [1;1;1]];	# X and White
    end
  end
  col = reshape (col(:),3,2);
  col = col(:,icol);
end				# EOF if checker


if prod (size (col)) == 3*(R-1)*(C-1),
  colorPerVertex = 0;
end

if ! colorPerVertex
  if prod (size (col)) == 3*(R-1)*(C-1)
    col = reshape (col,3, (R-1)*(C-1));
    col = [col, col];
  else
    printf(["vrml_surf : ",\
	    " colorPerVertex==0, (R-1)*(C-1)==%i, but col has size [%i,%i]\n"],\
     R*C,size (col));
  end

end

if ! all(keepp),

				# Try to toggle some triangles to fill in
				# holes
  if ! upper
    nt = (R-1)*(C-1) ;
    tmp = ! reshape(keepp(trgs),3,2*nt);
    tmp = all( tmp == kron([0,0;0,1;1,0],ones(1,nt)) );
    trgs(3,     find (    tmp(1:nt)   & rem (trgs(3,1:nt),R)) )++ ;
    trgs(2, nt+ find ( tmp(nt+1:2*nt) & (rem (trgs(3,nt+1:2*nt),R)!=1)) )-- ;
    
				# Remove whatever can't be kept
    keept = all (reshape(keepp(trgs),3,2*(R-1)*(C-1)));
  else
    tmp = reshape (keepp,R,C);
    keept = \
	all (reshape (tmp(trgs(1:2,:)),2,2*(R-1)*(C-1))) & \
	[(tmp(1:R-1,2:C) | tmp(2:R,2:C))(:)', \
	 (tmp(1:R-1,1:C-1) | tmp(2:R,1:C-1))(:)'] ;
  end

  keepit = find (keept);

  renum = cumsum (keepp);

  pts = pts (:,keepip);
  trgs = reshape(renum (trgs (:,keepit)), 3, columns(keepit));

  if prod (size (col)) == 6*(R-1)*(C-1)	
    col = col(:,keepit);
				# Coherence check : colorPerVertex == 0
    if colorPerVertex
      error ("Col has size 3*(R-1)*(C-1), but colorPerVertex == 1");
    end

  elseif prod (size (col)) == 3*R*C 
    col = col(:,keepip);

				# Coherence check : colorPerVertex == 1
    if ! colorPerVertex
      error ("Col has size 3*R*C, but colorPerVertex == 0");
    end
  end

end
## printf ("Calling vrml_faces\n");
s = vrml_faces (pts, trgs, "col", col,\
		"colorPerVertex",colorPerVertex,\
		"creaseAngle", creaseAngle,\
		"tran", tran, "emit", emit,\
		"DEFcoord",DEFcoord,"DEFcol",DEFcol);
## printf ("Done\n");
## R=5; C=11;
## x = ones(R,1)*[1:C]; y = [1:R]'*ones(1,C);
## zz = z = sin(x)+(2*y/R-1).^2 ;
## ## Punch some holes
## holes = ind2sub ([R,C],[3,3,3,1,2,3,2,3;1,2,3,5,7,7,9,10]')
## z(holes) = nan
## save_vrml("tmp.wrl",vrml_surf(x,y,z+1))
## save_vrml("tmp.wrl",vrml_surf(z,"col",[0.5,0,0],"tran",0.5),vrml_surf(z+1))

