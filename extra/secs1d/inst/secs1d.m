# Run this only if the package is installed
## PKG_ADD: if (! exist (fullfile (fileparts (mfilename ("fullpath")), "inst"), "dir"))
## PKG_ADD:  dirlist= {"Utilities","DDG","DDN"};
## PKG_ADD:  for ii=1:length(dirlist)
## PKG_ADD:     addpath ( [ fileparts( mfilename("fullpath")) "/" dirlist{ii}])
## PKG_ADD:  end
## PKG_ADD: end

# Run this only if the package is installed
## PKG_DEL: if (! exist (fullfile (fileparts (mfilename ("fullpath")), "inst"), "dir"))
## PKG_DEL:  dirlist= {"Utilities","DDG","DDN"};
## PKG_DEL:  for ii=1:length(dirlist)
## PKG_DEL:     rmpath ( [ fileparts( mfilename("fullpath")) "/" dirlist{ii}])
## PKG_DEL:  end
## PKG_DEL: end
