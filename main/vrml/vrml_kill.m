##  p = vrml_kill ()            - Kill the current vrml browser
## 
## If a vrml browser has previously been launched with vrml_browse(), it
## will be sent a KILL signal.
##
## See also : vrml_browse.
##
## Author  : Etienne Grossmann   <etienne@isr.ist.utl.pt>
function p = vrml_kill ()

global vrml_b_pid = 0;

if vrml_b_pid, 
  printf ("vrml_browse : Sending kill signal to browser\n");
  system (sprintf ("kill -KILL %d &> /dev/null",vrml_b_pid));
else
  printf ("vrml_browse : No live browser to kill\n");
end
vrml_b_pid = 0;
return
