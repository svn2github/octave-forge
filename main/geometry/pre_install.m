function pre_install (desc)
%{
%% Prepares for installation a package that is organized in subfolders

  %% List of folders with src subfolder
  subfld = {"octclip"};

  %% Create correct strings
  subfld_ready = strcat ({[pwd() filesep() "inst" filesep()]},
                         subfld,[filesep() "src" filesep() "*"]);

  %% Destination folder
  to_fld = strcat (pwd (),[filesep() "src"]);


  %% Copy files to package/src folder
  %% TODO handle merging of Makefiles
  warning ("Copying subfolder src to package main dir, but multiple Makefiles are not handled")

  if !exist("src","dir")
    system(["mkdir " to_fld]);
  end

  for from_fld = subfld_ready
    system (["mv " from_fld{1} " " to_fld]);
    system (["rm -R " from_fld{1}(1:end-2)]);
  end
%}
end
