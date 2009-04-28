function y=striplegend(x)
  start = 0;
  stop = 0;
  for i=1:length(x)
    if x(i) == ';'
      if start==0, start = i;
      else stop = i;
      end
    end
  end
  if start & stop, x(start:stop) = [];
  elseif start, x(start:length(x)) = [];
  end
  y=x;
