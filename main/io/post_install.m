## this function removes the PKG_ADD script from the .oct directory of the io
## package after installation. The reason is that PKG_ADD calls chk_spreadsheet_support
## which belongs to the io package itself. While it is ok when called from the
## .m directory (since chk_spreadsheet_support is there), when called from the
## .oct directory it fails since the package hasn't been loaded yet

function post_install (desc)
  file = cstrcat (desc.archprefix, filesep, octave_config_info ("canonical_host_type"),
                  "-", octave_config_info ("api_version"), filesep, "PKG_ADD");
  [err, msg] = unlink (file);
  if (err)
    warning ("Unable to remove PKG_ADD: %s", msg);
  endif
endfunction
