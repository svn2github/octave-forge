## s = vrml_flatten (x [, d, w, col]) - A planar surface containing x
##
## If the points  x  are not coplanar (or not in the affine plane {y|d'*y==w}),
## the surface will not contain the points, but rather their projections on
## the plane {y|d'*y==w}.
## 
## x   : 3 x P  : 3D points
## d   : 3      : normal to plane    | Default : given by best_dir()
## w   : 1      : intercept of plane |
## col : 3      : RGB color            Default : [0.3,0.4,0.9]
##
## s   : string : vrml code representing the planar surface

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function s = vrml_flatten (x, d, w, col)


if     nargin <= 3 || isnan (col),  col = [0.3,0.4,0.9];  end
if     nargin <= 1 || isnan (d),    [d,w] = best_dir (x); 
elseif nargin <= 2 || isnan (w),    w = mean (d'*x); end
if   ! nargin,       error ("vrml_flatten : no arguments given"); end 

y = bound_convex (d,w,x);
Q = columns (y);
faces = [ones(1,Q-2); 2:Q-1; 3:Q];

s = vrml_faces (y, faces, "col",col);