## Copyright (C) 2012 Philip Nienhuis <prnienhuis@users.sf.net>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## Check for JAVA_HOME setting and JDK presence before attempting to
## install the Java package

## Author: Philip Nienhuis
## Created: 2012-06-24

function [ ret ] = pre_install ()

  jdk_ok = false;
  ## Get JAVA_HOME contents
  jh = getenv ("JAVA_HOME");
  
  ## Check if has been set at all
  if (isempty (jh))
    printf ("\nError while trying to install Java package:\n");
    printf ("environment variable 'JAVA_HOME' has not been set.\n");
    printf ("  use 'setenv (\"JAVA_HOME\", \"/full/path/to/javaJDK\")'\n");
    
  else
    ## Check if JAVA_HOME points to a jvm (that is, given the variety of
    ## Java installations in the wild, merely check JAVA_HOME/jre/lib)
    ## and the executables are in the PATH
    if (ismac)
      ## Look in <jh>/../Libraries/
      if (exist ([jh filesep ".." filesep "Libraries" filesep "libclient.dylib"], "file") == 2)
        jdk_ok = true; 
      endif

    else
      jhd = dir ([jh filesep "jre" filesep "lib"]);
      if (! isempty (jhd))

        ## Search for a subdir (hopefully <arch>/) containing a
        ## subdir client/ (*nix) or a file jvm.cfg (Windows)
        ijhd = find (cell2mat ({jhd.isdir}));
        ii = 3;                    # Ignore current and parent dirs
        while ii < numel (ijhd)
          jhsd = dir ([jh filesep "jre" filesep "lib" filesep jhd(ijhd(ii)).name]);
          ## Check if client is a subdir (hopefully of <arch>/)
          id = strmatch ("client", {jhsd.name});
          if ((! isempty (id)) && jhsd(id).isdir)
            cl_dir = [jh filesep "jre" filesep "lib" filesep jhd(ijhd(ii)).name filesep "client"];
            jhcsd = dir (cl_dir);
            ## Check for a libjvm* file inside. Should work if it's a link too.
            jdk_ok = ! isempty (strmatch ("libjvm", {jhcsd.name}));
            if (! jdk_ok); 
              printf ("  No libjvm library found in %s\n", cl_dir); 
            endif
          endif
          ## Below line especially for Windows installations
          jdk_ok = jdk_ok || (! isempty (strmatch ("JVM.CFG", upper ({jhsd.name}))));
          if (jdk_ok);  ii += numel (ijhd); endif
          ++ii;
        endwhile

        ## Try the Java executables. If we find javac we're probably OK
        if (ispc)
          jtst = (system ('javac -version 2> nul'));
        else
          jtst = (system ('javac -version 2> /dev/null'));
        endif
        if (jtst)         ## Should be zero if command returned normally
          ## OK, found Java compiler & it works.
        elseif (jdk_ok)
          ## Apparently javac is not in the PATH (as usual on e.g., Windows).
          ## Try to find it tru JAVA_HOME, if found add JAVA_HOME/bin to the
          ## environment PATH
          jpth = [jh filesep "bin"];
          if (ispc)
            jtst = (system ([ jpth filesep 'javac -version 2> nul' ]));
          else
            jtst = (system ([ jpth filesep 'javac -version 2> /dev/null' ]));
          endif
          if (! jtst)
            setenv ("PATH", [ jpth pathsep getenv("PATH") ]);
          endif
        endif
      endif
    endif
    
    if (! jdk_ok);
      printf ("\nError while trying to install Java package:\n");
      printf ("JAVA_HOME environment variable does not properly point to a JDK\n");
    endif
  endif

  if (! jdk_ok);
    printf ("  Hint:\n");
    printf ("  JAVA_HOME should usually be set such that either:\n");
    printf ("  (on *nix:)\n");
    printf ("    <JAVA_HOME>/jre/lib/<arch>/client/ contains libjvm.so (file or symlink)\n");
    printf ("  (on OSX:)\n");
    printf ("    <JAVA_HOME>/../Libraries/ contains a file libclient.dylib\n");
    printf ("  (on Windows:)\n");
    printf ("    <JAVA_HOME>/jre/lib/<arch>/ contains a file jvm.cfg\n");
    printf ("  (<arch> depends on your system hardware, can be i386, x86_64, alpha, arm, ...)\n\n");
    printf ("  Use forward slashes as path separator, also on Windows\n");
    error  ("Aborting pkg install");
  endif
  
endfunction
