## Copyright (C) 2008  Rafael Laboissiere
##
## This file is in the public domain.

## Function zlim does not work with the Grace graphic interface.
## In order to use this function, please revert to the standard
## graphic interface by doing 'toggle_grace_use ("off")'.

function zlim ()
  
  error ("Function zlim does not work with the Grace graphic interface.\n\
In order to use this function, please revert to the standard\n\
graphic interface by doing 'toggle_grace_use (\"off\")'.");

endfunction
