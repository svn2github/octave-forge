function plot (dat)

  [n, p, m, e] = size (dat)

  if (m == 0)  # time series
    for k = 1 : e
      plot (dat.y{k})
      hold on
    endfor
  else         # inputs present
    for k = 1 : e
      subplot (2, 1, 1)
      plot (dat.y{k})
      hold on
      subplot (2, 1, 2)
      stairs (dat.u{k})
      hold on
    endfor
  endif
  
  hold off

endfunction