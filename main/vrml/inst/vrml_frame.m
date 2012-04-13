## Copyright (C) 2002 Etienne Grossmann <etienne@cs.uky.edu>
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

##       v = vrml_frame (t, r, ...)
##  
## t : 3      Translation                          Default : [0,0,0]
## r : 3x3    Matrix, or                           Default : eye(3)
##     3      Argument for rotv
## OPTIONS
##  name   : size     : function                                   : default
## "scale" : 3 or 1   : Length of frame's branches (including cone)   <1>
## "diam"  : 3 or 1   : Diameter of cone's base
## "col"   : 3 or 3x3 : Color of branches (may be stacked vertically) <[3 4 9]/10>
## "hcol"  : 3 or 3x3 : Color of head     (may be stacked vertically) <col>
##                                                  

function v = vrml_frame (varargin)

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
args = nargin; # nargin is now a function
while args && numeric_args<2,


  tmp = varargin{numeric_args + 1};
  if ischar (tmp), break; end
  --args;
  numeric_args++;
  if numeric_args == 1, t = tmp ; 
  else                  r = tmp ;  break;
  end
end

if args

  leftover_args = varargin;	# pos 2.1.39
  leftover_args = leftover_args (numeric_args+1:length(leftover_args));

  verbose = 0;

  ## df = tars (col, hcol, diam, scale, verbose);
  df = struct ("col",    col,   \
	       "hcol",   hcol,  \
	       "diam",   diam,  \
	       "scale",  scale, \
	       "verbose",verbose);
  op1 = " col hcol diam scale ";
  op0 = " verbose ";
  s = read_options (leftover_args, "op1",op1,"op0",op0,"default",df,"skipnan",1);
  col = s.col;
  hcol = s.hcol;
  diam = s.diam;
  scale = s.scale;
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

ml = max (abs (scale(ii)));
diam(ii) = ml./scale/16;
rdiam(ii) = ml./scale/32;

sz = [scale; nan*ones(1,3); diam; rdiam] ;

## roddiam = min (nze (scale))/12 ;
## if roddiam, d = roddiam.*scale ; else d = [nan,nan,nan] ; end

## diam = diam.*scale ;
## d = diam = nan*scale;
r2 = r;
n = sqrt (sum (r2.^2));
r2./= [1;1;1] * n;
sz(1,:) .*= n;
sz(3,:) ./= n;
sz(4,:) ./= n;

tmp = [r2(:,1), null(r2(:,1)')](:,[2,1,3])';
if det (tmp) < 0, tmp(3,:) *= -1; end
a1 = vrml_transfo (vrml_arrow(sz(:,1),[col(1,:);hcol(1,:)],0),\
		   [0,0,0],tmp);
## keyboard
tmp = [r2(:,2), null(r2(:,2)')](:,[2,1,3])';
if det (tmp) < 0, tmp(3,:) *= -1; end
a2 = vrml_transfo (vrml_arrow(sz(:,2),[col(2,:);hcol(2,:)],0),\
		   [0,0,0],tmp);

tmp = [r2(:,3), null(r2(:,3)')](:,[2,1,3])';
if det (tmp) < 0, tmp(3,:) *= -1; end
a3 = vrml_transfo (vrml_arrow(sz(:,3),[col(3,:);hcol(3,:)],0),\
		   [0,0,0],tmp);

f0 = vrml_group (a1, a2, a3);
v = vrml_transfo (f0, t, nan);


endfunction

