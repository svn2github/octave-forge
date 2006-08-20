%USAGE  y = thfm ( x, MODE )
%
%       trigonometric/hyperbolic functions of square matrix x
%
%MODE	cos   sin   tan   sec   csc   cot
%	cosh  sinh  tanh  sech  csch  coth
%       acos  asin  atan  asec  acsc  acot
%       acosh asinh atanh asech acsch acoth
%       sqrt  log   exp
%
%NOTE		--- IMPORTANT ---
%	This algorithm does  NOT USE an eigensystem
%	similarity transformation. It maps the MODE
%	functions to functions of expm, logm and sqrtm, 
%       which are known to be robust with respect to
%	non-diagonalizable ('defective') x
%
%EXA	thfm( x ,'cos' )  calculates  matrix cosinus
%	EVEN IF input matrix x IS NOT DIAGONALIZABLE
%
%ASSOC	expm, sqrtm, logm, funm
% Copyright	(C) 2001 Rolf Fabian <fabian@tu-cottbus.de>
% 010213
%	published under current GNU GENERAL PUBLIC LICENSE

% 2001-03-15 Paul Kienzle
%     * extend with inverse functions and power functions
%     * optimize handling of real input

function y=thfm(x,M)
				#% minimal arg check only
  if	nargin~=2||~ischar(M)||ischar(x)	
    usage ("y = thfm (x, MODE)");
  endif

  ## look for known functions of sqrt, log, exp
  I = eye(size(x));
  match = 1;
  len =  length(M);
  if	len==3
    
    if	M=='cos',  
      if (isreal(x))     y = real( expm( i*x ) );
      else               y = ( expm( i*x ) + expm( -i*x ) ) / 2;
      endif
      
    elseif	M=='sin',
      if (isreal(x))     y = imag( expm( i*x ) );
      else               y = ( expm( i*x ) - expm( -i*x ) ) / (2*i);
      endif
      
    elseif	M=='tan',
      if (isreal(x))     t = expm( i*x );    y = imag(t)/real(t);
      else     	         t = expm( -2*i*x ); y = -i*(I-t)/(I+t);
      endif
      
    elseif	M=='cot',		% == cos/sin
      if (isreal(x))     t = expm( i*x );    y = real(t)/imag(t);
      else	         t = expm( -2*i*x ); y = i*(I+t)/(I-t);
      endif
      
    elseif	M=='sec',  
      if (isreal(x))     y = inv( real(expm(i*x)) );
      else               y = inv( expm(i*x)+expm(-i*x) )*2 ;
      endif
      
    elseif	M=='csc',  
      if (isreal(x))     y = inv( imag(expm(i*x)) );
      else               y = inv( expm(i*x)-expm(-i*x) )*2i;
      endif

    elseif    M=='log',  y = logm(x);
      
    elseif    M=='exp',  y = expm(x);
      
    else match = 0;

    endif
    
  elseif	len==4
    
    if      M=='cosh',   y = ( expm(x)+expm(-x) )/2;
      
    elseif  M=='sinh',   y = ( expm(x)-expm(-x) )/2;
      
    elseif  M=='tanh'    t = expm( -2*x ); y = (I - t)/(I + t);
     
    elseif  M=='coth', 	 t = expm( -2*x ); y = (I + t)/(I - t);
      
    elseif  M=='sech',   y = 2 * inv( expm(x) + expm(-x) );
      
    elseif  M=='csch',   y = 2 * inv( expm(x) - expm(-x) );
      
    elseif  M=='asin',   y = -i * logm( i*x + sqrtm(I - x*x) );
      
    elseif  M=='acos',   y =  i * logm( x - i*sqrtm(I - x*x) );

    elseif  M=='atan',   y = -i/2 * logm( (I + i*x)/(I - i*x) );

    elseif  M=='acot',   y =  i/2 * logm( (I + i*x)/(i*x - I) );

    elseif  M=='asec',   y = i * logm( ( I - sqrtm(I - x*x) ) / x );

    elseif  M=='acsc',   y = -i * logm( i*( I + sqrtm(I - x*x) ) / x );

    elseif  M=='sqrt',   y = sqrtm(x);

    else match = 0;

    end

  elseif   len==5

    if      M=='asinh',  y = logm( x + sqrtm (x*x + I) );
      
    elseif  M=='acosh',  y = logm( x + sqrtm (x*x - I) );
      
    elseif  M=='atanh',  y = logm( (I + x)/(I - x) ) / 2;
      
    elseif  M=='acoth',  y = logm( (I + x)/(x - I) ) / 2;

    elseif  M=='asech',  y = logm( (I + sqrtm (I - x*x)) / x );

    elseif  M=='acsch',  y = logm( (I + sqrtm (I + x*x)) / x );

    else match = 0;

    endif

  else match = 0;

  endif

  ## if no known function found, use generic solver
  if (match == 0)
    y = funm( x, M );
  endif
endfunction
