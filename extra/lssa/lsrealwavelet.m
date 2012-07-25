# Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>

##-*- texinfo -*-
## @deffun {Function File} {t =} 
## 
##
##
## @end deffun


function transform = lsrealwavelet(T, X, maxfreq, ncoeff, noctave, t_min, t_max, minimum_window_number, sigma=0.1 )

delta_t = (t_max - t_min)/(t_subdiv-1)
# fails if you're trying to use less than 2 windows. Why use the wavelet tool at that point?

len_tx = length (T)
omegamult = 2 ^ ( - 1/ ncoeff )
omegamult_inv = 1 / omegamult
winradius = pi / ( sigma * maxfreq )

current_radius = winradius;

o = maxfreq;

# zeta _ ( t , omega ) = sum(w(sigma omega (t_k - t )e^(-i omega (t_k - t))xi_k)
# / sum( w(sigma omega ( t_k - t ) ) );
#
# w ( t ) = { 1 - 3 | t | ^ 2 + 2 | t | ^ 3 , t in [ - 1 , 1 ] ; 0 for others }

# Now, I *think* that this transform is supposed to be applied by taking
# t as the centre of each window, while sigma should scale the time
# values inside the window to the window. I think.

transform = cell(noctave*ncoeff,1);

## in this, win_t is the centre of the window in question
window_min = t_min;
## Although that will vary depending on the window. This is just an implementation for the first window.
win_t = window_min + window_radius;

windowed_t = ((abs (T-win_t) < window_radius) .* T);
zeta = sum( cubicwgt ((windowed_t - win_t) ./ window_radius) .* exp( - i * o .* windowed_t ) .* X ) / sum ( cubicwgt( windowed_t ./ window_radius ) );
iota = sum( cubicwgt ((windowed_t - win_t) ./ window_radius) .* exp( - i * 2 * o .* windowed_t) .* X ) / sum ( cubicwgt( windowed_t .* 2 * o ) )
## this will of course involve an additional large memory allocation, at least in the short term,
## but it's faster to do the operation once on the time series, then multiply it by the data series.


  
for iter_freq = 1:( noctave * ncoeff )
  t = t_min;
  tx_point = 1;
  for iter_elem = 1:t_subdiv
    if tx_point > len_tx
      break
    endif
    while ( tx_point+1 <= len_tx) && ((t-T(tx_point+1))<winradius)
      tx_point++;
    endwhile
    zeta = 0;
    iota = 0;
    iota0 = 0;
    count = 0;
    ot = o * ( T(tx_point) - t);
    sot = sigma * ot;
    while ( tx_point <= len_tx) && ( (sot = sigma * (ot = o*(T(tx_point)-t))) < pi )
      w = 0.5 * ( 1 + cos (sot));
      iota0 += w;
      zeta += w * ( cos (ot) + sin (ot) * i ) * X(tx_point);
      ot *= 2;
      iota += w * ( cos(ot) + sin (ot) * i );
      count++;
      tx_point++;
    endwhile
    if count > 0
      result = 2 * ( conj (zeta) * iota0 + zeta * conj (iota) ) / ( ( count + iota0 ) ** 2 - real(iota) ** 2 - imag(iota) ** 2 )
      printf("%d\n",result);
      transform(iter_freq,iter_elem) = result;
    else
      transform(iter_freq,iter_elem) = 0;
    endif
    t += delta_t
  endfor
  o *= omegamult
  winradius *= omegamult_inv
  iter_freq
endfor


endfunction
