## clf
##   Clear the current figure and any associated annotations.
##   Unlike clg, clf clears text, arrows, etc.  The terminal
##   type may be wrong after clearing.

## Author: Paul Kienzle
## This program is public domain

function clf
 clg;
 __gnuplot_raw__  ("reset; \n");
 __gnuplot_raw__ ("set data style lines; \n");
endfunction
