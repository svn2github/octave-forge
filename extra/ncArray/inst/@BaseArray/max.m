% s = max (x, [], dim)
% compute the maximum along dimension dim
% See also
%   max

function s = max(self,B,varargin)

assert(isempty(B))

funred = @max;
funelem = @(x) x;

s = reduce(self,funred,funelem,varargin{:});
