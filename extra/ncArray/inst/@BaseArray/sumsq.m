% s = sumsq (x, dim)
% compute the sum squared along dimension dim
% See also
%   sum

function s = sumsq(self,varargin)

funred = @plus;
funelem = @(x) x.^2;

s = reduce(self,funred,funelem,varargin{:});

if isempty(s)
  s = 1;
end
