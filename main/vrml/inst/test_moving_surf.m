

R = 15;
C = 23;

[x,y] = meshgrid (linspace (-1,1,C), linspace (-1,1,R));

z = (cos (x*2*pi) + 2*y.^2)/3;
z2 = (2*cos (x*2*pi) + y.^2)/3;

a = [x(:),y(:),z(:)]';
b = [x(:),y(:),z2(:)]';


printf ("\ntest_changing_surf \n");
if 1
  printf (" - display a moving surface\n");

  s1 = vrml_surf (z,"DEFcoord","foo");

  s2 = vrml_anim ("Coordinate",[a,b,a],"foo.set_point",[0 0.5 1],5);

  s3 = vrml_faces ([-1 -1 1 1;-1 1 1 -1;0.1 0.1 0.1 0.1],\
		   list ([1 2 3 4]),"tran",0.4,"col",[0.3 0.9 0.4]);

  vrml_browse ([s1,s2,s3])

  printf ("Press a key. \n"); pause ();
end
if 1
  printf (" - display a moving surface w/ changing color\n");

  c0 = rem ([1:R-1]'*ones(1,C-1) + ones(R-1,1)*[1:C-1],2)(:);
  c1 = [0.8*c0                 ,(1-c0)*0.8, 0.3*ones((R-1)*(C-1),1)]';
  c2 = [0.3*ones((R-1)*(C-1),1),    c0*0.8, 0.8*(1-c0)]';

  c1 = [3 9 3]'/10;
  c2 = [3 3 9]'/10;

  s1 = vrml_surf (z,"DEFcol","bar","col",c1,"DEFcoord","foo");

  [s2,tn] = vrml_anim ("Color",[c1,c2,c1],"bar.set_diffuseColor",[0 0.5 1],5);

  s4 = vrml_anim ("Coordinate",[a,b,a],"foo.set_point",[0 0.5 1],tn);

  s3 = vrml_faces ([-1 -1 1 1;-1 1 1 -1;0.1 0.1 0.1 0.1],\
		 list ([1 2 3 4]),"tran",0.4,"col",[0.9 0.4 0.4]);

  vrml_browse ([s1,s2,s3,s4])
  printf ("Press a key. \n"); pause ();
end



