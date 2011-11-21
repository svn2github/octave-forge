function post_install (desc)
%% Prepares for installation a package that is organized in subfolders
%% Since src is compiled only in the package main dir
%% I need to remove the PKG_ADD and PKG_DEL from the architecture dependent folder

  arch = cstrcat (octave_config_info ("canonical_host_type"),
                              "-", octave_config_info ("api_version"));
  if exist (arch,"dir")
    system(["ls " arch])
    pause
  end

end
