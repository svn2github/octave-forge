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

##  p = vrml_browse ([s])       - View vrml code s with FreeWRL
##      vrml_browse ("-kill")   - Kill the browser
##
## s : string : VRML code, as returned by the vrml_XYZ functions. 
##              If  s  is not specified, a sombrero is showed
##
## p : int    : pid of the current browser. If freewrl has not been started
##              or has died, a new one is started. p is zero or negative in
##              case of failure to start freewrl.
##
## Some keystrokes for FreeWRL (more in the freewrl manpage) :
##
## 'e'   : Examine : mouse 1 and drag rotates the scene
##                   mouse 3 and drag moves closer/farther          
## 'w'   : Walk    : mouse 1 and drag moves for/backward, turns
##                   mouse 3 and drag translates parallel to the screen
## 's'   : Save a snapshot in files 'octave.snapshot.NNNN.ppm'
## 'q'   : Quit
## 
## WARNING : FreeWRL >0.25 (http://www.crc.ca/FreeWRL/) must be installed.
##
## BUG     : The vrml browser is not killed when octave exits. Sometimes the
##           vrml browser does not get raised or gets raised improperly
##           (shows the contents of the topmost window above it). Use
##           "-kill".
##
## Author  : Etienne Grossmann <etienne@cs.uky.edu>
function p = vrml_browse (varargin)

verbose = 0;

best_option = " ";
				# Allow scripting and specify where
				# browser's output goes 
##out_option = "--ps --psout /tmp/octave_browser_out.txt " ;
out_option = " " ;
global vrml_b_pid = 0;
global vrml_b_name = [];

p = vrml_b_pid ;
bop = "";

if nargin<1
  s = "";
else
  i = 1;
  while i <= length (varargin)
    o = varargin{i++};
    if strcmp (o, "-kill")
      vrml_kill(); return;
    elseif strcmp (o, "-bop")	# Browser options
      bop = [bop," ",varargin{i++}," "];
    end
  end
  s = varargin{length (varargin)};
end




vrml_b_name = "freewrl" ;

##b_opt = [out_option," ",bop," ",best_option," --server --snapb octave.snap "] ;
b_opt = [out_option," ",bop," ",best_option] ;


b_temp = "/tmp/octave_vrml_output.wrl" ;
b_log  = " &> /tmp/octave_vrml_browser.log";

new_browser = 0 ;
				# ####################################
if vrml_b_pid > 0		# There's already a browser ##########

				# Check that browser is really alive

  [status, dum] = system (sprintf ("kill -CONT %d &> /dev/null",vrml_b_pid));
  
  if ! status
    if verbose
      printf ( "vrml_browse : browser pid=%d is still alive\n",vrml_b_pid);
    end
  else 
    if verbose
      printf ( ["vrml_browse : ",\
		"browser pid=%d died. I'll spawn another\n"], vrml_b_pid);
    end
    vrml_b_pid = -1 ;
  end
end				# End of check if old browser's alive 
				# ####################################

				# ####################################
				# Check that temp file exists ########
[status, dum] = system (["test -e ",b_temp]);
if !length (s)

  if verbose
    printf( "vrml_browse : Trying to create temp file\n");
  end
				# Do a sombrero
  n = 30 ;
  x = y = linspace (-8, 8, n)';
  [xx, yy] = meshgrid (x, y);
  r = sqrt (xx .^ 2 + yy .^ 2) + eps;
  z = 3*sin (r) ./ (2*r);
  x /= 4 ; y /= 4 ;

  ##  pix = ones (n) ;
  ##    tmp = [1 0 0 1 1 1 0 0 1 1 0 0 0 0 0 1 1 0 0 1 1 1 0 1 0 1 1 0 0 0 ;\
  ##  	 0 1 1 0 1 0 1 1 0 1 1 1 0 1 1 1 0 1 1 0 1 1 0 1 0 1 1 0 1 1 ;\
  ##  	 0 1 1 0 1 0 1 1 1 1 1 1 0 1 1 1 0 1 1 0 1 1 0 1 0 1 1 0 0 0 ;\
  ##  	 0 1 1 0 1 0 1 1 0 1 1 1 0 1 1 1 0 0 0 0 1 1 0 1 0 1 1 0 1 1 ;\
  ##  	 1 0 0 1 1 1 0 0 1 1 1 1 0 1 1 1 0 1 1 0 1 1 1 0 1 1 1 0 0 0 ];

  ##    rtmp = rows(tmp)+2;
  ##    for i=1:rtmp:n-rtmp,
  ##      pix(i+[1:rows(tmp)],1:columns(tmp)) = tmp ;
  ##    end
  ##    pix = flipud (pix);
  ##    col = [1;1;1]*pix(:)' ;
  ## keyboard
  rmat = [0.90000  -0.38730   0.20000;
	  0.38730   0.50000  -0.77460;
	  0.20000   0.77460   0.60000];
  ## s = vrml_points ([x(:),y(:),z(:)],"balls");
  ## s =  vrml_transfo (vrml_thick_surf (x,y,z, "col",col), [0.25,0,0],rmat);
  s =  vrml_transfo (vrml_thick_surf (x,y,z), [0.25,0,0],rmat );
end


save_vrml (b_temp, s); # "nobg", s) ;
				# End of preparing temp file #########
				# ####################################

				# ####################################
				# Eventually start browser ###########
if vrml_b_pid <= 0
  new_browser = 1 ;
  if verbose, 
    printf( "vrml_browse : spawning browser ...\n");
  end
  ## keyboard
				# Starting a background browser : 
				# 
				# popen2 seems broken.
				# popen  had some problem, can't recall what
				# system "async" does not give me pid of
				#        browser, but pid of shell
				# system "sync" only returns when child
				#        process has exited
				# 
				# So my solution is : "system" a process that
				# forks. Its child is a browser. The parent
				# prints the child's pid (given by fork())
				# and exits. Octave reads the output of the
				# system call, which is the browser's pid.
				# Phew!  
##  [status, out] = system (cmd = [vrml_b_name," ",b_opt," \"file:",b_temp,"\""], 1);
  [status, out] = system (cmd = [vrml_b_name," ",b_opt," ",b_temp], 1);
##  cmd
  if status,
    
    printf("vrml_browse : Can't start browser '%s'. Is it installed?\n",\
	   vrml_b_name);
      p = vrml_b_pid ;
    return ;
  else

    vrml_b_pid = -1;
    server_works = 0;
    if server_works
      vrml_b_pid = str2num (out);
    end

    if verbose, printf( "vrml_browse : OK\n"); end
  end

end				# End of starting new browser ########
				# ####################################

if (!new_browser) && (vrml_b_pid > 1)
				# ####################################
				# Send USR1 signal to browser to tell it to
				# raise itself.
  [status, dum] = system (sprintf ("kill -USR1 %d &> /dev/null",vrml_b_pid));

  if status,  
    printf ("vrml_browse : browser pid=%d can't be signaled\n",vrml_b_pid);
  else 
    if verbose, 
      printf( ["vrml_browse : USR1 sent to browser pid=%d\n"], vrml_b_pid);
    end
  end
end				# End of signaling  browser ##########
				# ####################################

p = vrml_b_pid ;
endfunction

