## Copyright (C) 2012 Etienne Grossmann <etienne@egdn.net>
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
##
## s = vrml_Shape (s_geometry, s_appearance) - VRML code for a shape node
##
## Example: An orange flat box
## 
##  vrml_browse (vrml_Shape (vrml_Box ([3 2 0.2]),vrml_material([1 .5 0])))
function s = vrml_Shape (s_geometry, s_appearance)

if nargin < 1, s_geometry =   ""; end
if nargin < 2, s_appearance = ""; end

if !isempty (s_geometry),
  s_geometry = ["\n  geometry ",s_geometry];
end
if !isempty (s_appearance),

				# Check whether a "material" is passed. If yes,
				# wrap it in an Appearance
  is_material = strfind (s_appearance,"material");
  if !isempty (is_material), 
    is_material = is_material(1) != 1 || all (s_appearance(1:is_material(1)-1) == " ");
  end
  if is_material
    s_appearance = ["Appearance {\n",s_appearance,"}\n"];
  end

  s_appearance = ["\n  appearance ",s_appearance];

end

s = ["Shape {",s_appearance,s_geometry,"}\n"];
