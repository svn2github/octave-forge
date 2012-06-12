## Copyright (c) 2012 Benjamin Lewis <benjf5@gmail.com>
## GNU GPLv2

function coeff = lombnormcoeff(X,Y,omega)
tau = atan2( sum( sin( 2.*omega.*X)), sum(cos(2.*omega.*X))) / 2;
coeff = ( ( sum ( Y .* cos( omega .* X - tau ) ) .^ 2 ./ sum ( cos ( omega .* X - tau ) .^ 2 )
	   + sum ( Y .* sin ( omega .* X - tau ) ) .^ 2 / sum ( sin ( omega .* X - tau ) .^ 2 ) )
	 / ( 2 * var(Y) ) );
end