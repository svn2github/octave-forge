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

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function s = vmesh (x, y, z, ...)


if (nargin <= 1) || isstr(y),	# Cruft to allow not passing x and y
  zz = x ;
  [R,C] = size (zz);
  [xx,yy] = meshgrid (linspace (-1,1,C), linspace (-1,1,R)); 
  ## ones(R,1)*[1:C] ;
  ## yy = ## [1:R]'*ones(1,C) ;
  if     nargin >=3,
    s = vmesh ( xx, yy, zz, y, z, all_va_args );
    if ! nargout,  clear s; end;  return
  elseif nargin >=2,
    s = vmesh ( xx, yy, zz, y, all_va_args );
    if ! nargout,  clear s; end;  return
  end
  x = xx ; y = yy ; z = zz ;
end

frame = 1;

surf_args = list (x,y,z);	# Arguments that'll be passed to vrml_surf

if nargin > 3,

  op1 = " tran col checker creaseAngle emit colorPerVertex tex ";
  op0 = " smooth " ;

  s = read_options (list(all_va_args),"op0",op0,"op1",op1);

				# Identify options for vrml_surf()
  all_surf_opts  = list ("tran", "col", "checker", "creaseAngle", "emit", \
			 "colorPerVertex", "smooth", "tex");

  for i = 1:length(all_surf_opts)
    optname = nth (all_surf_opts, i);
    if struct_contains (s, optname)
      surf_args = append (surf_args, list (optname, getfield (s, optname)));
    end
  end
end


s = leval ("vrml_surf", surf_args);

pts = [x(:)';y(:)';z(:)'];
## Addd a point light
scl = nanstd ((pts-mean (pts')'*ones(1,columns (pts)))(:));

lpos = [min (x(:)) - 1.1*scl* max (max(x(:))-min(x(:)), 1),
	mean(y(:)),
	max(z(:))];
pl = vrml_PointLight ("location", lpos, "intensity", 0.7);

#  distance = max ([max (x(:)) - min (x(:)),\
#  		 max (y(:)) - min (y(:)),\
#  		 max (z(:)) - min (z(:))])
#  vp = vrml_Viewpoint  ("orientation", [1 0 0 -pi/6],\
#  		      "position",    distance*[0 0 5]);

minpts = nanmin (pts');
maxpts = nanmax (pts');
medpts = (minpts + maxpts)/2;
ptssz  = (maxpts - minpts);

if frame, fr = vrml_frame (minpts-ptssz/10,
			   "scale", ptssz * 1.2, "col",(ones(3)+eye(3))/2);
else      fr = "";
end

sbg = vrml_Background ("skyColor", [0.5 0.5 0.6]);

s = [pl, sbg, s , fr];

vrml_browse (s);

if ! nargout,  clear s; end

## R=5; C=11;
## x = ones(R,1)*[1:C]; y = [1:R]'*ones(1,C);
## zz = z = sin(x)+(2*y/R-1).^2 ;
## ## Punch some holes
## holes = ind2sub ([R,C],[3,3,3,1,2,3,2,3;1,2,3,5,7,7,9,10]')
## z(holes) = nan
## save_vrml("tmp.wrl",vmesh(x,y,z+1))
## save_vrml("tmp.wrl",vmesh(z,"col",[0.5,0,0],"tran",0.5),vmesh(z+1))

