## s = vrml_parallelogram (x,...)
##
## x : 3 x 3 : Each column is a 3D point. The fourth corner is 
##               x(:,1)-x(:,2)+x(:,3)
##
## OPTIONS :
## ---------
## col,   c : 3x1 : Color of surface
## emit,  e : 1   :
## tran,  t : 1   :
##
## border,b : 1   :
## bocol, c : 3   :
## boemit,e : 1   :
## borad, r : 1   :
##
## balls, b : 1   :
## bcol,  c : 3   :
## bemit, e : 1   :
## brad,  r : 1   :
function s = vrml_parallelogram (x, varargin)

col = [0.3,0.4,0.9];
emit = 0;
tran = 0;
balls = 0;
border = 0;
bcol = btran = bemit = brad = borad = bocol = boemit = nan;

if nargin > 1
  op1 = " col emit tran balls border bcol btran bemit brad borad bocol boemit ";
  df = tar (col,emit,tran,balls,border,bcol,btran,bemit,brad,borad,bocol,boemit);
  s = read_options (varargin, "op1",op1, "default",df);
  [col,emit,tran,balls,border,bcol,btran,bemit,brad,borad,bocol,boemit] = \
      getfield (s,\
		"col","emit","tran","balls","border","bcol","btran","bemit",\
		"brad","borad","bocol","boemit");
end

if ! isnan (bcol) ||! isnan (brad) || ! isnan (bemit), balls = 1; end
if balls
 if isnan (bcol), bcol = col; end
 if isnan (btran), btran = tran; end
 if isnan (brad)
   brad = (norm (x(:,1)-x(:,2))+ norm(x(:,1)-x(:,2)))/20; 
 end
end

x = [x(:,1:3), x(:,1)-x(:,2)+x(:,3)];

				# The facet
s = vrml_faces (x,list (1:4),"col",col, "tran", tran,"emit",emit);

				# Decoration : balls on vertices
if balls
  if isnan (bemit), bemit = emit; end
  s = [s,vrml_points (x,"balls","rad",brad,"col",bcol,"tran",btran,"emit",bemit)];
end

				# Decoration : border

if ! isnan (bocol) ||! isnan (borad) || ! isnan (boemit), border = 1; end
if border
  if isnan (borad)
    borad = (norm (x(:,1)-x(:,2))+ norm(x(:,1)-x(:,2)))/80;
  end
  if isnan (boemit)
    if isnan (bemit), boemit = emit; else boemit = bemit; end
  end
  if isnan (bocol), bocol = col; end
    
  if !balls			# Make pretty junctions of cylinders
    s = [s,\
	 vrml_cyl (x(:,[1:columns(x),1]),"rad",borad,"emit",boemit,"col",col),\
	 vrml_points (x(:,1),"balls","rad",borad,"emit",boemit,"col",col)];
  else				# but only if balls don't cover them
    s = [s,vrml_cyl (x(:,[1:columns(x),1]),"rad",borad,"emit",boemit)];
  end
end