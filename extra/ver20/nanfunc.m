## Usage: R = nanfunc( which_func, a_matrix, default_for_func ) 
## applies 'which_func' to non-NaN values of 'a_matrix' columnwise, 
## returning 'default_for_func' if all values are NaN.

## Copyright (C) 2000 Daniel Calvelo Aros 
## 
## Do what you want with this code. No warranty whatsoever.
##
## Author:  Daniel Calvelo Aros <dcalvelo@phare.univ-lille2.fr>
## Description:  Generic function caller for dealing with NaNs as
##               missing data

function M = nanfunc(func,m,default),
  [r,c] = size(m);
  if r == 1,
    m = m(:);
    c = 1;
  endif;
  M = zeros(1,c);
  for col=1:c,
    f = find(~isnan(m(:,col)));
    if isempty(f),
      M(col) = default;
    else
      M(col) = feval(func, m(f,col) );
    endif;
  endfor;
endfunction;
