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

## Author : Etienne Grossmann <etienne@isr.ist.utl.pt>

printf (["\n",\
	 "     VRML Mini-HOWTO's second listing\n",\
	 "     Show a helix of ellipsoids and one consisting of cylinders\n\n"]);

printf (["    Reminder of FreeWRL keystrokes and mouse actions :\n"\
	 "      q : quit\n",\
	 "      w : switch to walk mode\n",\
	 "      e : switch to examine mode\n",\
	 "      drag left mouse : rotate (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "      drag right mouse : zoom (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "\n"]);

## Listing 4

x = linspace (0,4*pi,50);

                           # Points on a helix

xx1 = [x/6; sin(x); cos(x)];



                           # Linked by segments

s1 = vrml_cyl (xx1, "col",kron (ones (3,25),[0.7 0.3]));



                           # Scaled and represented by spheres

s2 = vrml_points (xx1,"balls");

s2 = vrml_transfo (s2,nan,[pi/2,0,0],[1 0.5 0.5]);

s3 = vrml_Background ("skyColor",[0 0 1]);

vrml_browse ([s1, s2, s3]);






