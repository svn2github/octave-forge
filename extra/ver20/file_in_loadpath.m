## Backport of 2.1.x function to find a particular file in the loadpath.
function name = file_in_loadpath(file)
  name = file_in_path(LOADPATH, file);
