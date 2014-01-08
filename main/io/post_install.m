## (C) 2011,2012 Nitzan Arani
## (C) 2014 Philip Nienhuis <prnienhuis at users.sf.net>
## This function moves the PKG_ADD & PKG_DEL scripts from the .oct directory of the io
## package to the function script file after installation. The reason is that PKG_ADD
## calls chk_spreadsheet_support before the function subdir has been added to Octave's
## search path.

## Changes:
## 2014-01-08 Changed to move, rather than remove, PKG_ADD & PKG_DEL

function post_install (desc)

  ## Try to move PKG_ADD & PKG_DEL to the io function script subdir to avoid
  ## PKG_ADD invoking chk_spreadsheet_support before the function dir is in
  ## the load path during loading of io pkg (esp. during installation).
  
  files = cstrcat (desc.archprefix, filesep, octave_config_info ("canonical_host_type"),
                  "-", octave_config_info ("api_version"), filesep, "PKG_???");
  [status, msg] = movefile (files, desc.dir, 'f');
  if (! status)
    warning ("post_install.m: unable to move PKG_ADD & PKG_DEL to script dir: %s", msg);
  endif

endfunction
