% hist2d ([x,y], xbins, ybins, norm)
% Produce a 2D histogram.
%
% Points xi,yi are stored in a 2-column array.
% If ybins is missing, use xbins.
% If bins is a scalar, use that many bins.
% If bins is a vector, it represents bin edges.

% Author: Paul Kienzle
% This code is public domain.

function [ret_counts, xbins, ybins] = hist2d(M,xbins,ybins)

  if nargin < 1 && nargin > 3, usage("[nn,xx,yy] = hist2d (M,x,y)"); end

  lo = min(M);
  hi = max(M);
  if nargin == 1
    ybins = xbins = 10;
  elseif nargin == 2
    ybins = xbins;
  endif

  # If n bins, find centers based on n+1 bin edges
  if isscalar(xbins) 
    xbins = linspace(lo(1),hi(1),xbins+1); 
    xbins = (xbins(1:end-1)+xbins(2:end))/2;
  end
  if isscalar(ybins)
    ybins = linspace(lo(2),hi(2),ybins+1); 
    ybins = (ybins(1:end-1)+ybins(2:end))/2;
  end    

  xcut = (xbins(1:end-1)+xbins(2:end))/2;
  ycut = (ybins(1:end-1)+ybins(2:end))/2;
  xidx = lookup(xcut,M(:,1))+1;
  yidx = lookup(ycut,M(:,2))+1;
  counts = sparse(xidx,yidx,1,length(xbins),length(ybins),'sum');

  if nargout
    ret_counts = full(counts');
  else
    mesh(xbins,ybins,full(counts'));
  end
end
