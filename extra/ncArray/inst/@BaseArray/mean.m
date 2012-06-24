% s = mean (X, DIM)
% compute the mean along dimension dim
% See also
%   mean
function s = mean(self,varargin)

funred = @plus;
funelem = @(x) x;

[s,n] = reduce(self,funred,funelem,varargin{:});

if isempty(s)
  s = 0;
else
  s = s/n;
end
