% s = min (x, [], dim)
% compute the minimum along dimension dim
% See also
%   min

function s = min(self,B,varargin)

assert(isempty(B))

funred = @min;
funelem = @(x) x;

s = reduce(self,funred,funelem,varargin{:});
