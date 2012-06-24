function s = sum(self,varargin)

funred = @plus;
funelem = @(x) x;

s = reduce(self,funred,funelem,varargin{:});

if isempty(s)
  s = 0;
end
