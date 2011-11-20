function pre_install (desc)
%% Prepares for installation a package that is organized in subfolders

  %% List of folders with src subfolder
  subfld = {"octclip"};

  %% Create correct strings
  subfld_ready = strcat({[pwd() filesep()]},
                         subfld,[filesep() "src"]);

  %% Destination folder
  to_fld = strcat(pwd,filesep ());


  %% Copy files to package/src folder
  for from_fld = subfld_ready
  %% TODO handle merging of Makefiles
    warning("Multiple Makefiles not handled")
    disp (["mv " from_fld{1} " " to_fld])
    %system (["mv " from_fld{1} " " to_fld]);
  end

end
