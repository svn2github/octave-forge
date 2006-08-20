## csvwrite(f,m,...) -> dlmwrite(f,m,',',...)
function m = csvwrite(f,m,varargin)
  dlmwrite(f,m,',',varargin{:});
