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

## s = vrml_select_points (x, state) - vrml code for selecting 3D points
##
## x     : 3 x P  : 3D points
## state : P      : 0-1 matrix specifying currently selected points
##      or Q      : List of indices of currently selected points
##                                                    Default=zeros(1,P)
## sphere: bool   : If true represent points as spheres instead of cubes.
##
## s     : string : vrml code representing points in x as spheres that
##                  change color (green to/from blue) when clicked upon.
## 
## See  select_3D_points()  for complete 3D point selection interface.

## Author : Etienne Grossmann <etienne@cs.uky.edu>
function s = vrml_select_points (x, state, sphere)

P = columns (x);

if nargin < 2,
  state = zeros (1,P);		# Default : nothing pre-selected
else
  state = state(:)';
  if length (state) != P || any (state != 1 & state != 0),
    tmp = zeros (1,P);
    tmp(state) = 1;
    state = tmp;
    ## state = loose (state, P)';
  end
end
if nargin < 3, sphere = 0; end

diam = 0.1 * mean (sqrt (sum ((x-mean(x')'*ones(1,P)).^2))) ;

## For odb
## Depends: defSpeakSphere.wrl defSpeakBox.wrl

if sphere
  proto = "data/defSpeakSphere.wrl" ;
else
  proto = "data/defSpeakBox.wrl" ;
end

s0 = slurp_file (proto);

				# Pre-selected spheres will be lighter-colored
col1 = [0.4;0.4;0.9]*ones(1,P);
if any (state),
  col1(:,find(state)) = [0.6;0.6;0.8]*ones(1,sum(state));
end

tp = "SpeakSphere {col1 %8.3f %8.3f %8.3f state %i pos %8.3g %8.3g %8.3g scale %8.3g %8.3g %8.3g tag \"%i\"}\n";

s1 = sprintf (tp, [col1; state; x; diam*ones(3,P);1:P]);

s = [s0,s1];
