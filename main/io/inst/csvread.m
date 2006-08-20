## csvread(file,...) -> dlmread(file,',',...)
function m = csvread(f,varargin)
  m = dlmread(f,',',varargin{:});
