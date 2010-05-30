function [x, h] = mgorth (x, V)
  for j=1:columns (V)
    h(j) = V(:,j)' * x;
    x   -= h(j) * V (:,j);
  endfor
endfunction
