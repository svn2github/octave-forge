##       v = vrml_frame (t, r, ... )
##  
## t : 3      Translation                          Default : [0,0,0]
## r : 3x3    Rotation matrix, or                  Default : eye(3)
##     3      Argument for rotv
## Options
## "scale" : 3 or 1   : Length of frame's branches (including cone)
## "diam"  : 3 or 1   : Diameter of cone's base
## "col"   : 3 or 3x3 : Color of branches (eventually stacked vertically)
## "hcol"  : 3 or 3x3 : Color of head     (eventually stacked vertically)
##                                                  Default : col

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function v = vrml_frame(...)

### Test with : frame with R,G,B vectors of len 3,2,1 and cone's diam are .2,
### .4, .6.
##
### vrml_browse (vrml_frame ("scale",[3,2,1],"diam",0.2*[1,2,3],"col",eye(3)));

t = zeros (3,1);
r = eye(3);

scale = ones (1,3);
diam = [nan,nan,nan];
col = [0.3 0.4 0.9];
hcol = [];

######################################################################
## Read options
numeric_args = 0;
while nargin && numeric_args<2,

  tmp = va_arg ();
  if isstr (tmp), break; end
  --nargin;
  numeric_args++;
  if numeric_args == 1, t = tmp ; 
  else                  r = tmp ;  break
  end
end

if nargin
  leftover_args = list (all_va_args);
  leftover_args = leftover_args (numeric_args+1:length(leftover_args));

  verbose = 0;

  df = tar (col, hcol, diam, scale, verbose);
  op1 = " col hcol diam scale ";
  op0 = " verbose ";
  s = read_options (leftover_args, "op1",op1,"op0",op0,"default",df);
  [col, hcol, diam, scale, verbose] = \
      getfield (s, "col","hcol","diam","scale","verbose");
end

######################################################################
if isempty (hcol), hcol = col; end

t = t(:);			# t : 3x1

if prod (size (r)) == 3, r = rotv (r); end

## col is 3x3 from now on
if prod (size (col))==3,   col =   [1;1;1]*col(:)' ; end
if prod (size (hcol))==3,  hcol =  [1;1;1]*hcol(:)' ; end
if prod (size (diam))==1,  diam =  [1,1,1]*diam ; end
if prod (size (scale))==1, scale = [1,1,1]*scale ; end

diam = diam(:)' ;
scale = scale(:)' ;

ii = find (scale & ! isnan (scale));
diam(ii) = diam(ii).*scale(ii);
rdiam = nan*ones(1,3) ; ## ones (1,3)/24 ;

sz = [scale; nan*ones(1,3); diam; rdiam] ;

## roddiam = min (nze (scale))/12 ;
## if roddiam, d = roddiam.*scale ; else d = [nan,nan,nan] ; end

## diam = diam.*scale ;
## d = diam = nan*scale; 
a1 = vrml_transfo (vrml_arrow(sz(:,1),[col(1,:);hcol(1,:)],0),\
		   [0,0,0],[0,-1,0;1,0,0;0,0,1]);
a2 = vrml_arrow(sz(:,2),[col(2,:);hcol(2,:)],0);
a3 = vrml_transfo (vrml_arrow(sz(:,3),[col(3,:);hcol(3,:)],0),\
		   [0,0,0],[1,0,0;0,0,1;0,-1,0]);

f0 = vrml_group (a1, a2, a3);

v = vrml_transfo (f0, t, r);