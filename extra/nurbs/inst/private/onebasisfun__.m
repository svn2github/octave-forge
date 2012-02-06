function N = onebasisfun__ (u, p, U)

%  __ONEBASISFUN__: Undocumented internal function
%
%   Copyright (C) 2009 Carlo de Falco
%   Copyright (C) 2012 Rafael Vazquez
%   This software comes with ABSOLUTELY NO WARRANTY; see the file
%   COPYING for details.  This is free software, and you are welcome
%   to distribute it under the conditions laid out in COPYING.

  N = zeros (size (u));

  for ii = 1:numel (u)
    if (~ any (U <= u(ii))) || (~ any (U > u(ii)))
      continue;
    elseif (p == 0)
      N(ii) = 1;
      continue;
    else
      ln = u(ii) - U(1);
      ld = U(end-1) - U(1);
      if (ld ~= 0)
        N(ii) = N(ii) + ln * onebasisfun__ (u(ii), p-1, U(1:end-1))/ ld; 
      end

      dn = U(end) - u(ii);
      dd = U(end) - U(2);
      if (dd ~= 0)
        N(ii) = N(ii) + dn * onebasisfun__ (u(ii), p-1, U(2:end))/ dd;
      end
    end
  end
  
end
