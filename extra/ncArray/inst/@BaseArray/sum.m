% s = sum (x, dim)
% compute the sum along dimension dim
% See also
%   sum

function s = sum(self,varargin)

funred = @plus;
funelem = @(x) x;

s = reduce(self,funred,funelem,varargin{:});

if isempty(s)
  s = 0;
end
