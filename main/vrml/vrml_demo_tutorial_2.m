
## Author : Etienne Grossmann <etienne@isr.ist.utl.pt>

printf (["\n",\
	 "     VRML Mini-HOWTO's second listing\n",\
	 "     Show 3D points and select some with the mouse\n\n"]);

printf (["    Reminder of FreeWRL keystrokes and mouse actions :\n"\
	 "      q : quit\n",\
	 "      w : switch to walk mode\n",\
	 "      e : switch to examine mode\n",\
	 "      drag left mouse : rotate (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "      drag right mouse : zoom (examine mode) or translate\n",\
	 "          (walk mode).\n",\
	 "      click on box : toggle selection\n",\
	 "\n"]);

## Listing 2

N = 30;

x = [randn(3,N) .* ([1,3,6]'*ones(1,N)), [5 5;-1 1;0 0]];

s = select_3D_points (x);

printf ("The selected points are : \n");
s
