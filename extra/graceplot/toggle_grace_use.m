## Copyright (C) 2003  Rafael Laboissiere
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2 of the License, or (at your
## option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## Modified: Joao Cardoso
## Modified to work with Grace: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Created on: Sun Oct 18 22:03:10 CEST 1998

## usage: toggle_grace_use
##
## Use this script to activate/deactivate the default library for the
## 2D plotting functions (plot, errorbar, etc.), as both the native
## gnuplot and the Grace interface use similar names to the
## functions. toggle_grace_use post-/pre-pends to LOADPATH the path for
## the Grace functions in successive calls.

1;

global use_grace_state

if(isempty(use_grace_state))
  use_grace_state = "on";
else
  if strcmp (use_grace_state, "on")
    use_grace_state = "off";
  else
    use_grace_state = "on";
  endif
endif

use_grace_path = grace_octave_path;
use_grace_i = findstr (LOADPATH, use_grace_path);
if (!isempty (use_grace_i))
  LOADPATH (use_grace_i(1):use_grace_i(1)+length(use_grace_path)-1)= "";
  LOADPATH = strrep (LOADPATH, "::", ":");
endif

if (strcmp (use_grace_state, "on"))
  LOADPATH = [use_grace_path, ":", LOADPATH];
  __grinit__();
elseif (strcmp (use_grace_state, "off"))
  LOADPATH = [LOADPATH, ":", use_grace_path];
  __grexit__();
endif

use_grace_lcd = pwd;
cd (use_grace_path);

grace_cmds = glob ("*.m");
for gr_ind = 1:size(grace_cmds,1), 
  clear (strrep (deblank(grace_cmds{gr_ind,1}), ".m", ""));
end

cd (use_grace_lcd);

clear use_grace_path use_grace_lcd use_grace_i grace_cmds gr_ind

printf ("Use Grace: %s\n", use_grace_state);

