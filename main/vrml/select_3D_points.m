## sel2 = select_3D_points (x, sel1, deco) - select 3D points
##
## x     : 3 x P  : 3D points
## sel1  : P      : 0-1 matrix specifying currently selected points
##      or Q1     : List of indices of currently selected points
##                                                    Default=zeros(1,P)
## deco  : string : Vrml code for decorating set of 3D points
##                                                    Default=""
##
## sel2  : P      : 0-1 matrix or list of selected points    (default)
##      or Q2       List of selected points

## Author  : Etienne Grossmann <etienne@isr.ist.utl.pt>

function sel2 = select_3D_points (x, sel1, varargin)

P = columns (x);
global vrml_b_pid = 0;

opts = struct ("frame", 1,\
	       "deco", "",\
	       "balls", 0);

if nargin > 2
  op1 = " frame deco balls ";

  opts = read_options (varargin, "op1", op1,"default",opts);
end
[frame, deco, balls] = getfield (opts, "frame", "deco", "balls");

want_list = 0;			# Return list of selected points or 0-1
				# matrix 



if nargin >=2 && length (sel1(:)) == P && all (sel1==0 || sel1==1),
				# sel1 has been passed 
  sel1 = sel1(:)';
  if columns (sel1) != P || (!isempty (sel1) && any (sel1!=1 & sel1!=0)),
    want_list = 1;
    tmp = zeros (1,P);
    tmp(state) = 1;
    sel1 = tmp;
    ## sel1 = loose (sel1, P)';
  end
else
  sel1 = zeros (1,P);		# Default : nothing pre-selected
end
				# NOTE : this filename hardcoded in
				# vrml_browse()
data_out = "/tmp/octave_browser_out.txt";

x -= mean(x')' * ones(1,P);
x ./= sqrt (mean (x(:).^2));

s = vrml_select_points (x, sel1, balls);

## vrml_browse ("-kill");	# Stop previous browser, if any

sbg = vrml_Background ("skyColor", [0.5 0.5 0.6]);

				# Clean data file ####################
[st,err,msg] = stat (data_out);
if ! err,			# There's a file : clean it
  [err,msg] = unlink (data_out);
  if err,
    error ("select_3D_points : Can't remove data file '%s'",data_out);
  end
				# There's no file, but there's a pid.
elseif vrml_b_pid,		
				# assume browser died. kill it for sure
  vrml_browse ("-kill");
end

if frame
  sframe = vrml_frame ([0 0 0],[0 0 0],"col",0.5*(eye(3) + ones (3)));
else
  sframe = "";
end

				# Start browser ######################
vrml_browse ([sbg, sframe, s, deco]);

printf ("\nMenu: (R)estart browser. Other key : done. ");
inch = upper (kbhit());

## while my_menu ("\nMenu: (R)estart browser. Other key : done") == "R",
while inch == "R",
  vrml_browse ("-kill");
  vrml_browse ([s,deco]);
  printf ("\nMenu: (R)estart browser. Other key : done. ");
  inch = upper (kbhit());
end
printf ("\n");

## printf ("press <CR> when done selecting points\n");
## pause

## vrml_browse ("-kill");	# Stop browser #######################

				# Retrieve history of clicks #########
perlcmd = "print qq{$1,$2;} if /^TAG:\\s*(\\d+)\\s*STATE:\\s*(\\d+)/";
cmd = sprintf ("perl -ne '%s' %s",perlcmd,data_out);

res = system (cmd, 1);
res = res(1:length(res)-1);	# Remove last ";"
stl = eval (["[",res,"];"])';	# List of clicks

sel2 = sel1 ;

				# Build new selection matrix
## HERE I trust octave to behave as 
## for i=1:columns(stl), sel2(stl(1,:)) = stl(2,i); end

if ! isempty (stl), sel2(stl(1,:)) = stl(2,:); end

				# Eventually transform 0-1 matrix into 
				# list of selected points.
if want_list, sel2 = find (sel2); end

[err, msg] = unlink (data_out);
if err,
  printf (["select_3D_points :\n",\
	   "    error '%s'\n",\
	   "    while removing temp file %s\n"],\
	  msg,err);
end
