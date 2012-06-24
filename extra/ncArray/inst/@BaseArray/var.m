% s = var (x, opt, dim)
% compute the variance along dimension dim
% See also
%   var

function s = var(self,opt,varargin)

if nargin == 1
  opt = 0;
elseif isempty(opt)
  opt = 0;
end

m = mean(self,varargin{:});

funred = @plus;
funelem = @(x) (x-m).^2;

[s,n] = reduce(self,funred,funelem,varargin{:});

if isempty(s)
  s = 0;
else
  if opt == 0
    s = s/(n-1);
  else
    s = s/n;
  end
end
