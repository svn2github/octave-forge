
##
## Test vmesh.m

printf ("test_vmesh : display a surface with holes in it\n");

R = 21;
C = 13;

[x,y] = meshgrid (linspace (-1,1,C), linspace (-1,1,R));

z = (cos (x*2*pi) + y.^2)/3;
z(3,3) = nan;			# Bore a hole
				# Bore more holes
z(1+floor(rand(1,5)*R*C)) = nan;

				# Try texture as a file, an "ims" or a
				# matrix. 
## tex = "octave-mylib/tools/imgio/test_images/test_col.xpm";
## tex = ims_load ("octave-mylib/tools/imgio/test_images/test_col.jpg");
## tex = kron (ones (4),eye(2));

vmesh (z);
