## usage: tk_init
##
## Start the interpreter if it is not already running.
## Do any required initialization. Currently, this
## just hides the root window.  You can restore it
## again with tk_cmd("wm deiconify .")

## This code is in the public domain.

function tk_init
  try
    tk_interp;
    tk_cmd("wm withdraw .");
  catch
  end
endfunction
