
##
## Test vmesh.m

printf ("test_vmesh : \nDisplay a surface.\n");

R = 41;
C = 26;

[x,y] = meshgrid (linspace (-1,1,C), linspace (-1,1,R));

z = (cos (x*2*pi) + y.^2)/3;

vmesh (z);
printf ("Press a key.\n"); pause;


printf ("The same surface, with holes in it.\n");

z(3,3) = nan;			# Bore a hole
				# Bore more holes
z(1+floor(rand(1,5+R*C/30)*R*C)) = nan;

				# Try texture as a file, an "ims" or a
				# matrix. 
## tex = "octave-mylib/tools/imgio/test_images/test_col.xpm";
## tex = ims_load ("octave-mylib/tools/imgio/test_images/test_col.jpg");
## tex = kron (ones (4),eye(2));

vmesh (z);

printf ("Press a key.\n"); pause;

printf (["The same surface, with checkered stripes ",\
	 "(see the 'checker' option).\n"]);

vmesh (z,"checker",-[6,5]);

printf ("Press a key.\n"); pause;

printf (["The same surface, with z-dependent coloring (see 'zrb', 'zgrey'\n",\
	 "  and 'zcol' options)\n"]);

vmesh (z,"zrb");

printf ("That's it!\n");