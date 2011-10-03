function pre_install (desc)
%% Prepares for installation a package that is organized in subfolders 

  %% List of subfolders
  subfld = {"molecularDynamics","ocframe"};

  %% Create correct strings
  subfld_ready = strcat({[pwd() filesep() "inst" filesep()]},
                         subfld,[filesep() "*"]);

  %% Destination folder
  to_fld = strcat(pwd, filesep ());


  %% Copy files to package/ folder
  for from_fld = subfld_ready
    system (["cp -Rf " from_fld{1} " " to_fld]);
    system (["rm -R " from_fld{1}(1:end-2)]);
  end

end
