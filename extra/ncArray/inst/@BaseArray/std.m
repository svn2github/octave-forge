% s = std (X, OPT, DIM)
% compute the standard deviation
% See also
%   std
function s = std(self,varargin)

s = sqrt(var(self,varargin{:}));
