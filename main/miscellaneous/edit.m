## edit name
##   Edit the named function.  
##
##   If the function is available in a file on your path and that file 
##   is modifiable, then it will be editted in place.  If it is a system 
##   function, then it will first be copied to the directory HOME 
##   and then editted.  
##
##   If name is the name of a function defined in the interpreter but 
##   not in an m-file, then an m-file will be created in HOME
##   to contain that function along with its current definition.  
##
##   If name.cc is specified, then it will search for name.cc in the
##   path and try to modify it, otherwise it will create a new .cc file
##   in HOME.  If name happens to be an m-file or interpreter
##   defined function, then the text of that function will be inserted
##   into the .cc file as a comment.
##
##   If name.ext is on your path then it will be editted, otherwise
##   the editor will be started with HOME/name.ext as the
##   filename.  If name.ext is not modifiable, it will be copied to
##   HOME before editting.
##
##   WARNING!! You may need to clear name before the new definition
##   is available.  If you are editting a .cc file, you will need
##   to mkoctfile name.cc before the definition will be available.
##
## edit field value
##   Set the value for an edit control field.
##
## edit get field
##   Return the value for an edit control field.
##
## The following control fields are used:
##
## editor
##   This is the editor to use to modify the functions.  By default it uses
##   Octave's EDITOR state variable, which comes from getenv("EDITOR") and
##   defaults to vi.  Use %s in place of the function name.  E.g.,
##     [EDITOR, " %s"]
##       use the editor which Octave uses for bug_report
##     "xedit %s &"           
##       pop up simple X11 editor in a separate window
##     "gnudoit -q \"(find-file \\\"%s\\\")\""   
##       send it to current emacs; must have (gnuserv-start) in .emacs
##
## home
##   This is the location of user local m-files. Be be sure it is on LOADPATH.
##   The default is ~/octave.
##
## author
##   This is the name to put after the "## Author:" field of new functions.
##   By default it guesses from the `gecos' field of password database.
## 
## email
##   This is the e-mail address to list after the name in the author field.
##   By default it guesses <$LOGNAME@$HOSTNAME>, and if $HOSTNAME is not
##   defined it uses "uname -n".  You probably want to override this.  Be
##   sure to use "<user@host>" as your format.
##
## license
##   gpl     GNU General Public License (default)
##   bsd     BSD-style license without advertising clause
##   pd      public domain
##   "text"  your own default copyright and license
## 
##   Unless you specify PD, edit will prepend the copyright statement 
##   with "Copyright (C) yyyy Function Author"

## Author: Paul Kienzle <pkienzle@users.sf.net>

## This program is granted to the public domain.

## 2001-04-10 Paul Kienzle <pkienzle@users.sf.net>
## * Initial revision

## PKG_ADD: mark_as_command edit

function ret = edit(file,state)
  ## pick up globals or default them
  persistent FUNCTION = struct ("EDITOR", [ EDITOR, " %s" ],
  				"HOME", [ getenv("HOME"), "/octave" ],
  				"AUTHOR", getpwuid(getuid).gecos,
  				"EMAIL",  [],
  				"LICENSE",  "GPL");
  mlock; # make sure the state variables survive "clear functions"

  if (nargin == 2)
    switch toupper(file)
    case 'EDITOR'
    	FUNCTION.EDITOR=state;
    case 'HOME'
        if !isempty(state) && state(1) == '~'
	  state = [ getenv("HOME"), state(2:end) ];
	endif
    	FUNCTION.HOME=state;
    case 'AUTHOR'
    	FUNCTION.AUTHOR=state;
    case 'EMAIL'
    	FUNCTION.EMAIL=state;
    case 'LICENSE'
    	FUNCTION.LICENSE=state;
    case 'GET'
        ret = FUNCTION.(toupper(state));
    otherwise
    	error('expected "edit EDITOR|HOME|AUTHOR|EMAIL|LICENSE val"');
    end
    return
  end

  ## start the editor without a file if no file is given
  if nargin < 1
    system(['cd "',FUNCTION.HOME,'" ; ',sprintf(FUNCTION.EDITOR,"")]);
    return
  endif

  ## find file in path
  idx = rindex(file,'.');
  if idx != 0
    ## if file has an extension, use it
    path = file_in_loadpath(file);
  else
    ## otherwise try file.cc, and if that fails, default to file.m
    path = file_in_loadpath( [ file, ".cc" ] );
    if isempty(path)
      file = [ file, ".m" ];
      path = file_in_loadpath (file);
    endif
  endif

  ## if the file exists and is modifiable in place then edit it,
  ## otherwise copy it and then edit it.
  if !isempty(path)
    fid = fopen(path,"r+t");
    if (fid >- 0)
      fclose(fid);
    else
      from = path;
      path = [ FUNCTION.HOME, from(rindex(from,"/"):length(from)) ] ;
      system (sprintf("cp '%s' '%s'", from, path));
    endif
    system(sprintf(FUNCTION.EDITOR, ["'", path, "'"]));
    return
  endif

  ## if editing something other than a m-file or an oct-file, just
  ## edit it.
  path = [ FUNCTION.HOME, "/", file ];
  idx = rindex(file,'.');
  name = file(1:idx-1);
  ext = file(idx+1:length(file));
  switch (ext)
    case { "cc", "m" } 0;
    otherwise
      system(sprintf(FUNCTION.EDITOR, ["'", path, "'"]));
      return;
  endswitch
      
  ## the file doesn't exist in path so create it, put in the function
  ## template and edit it.

  ## guess the email name if it was not given.
  if (isempty(FUNCTION.EMAIL))
    host=getenv("HOSTNAME");
    if isempty(host), 
      [status, host] = system("uname -n");
                                # trim newline from end of hostname
      if !isempty(host) host = host(1:length(host)-1); endif
    endif
    if isempty(host)
      FUNCTION.EMAIL = " ";
    else
      FUNCTION.EMAIL = [ "<", getpwuid(getuid).name, "@", host, ">" ];
    endif
  endif
    
  ## fill in the revision string
  now = localtime(time);
  revs = [ strftime("%Y-%m-%d",now), " ", FUNCTION.AUTHOR, " ", ...
	  FUNCTION.EMAIL, "\n* Initial revision" ];

  ## fill in the copyright string
  copyright = strftime(["Copyright (C) %Y ", FUNCTION.AUTHOR], now);

  ## fill in the author tag field
  author = [ "Author: ", FUNCTION.AUTHOR, " ", FUNCTION.EMAIL ];
  
  ## fill in the header
  uclicense=toupper(FUNCTION.LICENSE);
  switch uclicense
    case "GPL"
      head = [ copyright, "\n\n", "\
This program is free software; you can redistribute it and/or modify\n\
it under the terms of the GNU General Public License as published by\n\
the Free Software Foundation; either version 2 of the License, or\n\
(at your option) any later version.\n\
\n\
This program is distributed in the hope that it will be useful,\n\
but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n\
GNU General Public License for more details.\n\
\n\
You should have received a copy of the GNU General Public License\n\
along with this program; if not, write to the Free Software\n\
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA\
" ];
      tail = [ author, "\n\n", revs ];

    case "BSD"
      head = [ copyright, "\n\n", "\
This program is free software; redistribution and use in source and\n\
binary forms, with or without modification, are permitted provided that\n\
the following conditions are met:\n\
\n\
   1.Redistributions of source code must retain the above copyright\n\
     notice, this list of conditions and the following disclaimer.\n\
   2.Redistributions in binary form must reproduce the above copyright\n\
     notice, this list of conditions and the following disclaimer in the\n\
     documentation and/or other materials provided with the distribution.\n\
\n\
THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND\n\
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE\n\
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE\n\
ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE\n\
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL\n\
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS\n\
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)\n\
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT\n\
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY\n\
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF\n\
SUCH DAMAGE.\
" ];
      tail = [ author, "\n\n", revs ];
    case "PD"
      head = "";
      tail = [ author, "\n\n", ...
	      "This program is granted to the public domain\n\n", ...
	      revs ];
    otherwise
      head = "";
      tail = [ copyright, "\n\n", FUNCTION.LICENSE, "\n", ...
	      author, "\n\n", revs ];
  endswitch
    
  ## generate the function template
  exists = exist(name);
  switch (ext)
    case {"cc","C","cpp"}
      if isempty(head)
	comment = ["/*\n", tail, "\n\n*/\n\n"];
      else
	comment = ["/*\n", head, "\n\n", tail, "\n\n*/\n\n"];
      endif
      ## if we are shadowing an m-file, paste the code for the m-file
      if any(exists == [2,103])
	code = [ "\\ ", strrep(type(name),"\n","\n// ") ];
      else
	code = " ";
      endif
      body = [ "#include <octave/oct.h>\n\n", ...
	      "DEFUN_DLD(", name, ",args,nargout,\"\\\n", ...
	      name, "\\n\\\n\")\n{\n", ...
	      "  octave_value_list retval;\n", ...
	      "  int nargin = args.length();\n\n", ...
	      code, "\n  return retval;\n}\n" ];
      text = [ comment, body ];
    case "m"
      ## if we are editting a function defined on the fly, paste the code
      if any(exists == [2,103])
	body = type(name);
      else
	body = [ "function [ ret ] = ", name, " ()\n\nendfunction\n" ];
      endif
      if isempty(head)
	comment = [ "## ", name, "\n\n", ...
                    "## ", strrep(tail,"\n","\n## "), "\n\n" ];
      else
	comment = [ "## ", strrep(head,"\n","\n## "), "\n\n", ...
                    "## ", name, "\n\n", ...
                    "## ", strrep(tail,"\n","\n## "), "\n\n" ];
      endif
      text = [ comment, body ];
  endswitch

  ## Write the initial file (if there is anything to write)
  fid = fopen(path, "wt");
  if (fid<=0)
    error("edit: could not create %s", path);
  endif
  fputs(fid, text);
  fclose(fid);

  ## Finally we are ready to edit it!
  system(sprintf(FUNCTION.EDITOR, ["'", path, "'"]));

endfunction
