function x=is_vector(y)
  x=~isempty(y)&(all(size(y)==1)|sum(size(y)~=1)==1);