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
## "tran", tran : 1x1    : Transparency,                        default = 0
##
## "creaseAngle", a 
##              : 1      : vrml creaseAngle The browser may smoothe the fold
##                         between facets forming an angle less than a.
##                                                              default = 0
## "smooth"           : same as "creaseAngle",pi.

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function s = vrml_surf (x, y, z, ...)


if (nargin <= 1) || isstr(y),	# Cruft to allow not passing x and y
  zz = x ;
  [R,C] = size (zz);
  [xx,yy] = meshgrid (linspace (-1,1,C), linspace (-1,1,R)); 
  ## ones(R,1)*[1:C] ;
  ## yy = ## [1:R]'*ones(1,C) ;
  if     nargin >=3,
    s = vrml_surf ( xx, yy, zz, y, z, all_va_args );
    return
  elseif nargin >=2,
    s = vrml_surf ( xx, yy, zz, y, all_va_args );
    return
  end
  x = xx ; y = yy ; z = zz ;
end

				# Read options
				# Default values
tran = 0 ;
col = [0.3, 0.4, 0.9] ;
checker = 0;
colorPerVertex = 1;
smooth = creaseAngle = nan ;
emit = 0;


if nargin > 3,

  op1 = " tran col creaseAngle emit colorPerVertex checker ";
  op0 = " smooth " ;

  default = tar (tran, col, creaseAngle, emit, colorPerVertex, smooth, checker);
  s = read_options (list(all_va_args),"op0",op0,"op1",op1,"default",default);
  [tran, col, creaseAngle, emit, colorPerVertex, smooth, checker] = getfield \
      (s, "tran", "col", "creaseAngle", "emit", "colorPerVertex", "smooth","checker");

  ## nargin -= 3 ;
  ## read_options_old ;
end

if ! isnan (smooth), creaseAngle = pi ; end


[R,C] = size(z);
if any (size (x) == 1), x = ones(R,1)*x(:)' ; end
if any (size (y) == 1), y = y(:)*ones(1,C)  ; end

pts = [x(:)';y(:)';z(:)'];

keepp = all (!isnan(pts) & finite(pts)) ;

trgs = zeros(3,2*(R-1)*(C-1)) ;

tmp = 1:(R-1)*(C-1);

## Points are numbered as
##
## 1  R+1 .. (C-1)*R+1
## 2  R+2         :
## :   :          :
## R  2*R ..     C*R
##

## Triangles are numbered as :
## 
## X = (R-1)*(C-1)
## _______________________________
## |    /|    /|    /|    /|-R+1/|
## | 1 / | R / |   / |   / |R*C/ |
## |  /  |  /  |  /  |  /  |  /  |
## | /X+1| /X+R| /   | /   | /   |
## |/    |/    |/    |/    |/    |
## -------------------------------
## |    /|    /|    /|    /|    /|
## | 2 / |R+2/ |   / |   / |   / |
## |  /  |  /  |  /  |  /  |  /  |
## | /   | /   | /   | /   | /   |
## |/    |/    |/    |/    |/    |
## -------------------------------
##    :           :           :
##    :           :           :
## -------------------------------
## |    /|    /|    /|    /|    /|
## |R-1/ |2*R/ |   / |   / |C*R/ |
## |  /  |-1/  |  /  |  /  |  /  |
## | /X+R| /   | /   | /   | /C*R|
## |/    |/    |/    |/    |/ X+ |
## -------------------------------

## (x,y), (x,y+1), (x+1,y)  i.e. n, n+1, n+R

trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(3,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';

tmp += (R-1)*(C-1);

trgs(1,tmp) = ([1:R-1]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';
trgs(2,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[0:C-2])(:)';
trgs(3,tmp) = ([ 2:R ]'*ones(1,C-1) + R*ones(R-1,1)*[1:C-1])(:)';

if length (col) == 1		# Convert graylevel to RGB
  col = [1 1 1]*col;

elseif any (prod (size (col)) == [R*C,(R-1)*(C-1)])
  col = [1;1;1]*col(:)';
end


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
end


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
  nt = (R-1)*(C-1) ;
  tmp = ! reshape(keepp(trgs),3,2*nt);
  tmp = all( tmp == kron([0,0;0,1;1,0],ones(1,nt)) );
  trgs(3,     find (    tmp(1:nt)   & rem (trgs(3,1:nt),R)) )++ ;
  trgs(2, nt+ find ( tmp(nt+1:2*nt) & (rem (trgs(3,nt+1:2*nt),R)!=1)) )-- ;

				# Remove whatever can't be kept
  keept = all (reshape(keepp(trgs),3,2*(R-1)*(C-1)));
  ## keept = all (keepp(trgs)) ;
  keepip = find (keepp);
  keepit = find (keept);
  renum = cumsum (keepp);

  pts = pts (:,keepip) ;
  trgs = reshape(renum (trgs (:,keepit)), 3, columns(keepit));

end
s = vrml_faces (pts, trgs, "col", col,\
		"colorPerVertex",colorPerVertex,\
		"creaseAngle", creaseAngle,\
		"tran", tran, "emit", emit);

## R=5; C=11;
## x = ones(R,1)*[1:C]; y = [1:R]'*ones(1,C);
## zz = z = sin(x)+(2*y/R-1).^2 ;
## ## Punch some holes
## holes = ind2sub ([R,C],[3,3,3,1,2,3,2,3;1,2,3,5,7,7,9,10]')
## z(holes) = nan
## save_vrml("tmp.wrl",vrml_surf(x,y,z+1))
## save_vrml("tmp.wrl",vrml_surf(z,"col",[0.5,0,0],"tran",0.5),vrml_surf(z+1))

