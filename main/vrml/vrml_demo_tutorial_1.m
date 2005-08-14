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

## Author : Etienne Grossmann <etienne@cs.uky.edu>

printf (["\n",\
	 "    VRML Mini-HOWTO's first listing\n",\
	 "    Display the surface of a quadratic surface\n\n"]);

printf (["    Reminder of FreeWRL keystrokes and mouse actions :\n"\
	 "      q : quit\n",\
	 "      w : switch to walk mode\n",\
	 "      e : switch to examine mode\n",\
	 "      drag left mouse : rotate (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "      drag right mouse : zoom (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "\n"]);

## Listing 1

x = linspace (-1,1,31);

[xx,yy] = meshgrid (x,x);

zz = xx.^2 + yy.^2;

vmesh (zz);

## Variant of listing 1

printf ("    Hit a key to see the variant of listing 1\n\n");

pause

vmesh (zz,"checker",[5,-2],"col",[1 0 0;0.7 0.7 0.7]');


vmesh (zz,"checker",[5,-2],"col",[1 0 0;0.7 0.7 0.7]');
