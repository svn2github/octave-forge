## Copyright (C) 2012 Etienne Grossmann <etienne@egdn.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.
##

## full_path = vrml_set_browser (proposed_browser) - Set or find a vrml browser
##
## If argument proposed_browser is passed and non-empty, then vmrl_set_browser()
## tries to determine whether proposed_browser is a valid program. If it is,
## then the global variable vrml_b_name is set to the full path, which is also
## returned. Otherwise, an error occurs.
##
## If argument proposed_browser is empty or missing, then vrml_set_browser()
## tries to determine whether either freewrl ( > 0.25) or whitedune (two vrml
## browsers) are available. If one is found, then the global variable
## vrml_b_name is set to the full path, which is also returned. Otherwise, an
## error occurs.
##
## WARNING: vrml_set_browser has only been tested under Linux. Please report
## successes / problems / patches on other systems.
##
## See also: vrml_browse(), FreeWRL homepage http://www.crc.ca/FreeWRL,
## whitedune homepage http://vrml.cip.ica.uni-stuttgart.de/dune.
##
function full_path = vrml_set_browser (proposed_browser_name)

global vrml_b_name;

full_path = vrml_b_name;

if nargin < 1 || isempty (proposed_browser_name)

  browser_list = {"freewrl", "whitedune"};

  for i = 1:numel(browser_list)

    ## TODO: Test this under windows
    [status, full_path] = system (sprintf ("which %s", b{i}));
    if status != 1
      vrml_b_name = full_path;
      return;
    endif
  endfor

  error ("No VRML browser available");
endif

## TODO: Test this under windows
[status, full_path] = system (sprintf ("which %s", proposed_browser_name));
if status == 1
  error (sprintf ("VRML browser `%s' is not available", proposed_browser_name));
endif
vrml_b_name = full_path;