function s = prod(self,varargin)

funred = @times;
funelem = @(x) x;

s = reduce(self,funred,funelem,varargin{:});

if isempty(s)
  s = 1;
end
