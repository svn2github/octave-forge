% Extract FFT
for N = 1:500

  if (rem (N, 2))     % odd
    n1 = (N+1)/2;
  else                % even
    n1 = N/2+1;
  endif

  n2 = fix (N/2) + 1;
  
  if (n1 != n2)
    warning ("FFT %d: n1=%d, n2=%d", N, n1, n2);
  endif
  
endfor


% Frequency Vector
for N = 1:500

  if (rem (N, 2))     % odd
    n1 = (N-1)/2;
  else                % even
    n1 = N/2;
  endif

  n2 = fix (N/2);
  
  if (n1 != n2)
    warning ("W %d: n1=%d, n2=%d", N, n1, n2);
  endif
  
endfor
